import Foundation
import SwiftUI
import Combine

@MainActor
public final class PhonebookStore: ObservableObject {
    // MARK: - Published State
    @Published public var selectedDistrict: String {
        didSet {
            UserDefaults.standard.set(selectedDistrict, forKey: "selected_district")
        }
    }

    @Published public var districts: [District] = District.fallbackDistricts
    @Published public var contacts: [Contact] = []
    @Published public var villages: [Village] = []
    @Published public var offices: [Office] = []
    @Published public var emergency: [EmergencyContact] = []
    @Published public var broadcasts: [BroadcastNotice] = []
    @Published public var appInfo: AppInfo = AppInfo()

    // Favorites State
    @Published public var favoriteContacts: [Contact] = []
    @Published public var favoriteContactIds: Set<String> = []
    @Published public var showOnlyFavorites: Bool = false

    @Published public var isLoading: Bool = false
    @Published public var isOffline: Bool = false
    @Published public var isLiveConnected: Bool = false
    @Published public var syncStatusMessage: String = "Connecting..."

    // Filter states
    @Published public var contactSearchText: String = ""
    @Published public var selectedCategory: String = "All"
    @Published public var selectedRole: String = "All"

    @Published public var officeSearchText: String = ""
    @Published public var selectedOfficeCategory: String = "All"

    // UI Sheets / Banners
    @Published public var isDistrictPickerPresented: Bool = false
    @Published public var isNotificationHistoryPresented: Bool = false
    @Published public var isReportSheetPresented: Bool = false
    @Published public var reportTargetContact: Contact? = nil
    @Published public var reportTargetOffice: Office? = nil
    @Published public var reportTargetStaff: StaffMember? = nil
    @Published public var reportTargetEmergency: EmergencyContact? = nil

    @Published public var toastMessage: String? = nil
    @Published public var dismissBroadcastId: String? = nil

    private let api = APIService.shared
    private let cache = CacheManager.shared
    private var cancellables = Set<AnyCancellable>()

    public init() {
        let savedDistrict = UserDefaults.standard.string(forKey: "selected_district") ?? "Kolasib"
        self.selectedDistrict = savedDistrict
        loadCachedData()
        Task {
            await fetchFreshData()
        }
        setupRealtimeSync()
    }

    // MARK: - Offline Caching Hydration
    public func loadCachedData() {
        if let cachedDistricts = cache.load(forKey: "mizoram_districts", as: [District].self), !cachedDistricts.isEmpty {
            self.districts = cachedDistricts
        }

        if let cachedContacts = cache.load(forKey: "contacts_\(selectedDistrict)", as: [Contact].self) {
            self.contacts = cachedContacts
            self.syncStatusMessage = "Cached (\(contacts.count) Contacts)"
        }

        if let cachedVillages = cache.load(forKey: "villages_\(selectedDistrict)", as: [Village].self) {
            self.villages = cachedVillages
        }

        if let cachedOffices = cache.load(forKey: "offices_\(selectedDistrict)", as: [Office].self) {
            self.offices = cachedOffices
        }

        if let cachedEmergency = cache.load(forKey: "emergency_\(selectedDistrict)", as: [EmergencyContact].self) {
            self.emergency = cachedEmergency
        }

        if let cachedBroadcasts = cache.load(forKey: "broadcasts_\(selectedDistrict)", as: [BroadcastNotice].self) {
            self.broadcasts = cachedBroadcasts
        }

        if let cachedAppInfo = cache.load(forKey: "app_info", as: AppInfo.self) {
            self.appInfo = cachedAppInfo
        }

        if let cachedFavorites = cache.load(forKey: "favorite_contacts", as: [Contact].self) {
            self.favoriteContacts = cachedFavorites
            self.favoriteContactIds = Set(cachedFavorites.map { $0.id })
        }
    }

