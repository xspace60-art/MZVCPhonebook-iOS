import Foundation

public struct EmergencyContact: Identifiable, Codable, Hashable {
    public let id: String
    public let service: String
    public let category: String?
    public let officer: String?
    public let phone: String
    public let altPhone: String?
    public let address: String?
    public let priority: Int?
    public let district: String?

    public init(
        id: String,
        service: String,
        category: String? = nil,
        officer: String? = nil,
        phone: String,
        altPhone: String? = nil,
        address: String? = nil,
        priority: Int? = 1,
        district: String? = nil
    ) {
        self.id = id
        self.service = service
        self.category = category
        self.officer = officer
        self.phone = phone
        self.altPhone = altPhone
        self.address = address
        self.priority = priority
        self.district = district
    }

    public var cleanPhone: String {
        phone.filter { $0.isNumber }
    }

    public var cleanAltPhone: String {
        (altPhone ?? "").filter { $0.isNumber }
    }
}

public struct EmergencyResponse: Codable {
    public let success: Bool
    public let count: Int?
    public let data: [EmergencyContact]?
}
