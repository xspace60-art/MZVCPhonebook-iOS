import Foundation

public struct AppInfo: Codable, Hashable {
    public let appName: String?
    public let developerName: String?
    public let developerEmail: String?
    public let supportPhone: String?
    public let updatedAt: String?

    public init(
        appName: String? = "Mizoram VC Phonebook",
        developerName: String? = "K Vanlalrengpuia",
        developerEmail: String? = "rengakhiangte@gmail.com",
        supportPhone: String? = "8014159713",
        updatedAt: String? = nil
    ) {
        self.appName = appName
        self.developerName = developerName
        self.developerEmail = developerEmail
        self.supportPhone = supportPhone
        self.updatedAt = updatedAt
    }
}

public struct AppInfoResponse: Codable {
    public let success: Bool
    public let data: AppInfo?
}

public struct ReportPayload: Codable {
    public let contactId: String
    public let contactName: String
    public let serviceName: String
    public let villageName: String
    public let designation: String
    public let isEmergency: Bool
    public let isOffice: Bool
    public let officeName: String
    public let staffId: String?
    public let issueType: String
    public let suggestedPhone: String
    public let description: String
    public let reportedBy: String
    public let reporterPhone: String
    public let district: String

    public init(
        contactId: String,
        contactName: String,
        serviceName: String = "",
        villageName: String,
        designation: String,
        isEmergency: Bool = false,
        isOffice: Bool = false,
        officeName: String = "",
        staffId: String? = nil,
        issueType: String,
        suggestedPhone: String,
        description: String,
        reportedBy: String,
        reporterPhone: String,
        district: String
    ) {
        self.contactId = contactId
        self.contactName = contactName
        self.serviceName = serviceName.isEmpty ? contactName : serviceName
        self.villageName = villageName
        self.designation = designation
        self.isEmergency = isEmergency
        self.isOffice = isOffice
        self.officeName = officeName
        self.staffId = staffId
        self.issueType = issueType
        self.suggestedPhone = suggestedPhone
        self.description = description
        self.reportedBy = reportedBy
        self.reporterPhone = reporterPhone
        self.district = district
    }
}

public struct ReportResponse: Codable {
    public let success: Bool
    public let message: String?
    public let error: String?
}