    // MARK: - Fresh Fetch from Server
    public func fetchFreshData() async {
        isLoading = true
        syncStatusMessage = "Syncing \(selectedDistrict)..."

        do {
            async let dReq = api.getDistricts()
            async let cReq = api.getContacts(district: selectedDistrict)
            async let vReq = api.getVillages(district: selectedDistrict)
            async let oReq = api.getOffices(district: selectedDistrict)
            async let eReq = api.getEmergency(district: selectedDistrict)
            async let bReq = api.getBroadcasts(district: selectedDistrict)
            async let aReq = api.getAppInfo()

            let (freshDistricts, freshContacts, freshVillages, freshOffices, freshEmergency, freshBroadcasts, freshAppInfo) =
                try await (dReq, cReq, vReq, oReq, eReq, bReq, aReq)

            self.districts = freshDistricts.isEmpty ? District.fallbackDistricts : freshDistricts
            self.contacts = freshContacts
            self.villages = freshVillages
            self.offices = freshOffices
            self.emergency = freshEmergency
            self.broadcasts = freshBroadcasts
            self.appInfo = freshAppInfo

            self.isOffline = false
            self.syncStatusMessage = "Live Sync: \(selectedDistrict)"

            // Save to offline persistent disk
            cache.save(self.districts, forKey: "mizoram_districts")
            cache.save(self.contacts, forKey: "contacts_\(selectedDistrict)")
            cache.save(self.villages, forKey: "villages_\(selectedDistrict)")
            cache.save(self.offices, forKey: "offices_\(selectedDistrict)")
            cache.save(self.emergency, forKey: "emergency_\(selectedDistrict)")
            cache.save(self.broadcasts, forKey: "broadcasts_\(selectedDistrict)")
            cache.save(self.appInfo, forKey: "app_info")

            // Update favorited contacts with any fresh details from server
            var updatedFavorites = false
            for fresh in freshContacts {
                if let idx = self.favoriteContacts.firstIndex(where: { $0.id == fresh.id }) {
                    self.favoriteContacts[idx] = fresh
                    updatedFavorites = true
                }
            }
            if updatedFavorites {
                cache.save(self.favoriteContacts, forKey: "favorite_contacts")
            }
        } catch {
            print("API Sync error: \(error)")
            self.isOffline = true
            if contacts.isEmpty {
                self.syncStatusMessage = "Offline (No cached data)"
            } else {
                self.syncStatusMessage = "Offline Mode (\(contacts.count) Contacts)"
            }
        }

        isLoading = false
    }

    // MARK: - District Switch
    public func switchDistrict(_ districtName: String) {
        guard districtName != selectedDistrict else { return }
        selectedDistrict = districtName
        selectedCategory = "All"
        selectedRole = "All"
        contactSearchText = ""
        officeSearchText = ""
        showOnlyFavorites = false
        dismissBroadcastId = nil

        loadCachedData()
        showToast("Switched to \(districtName) District")

        Task {
            await fetchFreshData()
        }
    }

    // MARK: - Filtered Contacts
    public var uniqueCategories: [String] {
        let sourceList = showOnlyFavorites ? favoriteContacts : contacts
        var cats = Array(Set(sourceList.compactMap { $0.category })).sorted()
        cats.insert("All", at: 0)
        return cats
    }

    public var filteredContacts: [Contact] {
        let sourceList = showOnlyFavorites ? favoriteContacts : contacts
        let query = contactSearchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        return sourceList.filter { contact in
            // Category filter
            if selectedCategory != "All" && (contact.category ?? "") != selectedCategory {
                return false
            }

            // Role filter
            if selectedRole != "All" {
                let badge = contact.roleBadgeName
                if selectedRole == "President" && badge != "VCP" { return false }
                if selectedRole == "Vice President" && badge != "VCVP" { return false }
                if selectedRole == "Secretary" && badge != "VCS" { return false }
                if selectedRole == "Treasurer" && badge != "Treasurer" { return false }
                if selectedRole == "Member" && badge != "Member" { return false }
                if selectedRole == "Worker" && badge != "Worker" { return false }
            }

            // Search query filter
            if !query.isEmpty {
                let matchesName = contact.name.lowercased().contains(query)
                let matchesVillage = contact.villageName.lowercased().contains(query)
                let matchesDesignation = contact.designation.lowercased().contains(query)
                let matchesPhone = contact.phone.contains(query)
                let matchesDistrict = (contact.district ?? "").lowercased().contains(query)
                if !matchesName && !matchesVillage && !matchesDesignation && !matchesPhone && !matchesDistrict {
                    return false
                }
            }

            return true
        }
    }

