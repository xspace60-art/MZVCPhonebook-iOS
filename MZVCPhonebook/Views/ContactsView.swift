import SwiftUI

public struct ContactsView: View {
    @EnvironmentObject private var store: PhonebookStore
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    public var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                ScrollView {
                    VStack(spacing: 14) {
                        // District Banner / Header Top Bar
                        headerBar

                        // Active Announcement Banner
                        if let broadcast = store.activeBroadcast {
                            announcementBanner(broadcast)
                        }

                        // Directory vs Saved Scope Switcher
                        directoryScopeSelector

                        // Search Bar
                        searchBar

                        // Category Filter Chips
                        categoryChips

                        // Role Filter & Counter Row
                        roleFilterRow

                        // Contacts List
                        if store.filteredContacts.isEmpty {
                            emptyStateView
                        } else if horizontalSizeClass == .regular {
                            LazyVGrid(columns: [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)], spacing: 14) {
                                ForEach(store.filteredContacts) { contact in
                                    ContactCardView(contact: contact)
                                }
                            }
                            .padding(.horizontal, 24)
                        } else {
                            LazyVStack(spacing: 12) {
                                ForEach(store.filteredContacts) { contact in
                                    ContactCardView(contact: contact)
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                    }
                    .padding(.bottom, 24)
                    .frame(maxWidth: horizontalSizeClass == .regular ? 1100 : .infinity)
                }
                .background(Color(.systemGroupedBackground))
                .refreshable {
                    await store.fetchFreshData()
                }

                // In-App Toast
                if let toast = store.toastMessage {
                    toastView(toast)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .padding(.bottom, 16)
                }
            }
            .navigationTitle(store.showOnlyFavorites ? "Saved Favorites" : "\(store.selectedDistrict) VC Phonebook")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        store.isDistrictPickerPresented = true
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "location.fill")
                                .font(.system(size: 12))
                            Text(store.selectedDistrict)
                                .font(.system(size: 14, weight: .bold))
                            Image(systemName: "chevron.down")
                                .font(.system(size: 9, weight: .bold))
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.accentColor.opacity(0.12))
                        .foregroundColor(.accentColor)
                        .clipShape(Capsule())
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 12) {
                        // Favorites Quick Toggle
                        Button {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                                store.showOnlyFavorites.toggle()
                            }
                        } label: {
                            ZStack(alignment: .topTrailing) {
                                Image(systemName: store.showOnlyFavorites ? "star.fill" : "star")
                                    .font(.system(size: 17))
                                    .foregroundColor(store.showOnlyFavorites ? .yellow : .primary)

                                if !store.favoriteContacts.isEmpty {
                                    Text("\(store.favoriteContacts.count)")
                                        .font(.system(size: 9, weight: .bold))
                                        .foregroundColor(.white)
                                        .frame(width: 14, height: 14)
                                        .background(Color.yellow.opacity(0.95))
                                        .clipShape(Circle())
                                        .offset(x: 6, y: -6)
                                }
                            }
                        }

                        // Notification Bell
                        Button {
                            store.isNotificationHistoryPresented = true
                        } label: {
                            ZStack(alignment: .topTrailing) {
                                Image(systemName: "bell.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(.primary)

                                if !store.broadcasts.isEmpty {
                                    Text("\(store.broadcasts.count)")
                                        .font(.system(size: 9, weight: .bold))
                                        .foregroundColor(.white)
                                        .frame(width: 15, height: 15)
                                        .background(Color.red)
                                        .clipShape(Circle())
                                        .offset(x: 6, y: -6)
                                }
                            }
                        }
                    }
                }
            }
            .sheet(isPresented: $store.isDistrictPickerPresented) {
                DistrictPickerSheet()
            }
            .sheet(isPresented: $store.isNotificationHistoryPresented) {
                NotificationHistorySheet()
            }
            .sheet(isPresented: $store.isReportSheetPresented) {
                ReportCorrectionSheet()
            }
        }
    }

    // MARK: - Header Bar
    private var headerBar: some View {
        HStack {
            HStack(spacing: 6) {
                Circle()
                    .fill(store.isLiveConnected ? Color.green : (store.isOffline ? Color.orange : Color.blue))
                    .frame(width: 8, height: 8)
                Text(store.syncStatusMessage)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
            }

            Spacer()

            if store.isLiveConnected {
                HStack(spacing: 4) {
                    Image(systemName: "bolt.horizontal.fill")
                        .font(.system(size: 9))
                    Text("LIVE PUSH")
                        .font(.system(size: 10, weight: .bold))
                }
                .foregroundColor(.green)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Color.green.opacity(0.12))
                .clipShape(Capsule())
            } else {
                Text("Village Council Directory")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 4)
    }

    // MARK: - Announcement Banner
    private func announcementBanner(_ bcast: BroadcastNotice) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: bcast.isUrgent ? "exclamationmark.triangle.fill" : "megaphone.fill")
                .font(.system(size: 18))
                .foregroundColor(bcast.isUrgent ? .red : .blue)
                .padding(.top, 2)

            VStack(alignment: .leading, spacing: 4) {
                Text(bcast.title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.primary)
                Text(bcast.message)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .lineLimit(2)

                Button {
                    store.isNotificationHistoryPresented = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "clock.arrow.circlepath")
                        Text("View History")
                    }
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.accentColor)
                }
                .padding(.top, 2)
            }

            Spacer()

            Button {
                store.dismissCurrentBroadcast()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.secondary)
                    .padding(4)
            }
        }
        .padding(12)
        .background(bcast.isUrgent ? Color.red.opacity(0.1) : Color.blue.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(bcast.isUrgent ? Color.red.opacity(0.3) : Color.blue.opacity(0.3), lineWidth: 1)
        )
        .padding(.horizontal, 16)
    }

    // MARK: - Scope Selector (All Directory vs Saved)
    private var directoryScopeSelector: some View {
        HStack(spacing: 8) {
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                    store.showOnlyFavorites = false
                }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "person.2.fill")
                        .font(.system(size: 12))
                    Text("All Directory")
                        .font(.system(size: 13, weight: !store.showOnlyFavorites ? .bold : .medium))
                    Text("(\(store.contacts.count))")
                        .font(.system(size: 11, weight: .semibold))
                        .opacity(0.8)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(!store.showOnlyFavorites ? Color.accentColor : Color(.secondarySystemGroupedBackground))
                .foregroundColor(!store.showOnlyFavorites ? .white : .primary)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }

            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                    store.showOnlyFavorites = true
                }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: store.showOnlyFavorites ? "star.fill" : "star")
                        .font(.system(size: 12))
                        .foregroundColor(store.showOnlyFavorites ? .yellow : .orange)
                    Text("Saved")
                        .font(.system(size: 13, weight: store.showOnlyFavorites ? .bold : .medium))
                    Text("(\(store.favoriteContacts.count))")
                        .font(.system(size: 11, weight: .semibold))
                        .opacity(0.8)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(store.showOnlyFavorites ? Color.accentColor : Color(.secondarySystemGroupedBackground))
                .foregroundColor(store.showOnlyFavorites ? .white : .primary)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        .padding(.horizontal, 16)
    }

    // MARK: - Search Bar
    private var searchBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            TextField("Search name, village, role, phone...", text: $store.contactSearchText)
                .font(.system(size: 14))

            if !store.contactSearchText.isEmpty {
                Button {
                    store.contactSearchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal, 16)
    }

    // MARK: - Category Chips
    private var categoryChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(store.uniqueCategories, id: \.self) { cat in
                    let isSelected = store.selectedCategory == cat

                    Button {
                        store.selectedCategory = cat
                    } label: {
                        Text(cat == "All" ? "All VCs" : cat)
                            .font(.system(size: 13, weight: isSelected ? .bold : .medium))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 7)
                            .background(isSelected ? Color.accentColor : Color(.secondarySystemGroupedBackground))
                            .foregroundColor(isSelected ? .white : .primary)
                            .clipShape(Capsule())
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }

    // MARK: - Role Filter & Counter Row
    private var roleFilterRow: some View {
        HStack {
            Menu {
                Button("All Designations") { store.selectedRole = "All" }
                Button("VCP (President) / Chairman") { store.selectedRole = "President" }
                Button("VCVP (Vice President)") { store.selectedRole = "Vice President" }
                Button("VCS (Secretary)") { store.selectedRole = "Secretary" }
                Button("Treasurer (VCT / LCT)") { store.selectedRole = "Treasurer" }
                Button("Member (VCM)") { store.selectedRole = "Member" }
                Button("Worker (VLW)") { store.selectedRole = "Worker" }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                    Text(roleMenuTitle)
                        .font(.system(size: 13, weight: .semibold))
                    Image(systemName: "chevron.down")
                        .font(.system(size: 10))
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color(.secondarySystemGroupedBackground))
                .foregroundColor(.primary)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }

            Spacer()

            Text("\(store.filteredContacts.count) Contacts")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 16)
    }

    private var roleMenuTitle: String {
        switch store.selectedRole {
        case "President": return "VCP / Chairman"
        case "Vice President": return "VCVP"
        case "Secretary": return "Secretary"
        case "Treasurer": return "Treasurer"
        case "Member": return "Member"
        case "Worker": return "Worker"
        default: return "All Designations"
        }
    }

    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 12) {
            if store.showOnlyFavorites && store.favoriteContacts.isEmpty {
                Image(systemName: "star.slash")
                    .font(.system(size: 46))
                    .foregroundColor(.yellow)
                    .padding(.top, 32)
                Text("No Saved Contacts Yet")
                    .font(.headline)
                Text("Tap the star icon ⭐ on any Village Council member to save them here for instant 1-tap offline access.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                        store.showOnlyFavorites = false
                    }
                } label: {
                    Text("Browse Directory")
                        .font(.system(size: 14, weight: .semibold))
                        .padding(.horizontal, 18)
                        .padding(.vertical, 9)
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .padding(.top, 4)
            } else {
                Image(systemName: "person.crop.circle.badge.questionmark")
                    .font(.system(size: 44))
                    .foregroundColor(.secondary)
                    .padding(.top, 32)
                Text("No Contacts Found")
                    .font(.headline)
                Text(store.showOnlyFavorites ? "No saved contacts match your search." : "Try searching for a different name, village or designation.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                Button {
                    store.contactSearchText = ""
                    store.selectedCategory = "All"
                    store.selectedRole = "All"
                } label: {
                    Text("Reset Search")
                        .font(.system(size: 14, weight: .semibold))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.accentColor.opacity(0.12))
                        .foregroundColor(.accentColor)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .padding(.top, 4)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
    }

    // MARK: - Toast
    private func toastView(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 13, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color.black.opacity(0.85))
            .clipShape(Capsule())
            .shadow(radius: 6)
    }
}
