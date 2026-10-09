import Foundation
import Combine

public enum RealtimeEvent {
    case connected(clientId: String)
    case ping
    case contactAdded(Contact)
    case contactUpdated(Contact)
    case contactDeleted(id: String)
    case villageAdded(Village)
    case villageDeleted(id: String)
    case emergencyAdded(EmergencyContact)
    case emergencyUpdated(EmergencyContact)
    case emergencyDeleted(id: String)
    case officeAdded(Office)
    case officeUpdated(Office)
    case officeDeleted(id: String)
    case broadcastReceived(BroadcastNotice)
    case broadcastDeleted(id: String)
    case fullSyncRequired
    case disconnected(error: String?)
}

public final class RealtimeSyncService {
    public static let shared = RealtimeSyncService()

    private var activeTask: Task<Void, Never>? = nil
    private var isRunning: Bool = false
    public let eventSubject = PassthroughSubject<RealtimeEvent, Never>()

    private init() {}

    public func start() {
        guard !isRunning else { return }
        isRunning = true
        activeTask = Task { [weak self] in
            await self?.runEventStreamLoop()
        }
    }

    public func stop() {
        isRunning = false
        activeTask?.cancel()
        activeTask = nil
        eventSubject.send(.disconnected(error: nil))
    }

    private func runEventStreamLoop() async {
        var backoffSeconds: UInt64 = 2

        while isRunning && !Task.isCancelled {
            do {
                guard let url = URL(string: "\(APIService.shared.baseURL)/api/sync/events") else {
                    try await Task.sleep(nanoseconds: 5_000_000_000)
                    continue
                }

                var request = URLRequest(url: url)
                request.setValue("text/event-stream", forHTTPHeaderField: "Accept")
                request.timeoutInterval = 3600 // Long-lived SSE stream

                let config = URLSessionConfiguration.default
                config.timeoutIntervalForRequest = 60.0
                config.timeoutIntervalForResource = 86400
                let session = URLSession(configuration: config)

                let (bytes, response) = try await session.bytes(for: request)

                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }

                // Reset backoff on successful HTTP connection
                backoffSeconds = 2

                var currentEvent: String? = nil
                var currentData: String? = nil

                for try await line in bytes.lines {
                    if Task.isCancelled || !isRunning { break }

                    if line.hasPrefix("event: ") {
                        currentEvent = String(line.dropFirst(7)).trimmingCharacters(in: .whitespacesAndNewlines)
                    } else if line.hasPrefix("data: ") {
                        currentData = String(line.dropFirst(6)).trimmingCharacters(in: .whitespacesAndNewlines)
                    } else if line.isEmpty {
                        // End of SSE message block
                        if let event = currentEvent, let data = currentData {
                            self.parseAndDispatch(event: event, data: data)
                        }
                        currentEvent = nil
                        currentData = nil
                    }
                }
            } catch {
                if Task.isCancelled || !isRunning { break }
                eventSubject.send(.disconnected(error: error.localizedDescription))
            }

            if isRunning && !Task.isCancelled {
                // Exponential backoff up to 15s
                try? await Task.sleep(nanoseconds: backoffSeconds * 1_000_000_000)
                backoffSeconds = min(backoffSeconds * 2, 15)
            }
        }
    }

    private func parseAndDispatch(event: String, data: String) {
        guard let jsonData = data.data(using: .utf8) else { return }
        let decoder = JSONDecoder()

        switch event {
        case "connected":
            struct ConnectPayload: Codable { let clientId: String? }
            let id = (try? decoder.decode(ConnectPayload.self, from: jsonData))?.clientId ?? "connected"
            eventSubject.send(.connected(clientId: id))

        case "ping":
            eventSubject.send(.ping)

        case "contact_added":
            struct ContactWrapper: Codable { let contact: Contact }
            if let w = try? decoder.decode(ContactWrapper.self, from: jsonData) {
                eventSubject.send(.contactAdded(w.contact))
            }

        case "contact_updated":
            struct ContactWrapper: Codable { let contact: Contact }
            if let w = try? decoder.decode(ContactWrapper.self, from: jsonData) {
                eventSubject.send(.contactUpdated(w.contact))
            }

        case "contact_deleted":
            struct IdWrapper: Codable { let id: String }
            if let w = try? decoder.decode(IdWrapper.self, from: jsonData) {
                eventSubject.send(.contactDeleted(id: w.id))
            }

        case "village_added":
            struct VillageWrapper: Codable { let village: Village }
            if let w = try? decoder.decode(VillageWrapper.self, from: jsonData) {
                eventSubject.send(.villageAdded(w.village))
            }

        case "village_deleted":
            struct IdWrapper: Codable { let id: String }
            if let w = try? decoder.decode(IdWrapper.self, from: jsonData) {
                eventSubject.send(.villageDeleted(id: w.id))
            }

        case "emergency_added":
            struct EmergencyWrapper: Codable { let emergency: EmergencyContact }
            if let w = try? decoder.decode(EmergencyWrapper.self, from: jsonData) {
                eventSubject.send(.emergencyAdded(w.emergency))
            }

        case "emergency_updated":
            struct EmergencyWrapper: Codable { let emergency: EmergencyContact }
            if let w = try? decoder.decode(EmergencyWrapper.self, from: jsonData) {
                eventSubject.send(.emergencyUpdated(w.emergency))
            }

        case "emergency_deleted":
            struct IdWrapper: Codable { let id: String }
            if let w = try? decoder.decode(IdWrapper.self, from: jsonData) {
                eventSubject.send(.emergencyDeleted(id: w.id))
            }

        case "office_added":
            struct OfficeWrapper: Codable { let office: Office }
            if let w = try? decoder.decode(OfficeWrapper.self, from: jsonData) {
                eventSubject.send(.officeAdded(w.office))
            }

        case "office_updated":
            struct OfficeWrapper: Codable { let office: Office }
            if let w = try? decoder.decode(OfficeWrapper.self, from: jsonData) {
                eventSubject.send(.officeUpdated(w.office))
            }

        case "office_deleted":
            struct IdWrapper: Codable { let id: String }
            if let w = try? decoder.decode(IdWrapper.self, from: jsonData) {
                eventSubject.send(.officeDeleted(id: w.id))
            }

        case "broadcast_received":
            struct BroadcastWrapper: Codable { let broadcast: BroadcastNotice }
            if let w = try? decoder.decode(BroadcastWrapper.self, from: jsonData) {
                eventSubject.send(.broadcastReceived(w.broadcast))
            }

        case "broadcast_deleted":
            struct IdWrapper: Codable { let id: String }
            if let w = try? decoder.decode(IdWrapper.self, from: jsonData) {
                eventSubject.send(.broadcastDeleted(id: w.id))
            }

        case "full_sync_required", "directory_restored":
            eventSubject.send(.fullSyncRequired)

        default:
            break
        }
    }
}
