import Foundation

actor CountryCatalogCache {
    private let fileURL: URL?

    init(directory: URL? = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first) {
        fileURL = directory?.appendingPathComponent("country-catalog-v1.json")
    }

    func load() -> Countries? {
        guard let fileURL,
              let data = try? Data(contentsOf: fileURL),
              let catalog = try? JSONDecoder().decode(Countries.self, from: data),
              !catalog.data.objects.isEmpty else { return nil }
        return catalog
    }

    func save(_ catalog: Countries) {
        guard let fileURL, !catalog.data.objects.isEmpty else { return }
        do {
            let data = try JSONEncoder().encode(catalog)
            try FileManager.default.createDirectory(at: fileURL.deletingLastPathComponent(), withIntermediateDirectories: true)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            // A cache write failure does not prevent displaying countries from the API.
        }
    }
}
