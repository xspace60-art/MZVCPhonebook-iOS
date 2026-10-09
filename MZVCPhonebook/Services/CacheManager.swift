import Foundation

public final class CacheManager {
    public static let shared = CacheManager()

    private let fileManager = FileManager.default

    private var cacheDirectory: URL {
        let urls = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        let dir = urls[0].appendingPathComponent("MZVCPhonebookCache", isDirectory: true)
        if !fileManager.fileExists(atPath: dir.path) {
            try? fileManager.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir
    }

    private func fileURL(for key: String) -> URL {
        cacheDirectory.appendingPathComponent("\(key).json")
    }

    public func save<T: Encodable>(_ object: T, forKey key: String) {
        DispatchQueue.global(qos: .utility).async { [weak self] in
            guard let self = self else { return }
            do {
                let data = try JSONEncoder().encode(object)
                let url = self.fileURL(for: key)
                try data.write(to: url, options: .atomic)
            } catch {
                print("Failed to save cache for \(key): \(error)")
            }
        }
    }

    public func load<T: Decodable>(forKey key: String, as type: T.Type) -> T? {
        let url = fileURL(for: key)
        guard fileManager.fileExists(atPath: url.path) else { return nil }
        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            print("Failed to load cache for \(key): \(error)")
            return nil
        }
    }

    public func clearCache(for district: String) {
        let keys = [
            "contacts_\(district)",
            "emergency_\(district)",
            "villages_\(district)",
            "offices_\(district)",
            "broadcasts_\(district)"
        ]
        for key in keys {
            let url = fileURL(for: key)
            try? fileManager.removeItem(at: url)
        }
    }
}
