import SwiftUI

public struct ContactCardView: View {
    public let contact: Contact
    @EnvironmentObject private var store: PhonebookStore

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header Row: Avatar, Name, Designation Badge
            HStack(alignment: .top, spacing: 12) {
                // Role Avatar
                ZStack {
                    Circle()
                        .fill(avatarBackgroundColor.opacity(0.15))
                        .frame(width: 44, height: 44)
                    Image(systemName: roleIconName)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(avatarBackgroundColor)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(contact.name)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)

                    HStack(spacing: 6) {
                        Text(contact.designation)
                            .font(.system(size: 12, weight: .semibold))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(badgeBackgroundColor)
                            .foregroundColor(badgeForegroundColor)
                            .clipShape(Capsule())

                        if let term = contact.term, !term.isEmpty {
                            Text(term)
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                    }
                }

                Spacer()

                // Favorite Button
                Button {
                    store.toggleFavorite(contact)
                } label: {
                    Image(systemName: store.isFavorite(contact) ? "star.fill" : "star")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(store.isFavorite(contact) ? Color.yellow : Color(.systemGray3))
                        .padding(4)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }

            // Village & Category Row
            HStack(spacing: 6) {
                Image(systemName: "mappin.and.ellipse")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                Text(contact.villageName)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.secondary)

                if let cat = contact.category, !cat.isEmpty {
                    Text("•")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                    Text(cat)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }

                if store.showOnlyFavorites, let dist = contact.district, !dist.isEmpty {
                    Spacer()
                    Text(dist)
                        .font(.system(size: 11, weight: .semibold))
                        .padding(.horizontal, 7)
                        .padding(.vertical, 2)
                        .background(Color.accentColor.opacity(0.12))
                        .foregroundColor(.accentColor)
                        .clipShape(Capsule())
                }
            }

            // Phone Number Line
            HStack(spacing: 8) {
                Image(systemName: "phone.fill")
                    .font(.system(size: 13))
                    .foregroundColor(.accentColor)
                Text(contact.formattedPhone)
                    .font(.system(size: 15, weight: .semibold, design: .monospaced))
                    .foregroundColor(.primary)

                if let alt = contact.altPhone, !alt.isEmpty {
                    Text("/ \(alt)")
                        .font(.system(size: 13, design: .monospaced))
                        .foregroundColor(.secondary)
                }
            }

            Divider()
                .padding(.vertical, 2)

            // Action Buttons Row
            HStack(spacing: 10) {
                // Call Button
                Button {
                    store.makePhoneCall(number: contact.cleanPhone)
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "phone.fill")
                        Text("Call")
                            .fontWeight(.semibold)
                    }
                    .font(.system(size: 13))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }

                // WhatsApp Button
                Button {
                    store.openWhatsApp(
                        number: contact.cleanPhone,
                        contactName: contact.name,
                        contextName: "\(contact.villageName) \(contact.designation)"
                    )
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "message.fill")
                        Text("WhatsApp")
                            .fontWeight(.semibold)
                    }
                    .font(.system(size: 13))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color(red: 0.1, green: 0.7, blue: 0.4))
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }

                // Copy Button
                Button {
                    store.copyToClipboard(text: contact.cleanPhone, label: contact.name)
                } label: {
                    Image(systemName: "doc.on.doc")
                        .font(.system(size: 14, weight: .semibold))
                        .padding(9)
                        .background(Color(.systemGray5))
                        .foregroundColor(.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }

                // Report Button
                Button {
                    store.reportTargetContact = contact
                    store.isReportSheetPresented = true
                } label: {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 14, weight: .semibold))
                        .padding(9)
                        .background(Color(.systemGray5))
                        .foregroundColor(.orange)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
        }
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
    }

    // Role-based colors & badges
    private var roleIconName: String {
        switch contact.roleBadgeName {
        case "VCP": return "person.badge.shield.checkmark.fill"
        case "VCVP": return "person.2.fill"
        case "VCS": return "doc.text.fill"
        case "Treasurer": return "indianrupeesign.circle.fill"
        default: return "person.fill"
        }
    }

    private var avatarBackgroundColor: Color {
        switch contact.roleBadgeName {
        case "VCP": return .blue
        case "VCVP": return .indigo
        case "VCS": return .teal
        case "Treasurer": return .orange
        case "Worker": return .purple
        default: return .secondary
        }
    }

    private var badgeBackgroundColor: Color {
        avatarBackgroundColor.opacity(0.12)
    }

    private var badgeForegroundColor: Color {
        avatarBackgroundColor
    }
}
