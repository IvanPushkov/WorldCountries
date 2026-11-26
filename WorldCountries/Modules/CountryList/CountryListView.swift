import SwiftUI

enum CountryRoute: Hashable {
    case categories
    case collection(CountryCollection)
    case country(String)
}

@MainActor
struct CountryListView: View {
    @ObservedObject var countryListModel: CountryListViewModel

    var body: some View {
        NavigationStack {
            VStack {
                SearchTextField(searchText: $countryListModel.searchText)
                if countryListModel.isLoading {
                    Spacer()
                    CustomLoadView(isLoading: true)
                    Spacer()
                } else {
                    List(countryListModel.cellModels) { country in
                        CountryCell(country: country, countryListModel: countryListModel)
                    }
                }
                TabBarView(showingFavorites: $countryListModel.showingFavorites)
            }
            .navigationTitle("world_countries")
            .navigationDestination(for: CountryRoute.self) { route in
                switch route {
                case .categories:
                    CategoryListView(countryListModel: countryListModel)
                case .collection(let collection):
                    CategoryDetailView(collection: collection, countryListModel: countryListModel)
                case .country(let countryID):
                    CountryView(countryID: countryID, countryListModel: countryListModel)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(value: CountryRoute.categories) {
                        Label("categories", systemImage: "folder")
                    }
                }
            }
        }
        .task {
            countryListModel.loadIfNeeded()
        }
        .alert("connection_error", isPresented: $countryListModel.showingConnectionError) {
            Button("retry") { countryListModel.fetchData() }
            Button("cancel", role: .cancel) {}
        }
        .alert("storage_error", isPresented: $countryListModel.showingStorageError) {
            Button("ok", role: .cancel) {}
        }
    }
}
