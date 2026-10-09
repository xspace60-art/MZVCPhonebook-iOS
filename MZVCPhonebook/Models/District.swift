import Foundation

public struct District: Identifiable, Codable, Hashable {
    public let id: String
    public let name: String
    public let code: String?
    public let headquarter: String?
    public let state: String?
    public let totalVCs: Int?

    public init(id: String, name: String, code: String? = nil, headquarter: String? = nil, state: String? = "Mizoram", totalVCs: Int? = nil) {
        self.id = id
        self.name = name
        self.code = code
        self.headquarter = headquarter
        self.state = state
        self.totalVCs = totalVCs
    }

    public static let fallbackDistricts: [District] = [
        District(id: "dist-kolasib", name: "Kolasib", code: "KLB", headquarter: "Kolasib", totalVCs: 60),
        District(id: "dist-aizawl", name: "Aizawl", code: "AZL", headquarter: "Aizawl", totalVCs: 85),
        District(id: "dist-lunglei", name: "Lunglei", code: "LGL", headquarter: "Lunglei", totalVCs: 72),
        District(id: "dist-champhai", name: "Champhai", code: "CMP", headquarter: "Champhai", totalVCs: 62),
        District(id: "dist-mamit", name: "Mamit", code: "MMT", headquarter: "Mamit", totalVCs: 52),
        District(id: "dist-serchhip", name: "Serchhip", code: "SCP", headquarter: "Serchhip", totalVCs: 56),
        District(id: "dist-saitual", name: "Saitual", code: "STL", headquarter: "Saitual", totalVCs: 46),
        District(id: "dist-khawzawl", name: "Khawzawl", code: "KZL", headquarter: "Khawzawl", totalVCs: 28),
        District(id: "dist-hnahthial", name: "Hnahthial", code: "HNT", headquarter: "Hnahthial", totalVCs: 26),
        District(id: "dist-lawngtlai", name: "Lawngtlai", code: "LWT", headquarter: "Lawngtlai", totalVCs: 55),
        District(id: "dist-siaha", name: "Siaha", code: "SIH", headquarter: "Siaha", totalVCs: 42)
    ]
}

public struct DistrictResponse: Codable {
    public let success: Bool
    public let count: Int?
    public let data: [District]?
}
