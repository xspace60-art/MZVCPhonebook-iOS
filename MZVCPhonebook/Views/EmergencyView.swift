import SwiftUI

public struct EmergencyView: View {
    @EnvironmentObject private var store: PhonebookStore
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 14) {
                    // Emergency Header Banner
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 8) {
                            Image(systemName: "cross.case.fill")
                                .font(.system(size: 22))
                                .foregroundColor(.red)
                            Text("\(store.selectedDistrict) Emergency Services")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                        }

                        Text("Toll-free helplines, administration, police & hospital contacts")
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.85))
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.red.opacity(0.85), Color.orange.opacity(0.85)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal, 16)

                    // Emergency Contacts List
                    if horizontalSizeClass == .regular {
                        LazyVGrid(columns: [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)], spacing: 14) {
                            ForEach(store.emergency) { em in
                                emergencyCard(em)
                            }
                        }
                        .padding(.horizontal, 24)
                    } else {
                        LazyVStack(spacing: 12) {
                            ForEach(store.emergency) { em in
                                emergencyCard(em)
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }
                .padding(.bottom, 24)
                .frame(maxWidth: horizontalSizeClass == .regular ? 1100 : .infinity)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Emergency")
            .navigationBarTitleDisplayMode(.inline)
            .refreshable {
                await store.fetchFreshData()
            }
        }
    }

    private func emergencyCard(_ em: EmergencyContact) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(em.service)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.primary)

                    if let officer = em.officer, !officer.isEmpty {
                        HStack(spacing: 4) {
                            Image(systemName: "person.badge.shield.checkmark.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                            Text(officer)
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)
                        }
                    }

                    if let addr = em.address, !addr.isEmpty {
                        HStack(spacing: 4) {
                            Image(systemName: "mappin.circle.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                            Text(addr)
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                    }
                }

                Spacer()

                // Emergency Call Button
                Button {
                    store.makePhoneCall(number: em.cleanPhone)
                } label: {
                    Image(systemName: "phone.fill")
                        .font(.system(size: 18))
                        .frame(width: 48, height: 48)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                        .shadow(color: Color.red.opacity(0.3), radius: 6, x: 0, y: 3)
                }
            }

            // Phone display line
            HStack(spacing: 8) {
                Image(systemName: "phone.fill")
                    .font(.system(size: 12))
                    .foregroundColor(.red)
                Text(em.phone)
                    .font(.system(size: 15, weight: .bold, design: .monospaced))
                    .foregroundColor(.primary)

                if let alt = em.altPhone, !alt.isEmpty {
                    Text("/ \(alt)")
                        .font(.system(size: 13, design: .monospaced))
                        .foregroundColor(.secondary)
                }

                Spacer()

                // Report incorrect number button
                Button {
                    store.reportTargetEmergency = em
                    store.isReportSheetPresented = true
                } label: {
                    HStack(spacing: 3) {
                        Image(systemName: "exclamationmark.triangle")
                        Text("Report")
                    }
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.orange)
                }
            }
        }
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
    }
}
