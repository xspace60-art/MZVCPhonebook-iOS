import SwiftUI

public struct CouncilsView: View {
    @EnvironmentObject private var store: PhonebookStore
    @Binding public var selectedTab: Int

    @State private var councilSearch: String = ""

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    public var filteredVillages: [Village] {
        let q = councilSearch.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if q.isEmpty { return store.villages }
        return store.villages.filter {
            $0.name.lowercased().contains(q) ||
            ($0.category ?? "").lowercased().contains(q)
        }
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Header card
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Image(systemName: "building.columns.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.accentColor)
                            Text("\(store.selectedDistrict) Village Councils")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                        }

                        Text("Tap any Village Council to view executive committee members.")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                    }
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 14))

                    // Search
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        TextField("Search village council...", text: $councilSearch)
                            .font(.system(size: 14))

                        if !councilSearch.isEmpty {
                            Button {
                                councilSearch = ""
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

                    // Village Cards Grid
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(filteredVillages) { village in
                            Button {
                                // Filter contacts by this village and switch to Directory tab
                                store.contactSearchText = village.name
                                store.showOnlyFavorites = false
                                selectedTab = 0
                            } label: {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Image(systemName: "house.fill")
                                            .font(.system(size: 13))
                                            .foregroundColor(.accentColor)
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 11, weight: .bold))
                                            .foregroundColor(.secondary)
                                    }

                                    Text(village.name)
                                        .font(.system(size: 15, weight: .bold))
                                        .foregroundColor(.primary)
                                        .multilineTextAlignment(.leading)

                                    if let cat = village.category, !cat.isEmpty {
                                        Text(cat)
                                            .font(.system(size: 11, weight: .semibold))
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(Color.accentColor.opacity(0.1))
                                            .foregroundColor(.accentColor)
                                            .clipShape(RoundedRectangle(cornerRadius: 4))
                                    }

                                    if let members = village.totalMembers, members > 0 {
                                        Text("\(members) Members")
                                            .font(.system(size: 11))
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .padding(12)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(.secondarySystemGroupedBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                                .shadow(color: Color.black.opacity(0.03), radius: 4, x: 0, y: 2)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(16)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Village Councils (\(store.villages.count))")
            .navigationBarTitleDisplayMode(.inline)
            .refreshable {
                await store.fetchFreshData()
            }
        }
    }
}
