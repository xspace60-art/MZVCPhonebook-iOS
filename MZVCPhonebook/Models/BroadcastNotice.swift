import Foundation

public struct BroadcastNotice: Identifiable, Codable, Hashable {
    public let id: String
    public let title: String
    public let message: String
    public let priority: String?
    public let district: String?
    public let createdAt: String?

    public init(
        id: String,
        title: String,
        message: String,
        priority: String? = "normal",
        district: String? = "All",
        createdAt: String? = nil
    ) {
        self.id = id
        self.title = title
        self.message = message
        self.priority = priority
        self.district = district
        self.createdAt = createdAt
    }

    public var isUrgent: Bool {
        priority?.lowercased() == "urgent"
    }

    public var formattedDate: String {
        guard let createdAt = createdAt else { return "Recent" }
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: createdAt) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .medium
            displayFormatter.timeStyle = .short
            return displayFormatter.string(from: date)
        }
        return "Recent"
    }
}

public struct BroadcastsResponse: Codable {
    public let success: Bool
    public let count: Int?
    public let data: [BroadcastNotice]?
}
