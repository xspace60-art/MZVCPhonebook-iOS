import SwiftUI

public struct OfficesView: View {
    @EnvironmentObject private var store: PhonebookStore
    @State private var expandedOfficeIds: Set<String> = []

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 14) {
                    // Header Banner
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Image(systemName: "building.2.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.blue)
                            Text("Government & District Offices")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                        }
                        Text("DC Office, Police, Line Departments & Staff Directory")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .padding(.horizontal, 16)

                    // Office Search Bar
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        TextField("Search offices, departments or officers...", text: $store.officeSearchText)
                            .font(.system(size: 14))

                        if !store.officeSearchText.isEmpty {
                            Button {
                                store.officeSearchText = ""
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

                    // Department Category Pills
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(store.uniqueOfficeCategories, id: \.self) { cat in
                                let isSelected = store.selectedOfficeCategory == cat

                                Button {
                                    store.selectedOfficeCategory = cat
                                } label: {
                                    Text(cat == "All" ? "All Offices" : cat)
                                        .font(.system(size: 13, weight: isSelected ? .bold : .medium))
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 7)
                                        .background(isSelected ? Color.blue : Color(.secondarySystemGroupedBackground))
                                        .foregroundColor(isSelected ? .white : .primary)
                                        .clipShape(Capsule())
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    }

                    // Toolbar: Count and Expand/Collapse All
                    HStack {
                        Text("\(store.filteredOffices.count) Offices")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.secondary)

                        Spacer()

                        Button("Expand All") {
                            expandedOfficeIds = Set(store.filteredOffices.map { $0.id })
                        }
                        .font(.system(size: 12, weight: .medium))

                        Text("•")
                            .foregroundColor(.secondary)

                        Button("Collapse All") {
                            expandedOfficeIds.removeAll()
                        }
                        .font(.system(size: 12, weight: .medium))
                    }
                    .padding(.horizontal, 16)

                    // Office Cards
                    if store.filteredOffices.isEmpty {
                        VStack(spacing: 8) {
                            Image(systemName: "building.slash")
                                .font(.system(size: 40))
                                .foregroundColor(.secondary)
                                .padding(.top, 24)
                            Text("No Offices Found")
                                .font(.headline)
                            Text("Try searching for a different office or officer name.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 24)
                    } else {
                        LazyVStack(spacing: 14) {
                            ForEach(store.filteredOffices) { office in
                                officeCard(office)
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }
                .padding(.bottom, 24)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("\(store.selectedDistrict) Offices")
            .navigationBarTitleDisplayMode(.inline)
            .refreshable {
                await store.fetchFreshData()
            }
        }
    }

    // MARK: - Office Card
    private func officeCard(_ office: Office) -> some View {
        let isExpanded = expandedOfficeIds.contains(office.id)
        let staffList = office.staff ?? []

        return VStack(alignment: .leading, spacing: 12) {
            // Office Top
            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(office.name)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.primary)

                        if let dept = office.department, !dept.isEmpty {
                            Text(dept)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                    }

                    Spacer()

                    if let cat = office.category, !cat.isEmpty {
                        Text(cat)
                            .font(.system(size: 11, weight: .semibold))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color.blue.opacity(0.12))
                            .foregroundColor(.blue)
                            .clipShape(Capsule())
                    }
                }

                // Address & Office Phone
                if let addr = office.address, !addr.isEmpty {
                    HStack(spacing: 6) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                        Text(addr)
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                }

                if let phone = office.phone, !phone.isEmpty {
                    HStack(spacing: 6) {
                        Image(systemName: "phone.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.accentColor)
                        Text("Office: \(phone)")
                            .font(.system(size: 13, weight: .semibold, design: .monospaced))
                            .foregroundColor(.primary)

                        Spacer()

                        Button {
                            store.makePhoneCall(number: office.cleanPhone)
                        } label: {
                            Image(systemName: "phone.fill")
                                .font(.system(size: 11))
                                .padding(6)
                                .background(Color.green)
                                .foregroundColor(.white)
                                .clipShape(Circle())
                        }
                    }
                }
            }

            // Staff Toggle Header
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    if isExpanded {
                        expandedOfficeIds.remove(office.id)
                    } else {
                        expandedOfficeIds.insert(office.id)
                    }
                }
            } label: {
                HStack {
                    Image(systemName: "person.2.fill")
                        .font(.system(size: 13))
                        .foregroundColor(.blue)
                    Text("Staff Directory (\(staffList.count))")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.primary)
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .buttonStyle(.plain)

            // Staff Directory Accordion
            if isExpanded {
                if staffList.isEmpty {
                    Text("No staff directory entries listed yet.")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .padding(.vertical, 6)
                } else {
                    VStack(spacing: 10) {
                        ForEach(staffList) { staff in
                            staffRow(staff, in: office)
                        }
                    }
                    .padding(.top, 4)
                }
            }
        }
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
    }

    // MARK: - Staff Row
    private func staffRow(_ staff: StaffMember, in office: Office) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 10) {
                // Initials Avatar
                Text(staff.initials)
                    .font(.system(size: 12, weight: .bold))
                    .frame(width: 34, height: 34)
                    .background(Color.blue.opacity(0.12))
                    .foregroundColor(.blue)
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 3) {
                    Text(staff.name)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.primary)

                    Text(staff.designation)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.blue)

                    HStack(spacing: 6) {
                        Image(systemName: "phone.fill")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                        Text(staff.formattedPhone)
                            .font(.system(size: 13, weight: .medium, design: .monospaced))
                            .foregroundColor(.primary)

                        if let alt = staff.altPhone, !alt.isEmpty {
                            Text("/ \(alt)")
                                .font(.system(size: 12, design: .monospaced))
                                .foregroundColor(.secondary)
                        }
                    }
                }

                Spacer()
            }

            // Action row
            HStack(spacing: 8) {
                Button {
                    store.makePhoneCall(number: staff.cleanPhone)
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "phone.fill")
                        Text("Call")
                    }
                    .font(.system(size: 12, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }

                Button {
                    store.openWhatsApp(
                        number: staff.cleanPhone,
                        contactName: staff.name,
                        contextName: "\(office.name) \(staff.designation)"
                    )
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "message.fill")
                        Text("WhatsApp")
                    }
                    .font(.system(size: 12, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
                    .background(Color(red: 0.1, green: 0.7, blue: 0.4))
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }

                Button {
                    store.copyToClipboard(text: staff.cleanPhone, label: staff.name)
                } label: {
                    Image(systemName: "doc.on.doc")
                        .font(.system(size: 12))
                        .padding(7)
                        .background(Color(.systemGray5))
                        .foregroundColor(.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }

                Button {
                    store.reportTargetOffice = office
                    store.reportTargetStaff = staff
                    store.isReportSheetPresented = true
                } label: {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 12))
                        .padding(7)
                        .background(Color(.systemGray5))
                        .foregroundColor(.orange)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
        }
        .padding(10)
        .background(Color(.systemGray6).opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
