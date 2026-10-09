import Foundation

public struct Village: Identifiable, Codable, Hashable {
    public let id: String
    public let name: String
    public let category: String?
    public let district: String?
    public let type: String?
    public let totalMembers: Int?
    public let address: String?

    public init(
        id: String,
        name: String,
        category: String? = nil,
        district: String? = nil,
        type: String? = "Village Council",
        totalMembers: Int? = 0,
        address: String? = nil
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.district = district
        self.type = type
        self.totalMembers = totalMembers
        self.address = address
    }
}

public struct VillagesResponse: Codable {
    public let success: Bool
    public let count: Int?
    public let data: [Village]?
}
