import CoreData

struct CountryCategory: Identifiable {
    static let defaultMapColorRGB: Int32 = 0x2B78D4

    let id: UUID
    let name: String
    var countryIDs: Set<String>
    var mapColorRGB: Int32
}

@MainActor
final class CoreDataManager {
    static let shared = CoreDataManager()

    private enum StorageError: Error {
        case categoryNotFound
    }

    private let context = PersistenceController.shared.context

    func fetchFavoriteNames() throws -> Set<String> {
        let request: NSFetchRequest<FavoritCountry> = FavoritCountry.fetchRequest()
        return Set(try context.fetch(request).compactMap(\.name))
    }

    func setFavorite(_ isFavorite: Bool, name: String) throws {
        let request: NSFetchRequest<FavoritCountry> = FavoritCountry.fetchRequest()
        request.predicate = NSPredicate(format: "name == %@", name)
        let matches = try context.fetch(request)

        if isFavorite {
            guard matches.isEmpty else { return }
            FavoritCountry(context: context).name = name
        } else {
            matches.forEach { context.delete($0) }
        }
        try saveChanges()
    }

    func fetchCategories() throws -> [CountryCategory] {
        let request: NSFetchRequest<SavedCategory> = SavedCategory.fetchRequest()
        return try context.fetch(request).compactMap { category in
            guard let id = category.id, let name = category.name else { return nil }
            let members = category.members as? Set<SavedCategoryCountry> ?? []
            return CountryCategory(
                id: id, name: name,
                countryIDs: Set(members.compactMap(\.countryID)),
                mapColorRGB: category.mapColorRGB
            )
        }
    }

    func createCategory(name: String) throws -> CountryCategory {
        let category = CountryCategory(id: UUID(), name: name, countryIDs: [], mapColorRGB: CountryCategory.defaultMapColorRGB)
        let savedCategory = SavedCategory(context: context)
        savedCategory.id = category.id
        savedCategory.name = category.name
        savedCategory.mapColorRGB = category.mapColorRGB
        try saveChanges()
        return category
    }

    func deleteCategories(ids: Set<UUID>) throws {
        let request: NSFetchRequest<SavedCategory> = SavedCategory.fetchRequest()
        request.predicate = NSPredicate(format: "id IN %@", ids.map { $0 as NSUUID } as NSArray)
        try context.fetch(request).forEach { context.delete($0) }
        try saveChanges()
    }

    func setCountry(_ countryID: String, included: Bool, in categoryID: UUID) throws {
        let category = try savedCategory(withID: categoryID)

        let members = category.members as? Set<SavedCategoryCountry> ?? []
        let matches = members.filter { $0.countryID == countryID }

        if included {
            guard matches.isEmpty else { return }
            let member = SavedCategoryCountry(context: context)
            member.countryID = countryID
            member.category = category
        } else {
            matches.forEach { context.delete($0) }
        }
        try saveChanges()
    }

    func setMapColor(_ rgb: Int32, in categoryID: UUID) throws {
        let category = try savedCategory(withID: categoryID)
        category.mapColorRGB = rgb
        try saveChanges()
    }

    private func savedCategory(withID categoryID: UUID) throws -> SavedCategory {
        let request: NSFetchRequest<SavedCategory> = SavedCategory.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", categoryID as NSUUID)
        request.fetchLimit = 1
        guard let category = try context.fetch(request).first else {
            throw StorageError.categoryNotFound
        }
        return category
    }

    private func saveChanges() throws {
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            context.rollback()
            throw error
        }
    }
}
