import SwiftUI

enum CountryCollection: Hashable {
    case favorites
    case category(UUID)
}

@MainActor
final class CountryListViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var showingFavorites = false
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
        allCellModels.filter { country in
            (!showingFavorites || country.isFavorits)
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

    func toggleFavorite(_ countryID: String) {
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
            categories.append(try coreDataManager.createCategory(name: name))
            sortCategories()
        } catch {
            showingStorageError = true
        }
    }

    func deleteCategories(ids: Set<UUID>) {
        do {
            try coreDataManager.deleteCategories(ids: ids)
            categories.removeAll { ids.contains($0.id) }
        } catch {
            showingStorageError = true
        }
    }

    private func sortCategories() {
        categories.sort { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
    }
}
