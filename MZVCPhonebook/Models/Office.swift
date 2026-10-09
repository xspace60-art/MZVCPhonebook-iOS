import Foundation

public struct StaffMember: Identifiable, Codable, Hashable {
    public let id: String
    public let name: String
    public let designation: String
    public let phone: String
    public let altPhone: String?
    public let email: String?

    public init(
        id: String,
        name: String,
        designation: String,
        phone: String,
        altPhone: String? = nil,
        email: String? = nil
    ) {
        self.id = id
        self.name = name
        self.designation = designation
        self.phone = phone
        self.altPhone = altPhone
        self.email = email
    }

    public var cleanPhone: String {
        phone.filter { $0.isNumber }
    }

    public var cleanAltPhone: String {
        (altPhone ?? "").filter { $0.isNumber }
    }

    public var formattedPhone: String {
        let digits = cleanPhone
        if digits.count == 10 {
            let index5 = digits.index(digits.startIndex, offsetBy: 5)
            return "\(digits[..<index5]) \(digits[index5...])"
        }
        return phone
    }

    public var whatsappPhone: String {
        let clean = cleanPhone
        if clean.hasPrefix("91") {
            return clean
        }
        return "91" + clean
    }

    public var initials: String {
        let parts = name.split(separator: " ")
        if parts.count >= 2 {
            let first = parts[0].prefix(1)
            let last = parts[1].prefix(1)
            return "\(first)\(last)".uppercased()
        } else if let first = parts.first {
            return String(first.prefix(2)).uppercased()
        }
        return "ST"
    }
}

public struct Office: Identifiable, Codable, Hashable {
    public let id: String
    public let name: String
    public let department: String?
    public let category: String?
    public let district: String?
    public let phone: String?
    public let email: String?
    public let address: String?
    public let staff: [StaffMember]?

    public init(
        id: String,
        name: String,
        department: String? = nil,
        category: String? = nil,
        district: String? = nil,
        phone: String? = nil,
        email: String? = nil,
        address: String? = nil,
        staff: [StaffMember]? = []
    ) {
        self.id = id
        self.name = name
        self.department = department
        self.category = category
        self.district = district
        self.phone = phone
        self.email = email
        self.address = address
        self.staff = staff
    }

    public var cleanPhone: String {
        (phone ?? "").filter { $0.isNumber }
    }
}

public struct OfficesResponse: Codable {
    public let success: Bool
    public let count: Int?
    public let data: [Office]?
}