    // MARK: - Favorites Management
    public func isFavorite(_ contact: Contact) -> Bool {
        favoriteContactIds.contains(contact.id)
    }

    public func toggleFavorite(_ contact: Contact) {
        if isFavorite(contact) {
            favoriteContactIds.remove(contact.id)
            favoriteContacts.removeAll { $0.id == contact.id }
            showToast("Removed from Saved Contacts")
        } else {
            favoriteContactIds.insert(contact.id)
            if !favoriteContacts.contains(where: { $0.id == contact.id }) {
                favoriteContacts.append(contact)
            }
            showToast("⭐ Saved to Favorites")
        }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        cache.save(favoriteContacts, forKey: "favorite_contacts")
    }

    // MARK: - Filtered Offices
    public var uniqueOfficeCategories: [String] {
        var cats = Array(Set(offices.compactMap { $0.category ?? $0.department })).sorted()
        cats.insert("All", at: 0)
        return cats
    }

    public var filteredOffices: [Office] {
        let query = officeSearchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        return offices.filter { office in
            if selectedOfficeCategory != "All" {
                let cat = office.category ?? office.department ?? ""
                if cat != selectedOfficeCategory { return false }
            }

            if !query.isEmpty {
                let matchesName = office.name.lowercased().contains(query)
                let matchesDept = (office.department ?? "").lowercased().contains(query)
                let matchesAddr = (office.address ?? "").lowercased().contains(query)
                let matchesPhone = (office.phone ?? "").contains(query)
                let matchesStaff = (office.staff ?? []).contains { staff in
                    staff.name.lowercased().contains(query) ||
                    staff.designation.lowercased().contains(query) ||
                    staff.phone.contains(query)
                }

                if !matchesName && !matchesDept && !matchesAddr && !matchesPhone && !matchesStaff {
                    return false
                }
            }

            return true
        }
    }

    // MARK: - Broadcast
    public var activeBroadcast: BroadcastNotice? {
        guard let first = broadcasts.first, first.id != dismissBroadcastId else { return nil }
        return first
    }

    public func dismissCurrentBroadcast() {
        if let current = activeBroadcast {
            dismissBroadcastId = current.id
        }
    }

    // MARK: - Direct Native Actions
    public func makePhoneCall(number: String) {
        let clean = number.filter { $0.isNumber }
        guard let url = URL(string: "tel://\(clean)"), UIApplication.shared.canOpenURL(url) else {
            showToast("Cannot place call from this device")
            return
        }
        UIApplication.shared.open(url)
    }

    public func openWhatsApp(number: String, contactName: String = "", contextName: String = "") {
        let clean = number.filter { $0.isNumber }
        let waNumber = clean.hasPrefix("91") ? clean : "91\(clean)"
        let greeting = "Chibai \(contactName) (\(contextName)), khawngaih in ka be thei che angem."
        let encodedText = greeting.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""

        if let waURL = URL(string: "whatsapp://send?phone=\(waNumber)&text=\(encodedText)"),
           UIApplication.shared.canOpenURL(waURL) {
            UIApplication.shared.open(waURL)
        } else if let webURL = URL(string: "https://wa.me/\(waNumber)?text=\(encodedText)") {
            UIApplication.shared.open(webURL)
        }
    }

    public func copyToClipboard(text: String, label: String = "number") {
        UIPasteboard.general.string = text
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        showToast("📋 Copied \(label): \(text)")
    }

