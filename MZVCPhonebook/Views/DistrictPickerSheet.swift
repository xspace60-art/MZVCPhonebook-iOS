import SwiftUI

public struct DistrictPickerSheet: View {
    @EnvironmentObject private var store: PhonebookStore
    @Environment(\.dismiss) private var dismiss

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Select your district in Mizoram to load Village Councils, Government Offices, and Emergency Services:")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 4)

                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(store.districts) { district in
                            let isSelected = district.name.lowercased() == store.selectedDistrict.lowercased()

                            Button {
                                store.switchDistrict(district.name)
                                dismiss()
                            } label: {
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack {
                                        Image(systemName: "location.fill")
                                            .font(.system(size: 13))
                                            .foregroundColor(isSelected ? .white : .accentColor)
                                        Text(district.name)
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundColor(isSelected ? .white : .primary)
                                        Spacer()
                                        if isSelected {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.white)
                                                .font(.system(size: 14))
                                        }
                                    }

                                    Text("HQ: \(district.headquarter ?? district.name)")
                                        .font(.system(size: 12))
                                        .foregroundColor(isSelected ? .white.opacity(0.85) : .secondary)

                                    if let count = district.totalVCs, count > 0 {
                                        Text("\(count) Village Councils")
                                            .font(.system(size: 11, weight: .medium))
                                            .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
                                    }
                                }
                                .padding(14)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(isSelected ? Color.accentColor : Color(.secondarySystemGroupedBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(isSelected ? Color.accentColor : Color(.systemGray5), lineWidth: 1)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(16)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Select District")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}
