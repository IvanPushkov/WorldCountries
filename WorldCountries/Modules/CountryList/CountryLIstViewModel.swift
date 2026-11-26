import SwiftUI

enum CountryCollection: Hashable {
    case favorites
    case category(UUID)
}

@MainActor
final class CountryListViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var showingSelectedOnly = false
    @Published private(set) var selectedCollection: CountryCollection = .favorites
    @Published var showingConnectionError = false
    @Published var showingStorageError = false
    @Published private(set) var isLoading = false
    @Published private(set) var allCellModels: [CountryCellModel] = []
    @Published private(set) var categories: [CountryCategory] = []

    @Published private var favoritesMapColor = UserDefaults.standard.object(forKey: "favoritesMapColorRGB") as? Int
        ?? Int(CountryCategory.defaultMapColorRGB)

    private let coreDataManager = CoreDataManager.shared
    private let apiManager = APIManager()
    private var hasStarted = false

    var cellModels: [CountryCellModel] {
        let selectedIDs = showingSelectedOnly ? countryIDs(in: selectedCollection) : []
        return allCellModels.filter { country in
            (!showingSelectedOnly || selectedIDs.contains(country.id))
                && (searchText.isEmpty || country.name.localizedStandardContains(searchText))
        }
    }

    func loadIfNeeded() {
        guard !hasStarted else { return }
        hasStarted = true

        do {
            categories = try coreDataManager.fetchCategories()
            sortCategories()
        } catch {
            showingStorageError = true
        }
        fetchData()
    }

    func fetchData() {
        guard !isLoading else { return }
        showingConnectionError = false
        isLoading = true

        apiManager.fetchAllCountries { [weak self] countries, _ in
            guard let self else { return }
            self.isLoading = false
            guard let countries else {
                self.showingConnectionError = true
                return
            }

            var favoriteNames = Set<String>()
            do {
                favoriteNames = try self.coreDataManager.fetchFavoriteNames()
            } catch {
                self.showingStorageError = true
            }

            var seenIDs = Set<String>()
            self.allCellModels = countries.data.objects.compactMap { country in
                var model = CountryCellModel(country: country)
                guard seenIDs.insert(model.id).inserted else { return nil }
                model.isFavorits = favoriteNames.contains(model.name)
                return model
            }
        }
    }

    func country(withID id: String) -> CountryCellModel? {
        allCellModels.first { $0.id == id }
    }

    private func toggleFavorite(_ countryID: String) {
        guard let index = allCellModels.firstIndex(where: { $0.id == countryID }) else { return }
        let country = allCellModels[index]
        let isFavorite = !country.isFavorits

        do {
            try coreDataManager.setFavorite(isFavorite, name: country.name)
            allCellModels[index].isFavorits = isFavorite
        } catch {
            showingStorageError = true
        }
    }

    func collectionName(_ collection: CountryCollection) -> String? {
        switch collection {
        case .favorites:
            return "favorites".localized
        case .category(let id):
            return categories.first { $0.id == id }?.name
        }
    }

    func selectCollection(_ collection: CountryCollection) {
        guard collectionName(collection) != nil else { return }
        selectedCollection = collection
    }

    func isIncluded(_ country: CountryCellModel, in collection: CountryCollection) -> Bool {
        switch collection {
        case .favorites:
            return country.isFavorits
        case .category(let id):
            return categories.first { $0.id == id }?.countryIDs.contains(country.id) == true
        }
    }

    func countryIDs(in collection: CountryCollection) -> Set<String> {
        switch collection {
        case .favorites:
            return Set(allCellModels.filter(\.isFavorits).map(\.id))
        case .category(let id):
            return categories.first { $0.id == id }?.countryIDs ?? []
        }
    }

    func toggleCountry(_ countryID: String, in collection: CountryCollection) {
        switch collection {
        case .favorites:
            toggleFavorite(countryID)
        case .category(let id):
            guard let index = categories.firstIndex(where: { $0.id == id }) else { return }
            let included = !categories[index].countryIDs.contains(countryID)

            do {
                try coreDataManager.setCountry(countryID, included: included, in: id)
                if included {
                    categories[index].countryIDs.insert(countryID)
                } else {
                    categories[index].countryIDs.remove(countryID)
                }
            } catch {
                showingStorageError = true
            }
        }
    }

    func mapColor(in collection: CountryCollection) -> Int32 {
        switch collection {
        case .favorites:
            return Int32(favoritesMapColor)
        case .category(let id):
            return categories.first { $0.id == id }?.mapColorRGB ?? CountryCategory.defaultMapColorRGB
        }
    }

    func setMapColor(_ rgb: Int32, in collection: CountryCollection) {
        guard mapColor(in: collection) != rgb else { return }
        switch collection {
        case .favorites:
            UserDefaults.standard.set(Int(rgb), forKey: "favoritesMapColorRGB")
            favoritesMapColor = Int(rgb)
        case .category(let id):
            guard let index = categories.firstIndex(where: { $0.id == id }) else { return }
            do {
                try coreDataManager.setMapColor(rgb, in: id)
                categories[index].mapColorRGB = rgb
            } catch {
                showingStorageError = true
            }
        }
    }

    func createCategory(name: String) {
        let name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return }
        do {
            let category = try coreDataManager.createCategory(name: name)
            categories.append(category)
            sortCategories()
            selectedCollection = .category(category.id)
        } catch {
            showingStorageError = true
        }
    }

    func renameCategory(_ id: UUID, to name: String) -> Bool {
        let name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty, let index = categories.firstIndex(where: { $0.id == id }) else { return false }
        guard categories[index].name != name else { return true }
        do {
            try coreDataManager.renameCategory(id, to: name)
            categories[index].name = name
            sortCategories()
            return true
        } catch {
            showingStorageError = true
            return false
        }
    }

    func deleteCategory(_ id: UUID) {
        do {
            try coreDataManager.deleteCategory(id)
            categories.removeAll { $0.id == id }
            if selectedCollection == .category(id) {
                selectedCollection = .favorites
            }
        } catch {
            showingStorageError = true
        }
    }

    private func sortCategories() {
        categories.sort { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
    }
}
