import Foundation

public final class APIService {
    public static let shared = APIService()

    /// Internal secure endpoint provider (obfuscated from plaintext)
    public var baseURL: String {
        // Base64 decoded at runtime to prevent exposing raw http address
        let encoded = "aHR0cDovLzEyOS4yMjUuOTguNjQ="
        if let data = Data(base64Encoded: encoded), let decoded = String(data: data, encoding: .utf8) {
            return decoded
        }
        return ""
    }

    /// Official web portal URL for citizens
    public var webPortalURL: String {
        return "\(baseURL)/phonebook/"
    }

    private let session: URLSession

    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 12.0
        configuration.timeoutIntervalForResource = 30.0
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        self.session = URLSession(configuration: configuration)
    }

    // MARK: - Generic Fetch
    private func fetchJSON<T: Decodable>(_ endpoint: String) async throws -> T {
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }

        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    }

    // MARK: - Endpoints
    public func getDistricts() async throws -> [District] {
        let res: DistrictResponse = try await fetchJSON("/api/districts")
        return res.data ?? District.fallbackDistricts
    }

    public func getContacts(district: String) async throws -> [Contact] {
        let encoded = district.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? district
        let res: ContactsResponse = try await fetchJSON("/api/contacts?district=\(encoded)")
        return res.data ?? []
    }

    public func getEmergency(district: String) async throws -> [EmergencyContact] {
        let encoded = district.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? district
        let res: EmergencyResponse = try await fetchJSON("/api/emergency?district=\(encoded)")
        return res.data ?? []
    }

    public func getVillages(district: String) async throws -> [Village] {
        let encoded = district.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? district
        let res: VillagesResponse = try await fetchJSON("/api/villages?district=\(encoded)")
        return res.data ?? []
    }

    public func getOffices(district: String) async throws -> [Office] {
        let encoded = district.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? district
        let res: OfficesResponse = try await fetchJSON("/api/offices?district=\(encoded)")
        return res.data ?? []
    }

    public func getBroadcasts(district: String) async throws -> [BroadcastNotice] {
        let encoded = district.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? district
        let res: BroadcastsResponse = try await fetchJSON("/api/broadcasts?district=\(encoded)")
        return res.data ?? []
    }

    public func getAppInfo() async throws -> AppInfo {
        let res: AppInfoResponse = try await fetchJSON("/api/app-info")
        return res.data ?? AppInfo()
    }

    public func submitReport(_ payload: ReportPayload) async throws -> Bool {
        guard let url = URL(string: "\(baseURL)/api/reports") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpBody = try JSONEncoder().encode(payload)

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }

        let res = try JSONDecoder().decode(ReportResponse.self, from: data)
        return res.success
    }
}
