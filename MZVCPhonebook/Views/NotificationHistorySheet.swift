import SwiftUI

public struct NotificationHistorySheet: View {
    @EnvironmentObject private var store: PhonebookStore
    @Environment(\.dismiss) private var dismiss

    public var body: some View {
        NavigationStack {
            Group {
                if store.broadcasts.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "bell.slash")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)
                        Text("No Announcements")
                            .font(.headline)
                        Text("Official district announcements and alerts for \(store.selectedDistrict) will appear here.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(store.broadcasts) { bcast in
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    HStack(spacing: 4) {
                                        Image(systemName: bcast.isUrgent ? "exclamationmark.triangle.fill" : "megaphone.fill")
                                        Text(bcast.isUrgent ? "Urgent Alert" : "Notice")
                                            .fontWeight(.bold)
                                    }
                                    .font(.system(size: 11))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .background(bcast.isUrgent ? Color.red.opacity(0.15) : Color.blue.opacity(0.15))
                                    .foregroundColor(bcast.isUrgent ? .red : .blue)
                                    .clipShape(Capsule())

                                    if let dist = bcast.district, !dist.isEmpty {
                                        Text(dist)
                                            .font(.system(size: 11, weight: .semibold))
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(Color(.systemGray5))
                                            .foregroundColor(.secondary)
                                            .clipShape(RoundedRectangle(cornerRadius: 4))
                                    }

                                    Spacer()

                                    Text(bcast.formattedDate)
                                        .font(.system(size: 11))
                                        .foregroundColor(.secondary)
                                }

                                Text(bcast.title)
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.primary)

                                Text(bcast.message)
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                                    .lineSpacing(3)
                            }
                            .padding(.vertical, 6)
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Notification History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}
