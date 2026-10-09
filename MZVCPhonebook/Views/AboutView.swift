import SwiftUI

public struct AboutView: View {
    @EnvironmentObject private var store: PhonebookStore

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // App Identity Card
                    VStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(Color.accentColor.opacity(0.12))
                                .frame(width: 72, height: 72)
                            Image(systemName: "building.columns.fill")
                                .font(.system(size: 34))
                                .foregroundColor(.accentColor)
                        }

                        Text("MZ VC Phonebook")
                            .font(.system(size: 22, weight: .bold, design: .rounded))

                        Text("Village Council Directory • Mizoram")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.secondary)

                        Text("Version 2.4.0 (2026 Edition)")
                            .font(.system(size: 11, weight: .semibold))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color(.systemGray5))
                            .foregroundColor(.secondary)
                            .clipShape(Capsule())
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)

                    // Description Box
                    VStack(alignment: .leading, spacing: 8) {
                        Text("About Directory")
                            .font(.system(size: 15, weight: .bold))

                        Text("Official digital telephone directory of Village Councils & Local Councils across Mizoram. Enables direct communication between residents, district officials, and village administration.")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                            .lineSpacing(3)
                    }
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 14))

                    // Feature: 100% Offline Access
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "arrow.down.circle.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.green)
                            .padding(.top, 2)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("100% Offline Access")
                                .font(.system(size: 14, weight: .bold))
                            Text("Contacts, emergency numbers, and offices are automatically cached locally on your iPhone. Works seamlessly without an active internet connection.")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 14))

                    // Feature: Saved Favorites
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "star.circle.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.yellow)
                            .padding(.top, 2)

                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text("Saved Favorites")
                                    .font(.system(size: 14, weight: .bold))
                                Spacer()
                                Text("\(store.favoriteContacts.count) saved")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(.secondary)
                            }
                            Text("Bookmark important Village Council leaders for immediate 1-tap calling across all districts without searching.")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 14))

                    // Feature: Live Sync & Real-Time Push
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: store.isLiveConnected ? "bolt.badge.clock.fill" : "bolt.fill")
                            .font(.system(size: 22))
                            .foregroundColor(store.isLiveConnected ? .green : .blue)
                            .padding(.top, 2)

                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text("Real-Time Push Engine")
                                    .font(.system(size: 14, weight: .bold))
                                Spacer()
                                Text(store.isLiveConnected ? "🟢 Active Push" : "Connecting")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundColor(store.isLiveConnected ? .green : .secondary)
                            }
                            Text("Connected to Oracle Cloud SSE push engine. Administrative updates, new appointments, and district notices stream directly to your device without manual refresh.")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 14))

                    // Developer & Support Info Card
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 8) {
                            Image(systemName: "person.crop.circle.badge.checkmark")
                                .font(.system(size: 16))
                                .foregroundColor(.accentColor)
                            Text("Developer & Support")
                                .font(.system(size: 15, weight: .bold))
                        }

                        Divider()

                        // Developer Name
                        HStack {
                            Text("Author / Developer:")
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(store.appInfo.developerName ?? "K Vanlalrengpuia")
                                .font(.system(size: 13, weight: .bold))
                        }

                        // Email
                        if let email = store.appInfo.developerEmail, !email.isEmpty {
                            HStack {
                                Text("Email:")
                                    .font(.system(size: 13))
                                    .foregroundColor(.secondary)
                                Spacer()
                                Link(email, destination: URL(string: "mailto:\(email)")!)
                                    .font(.system(size: 13, weight: .semibold))
                            }
                        }

                        // Support Phone
                        if let phone = store.appInfo.supportPhone, !phone.isEmpty {
                            HStack {
                                Text("Support Phone:")
                                    .font(.system(size: 13))
                                    .foregroundColor(.secondary)
                                Spacer()
                                Button(phone) {
                                    store.makePhoneCall(number: phone)
                                }
                                .font(.system(size: 13, weight: .semibold))
                            }
                        }

                        // State & Governance
                        HStack {
                            Text("Jurisdiction:")
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("Government of Mizoram")
                                .font(.system(size: 13, weight: .semibold))
                        }
                    }
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .padding(16)
                .padding(.bottom, 24)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