    public func showToast(_ msg: String) {
        toastMessage = msg
        Task {
            try? await Task.sleep(nanoseconds: 2_500_000_000)
            if toastMessage == msg {
                toastMessage = nil
            }
        }
    }

    // MARK: - Real-Time Server Push Engine
    private func setupRealtimeSync() {
        RealtimeSyncService.shared.eventSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                self?.handleRealtimeEvent(event)
            }
            .store(in: &cancellables)

        RealtimeSyncService.shared.start()
    }

    private func handleRealtimeEvent(_ event: RealtimeEvent) {
        switch event {
        case .connected:
            self.isLiveConnected = true
            self.isOffline = false
            self.syncStatusMessage = "⚡ Live Synced (\(selectedDistrict))"

        case .ping:
            self.isLiveConnected = true

        case .contactAdded(let contact):
            if contact.district == nil || contact.district == selectedDistrict {
                contacts.removeAll { $0.id == contact.id }
                contacts.insert(contact, at: 0)
                cache.save(contacts, forKey: "contacts_\(selectedDistrict)")
                showToast("⚡ New contact added: \(contact.name)")
            }

        case .contactUpdated(let contact):
            if let idx = contacts.firstIndex(where: { $0.id == contact.id }) {
                contacts[idx] = contact
                cache.save(contacts, forKey: "contacts_\(selectedDistrict)")
            }
            if let favIdx = favoriteContacts.firstIndex(where: { $0.id == contact.id }) {
                favoriteContacts[favIdx] = contact
                cache.save(favoriteContacts, forKey: "favorite_contacts")
            }
            showToast("⚡ Live updated: \(contact.name)")

        case .contactDeleted(let id):
            contacts.removeAll { $0.id == id }
            cache.save(contacts, forKey: "contacts_\(selectedDistrict)")

        case .villageAdded(let village):
            if village.district == nil || village.district == selectedDistrict {
                villages.removeAll { $0.id == village.id }
                villages.append(village)
                cache.save(villages, forKey: "villages_\(selectedDistrict)")
            }

        case .villageDeleted(let id):
            villages.removeAll { $0.id == id }
            cache.save(villages, forKey: "villages_\(selectedDistrict)")

        case .emergencyAdded(let em), .emergencyUpdated(let em):
            if em.district == nil || em.district == selectedDistrict {
                emergency.removeAll { $0.id == em.id }
                emergency.append(em)
                cache.save(emergency, forKey: "emergency_\(selectedDistrict)")
            }

        case .emergencyDeleted(let id):
            emergency.removeAll { $0.id == id }
            cache.save(emergency, forKey: "emergency_\(selectedDistrict)")

        case .officeAdded(let off), .officeUpdated(let off):
            if off.district == nil || off.district == selectedDistrict {
                offices.removeAll { $0.id == off.id }
                offices.append(off)
                cache.save(offices, forKey: "offices_\(selectedDistrict)")
            }

        case .officeDeleted(let id):
            offices.removeAll { $0.id == id }
            cache.save(offices, forKey: "offices_\(selectedDistrict)")

        case .broadcastReceived(let bcast):
            if bcast.district == nil || bcast.district == selectedDistrict || bcast.district == "All" {
                broadcasts.removeAll { $0.id == bcast.id }
                broadcasts.insert(bcast, at: 0)
                cache.save(broadcasts, forKey: "broadcasts_\(selectedDistrict)")
                UINotificationFeedbackGenerator().notificationOccurred(.warning)
                showToast("📢 New Notice: \(bcast.title)")
            }

        case .broadcastDeleted(let id):
            broadcasts.removeAll { $0.id == id }
            cache.save(broadcasts, forKey: "broadcasts_\(selectedDistrict)")

        case .fullSyncRequired:
            Task {
                await fetchFreshData()
            }

        case .disconnected:
            self.isLiveConnected = false
            if isOffline {
                self.syncStatusMessage = contacts.isEmpty ? "Offline (No cached data)" : "Offline Mode (\(contacts.count) Contacts)"
            }
        }
    }
}
