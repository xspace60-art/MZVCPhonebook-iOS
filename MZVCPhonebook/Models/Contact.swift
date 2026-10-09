import Foundation

public struct Contact: Identifiable, Codable, Hashable {
    public let id: String
    public let name: String
    public let phone: String
    public let altPhone: String?
    public let designation: String
    public let villageId: String?
    public let villageName: String
    public let district: String?
    public let category: String?
    public let term: String?
    public let notes: String?
    public let updatedAt: String?

    public init(
        id: String,
        name: String,
        phone: String,
        altPhone: String? = nil,
        designation: String,
        villageId: String? = nil,
        villageName: String,
        district: String? = nil,
        category: String? = nil,
        term: String? = nil,
        notes: String? = nil,
        updatedAt: String? = nil
    ) {
        self.id = id
        self.name = name
        self.phone = phone
        self.altPhone = altPhone
        self.designation = designation
        self.villageId = villageId
        self.villageName = villageName
        self.district = district
        self.category = category
        self.term = term
        self.notes = notes
        self.updatedAt = updatedAt
    }

    /// Formats 10-digit phone number as "XXXXX XXXXX"
    public var formattedPhone: String {
        let digits = phone.filter { $0.isNumber }
        if digits.count == 10 {
            let index5 = digits.index(digits.startIndex, offsetBy: 5)
            return "\(digits[..<index5]) \(digits[index5...])"
        }
        return phone
    }

    /// Clean phone number without spaces or symbols for dialing
    public var cleanPhone: String {
        phone.filter { $0.isNumber }
    }

    /// Indian standard WhatsApp destination number with country code 91
    public var whatsappPhone: String {
        let clean = cleanPhone
        if clean.hasPrefix("91") {
            return clean
        }
        return "91" + clean
    }

    /// Short role badge classification
    public var roleBadgeName: String {
        let lower = designation.lowercased()
        if lower.contains("president") || lower.contains("vcp") || lower.contains("chairman") {
            return "VCP"
        } else if lower.contains("vice") || lower.contains("vcvp") {
            return "VCVP"
        } else if lower.contains("secretary") || lower.contains("vcs") {
            return "VCS"
        } else if lower.contains("treasurer") || lower.contains("vct") || lower.contains("lct") {
            return "Treasurer"
        } else if lower.contains("worker") || lower.contains("vlw") {
            return "Worker"
        }
        return "Member"
    }
}

public struct ContactsResponse: Codable {
    public let success: Bool
    public let count: Int?
    public let data: [Contact]?
}
