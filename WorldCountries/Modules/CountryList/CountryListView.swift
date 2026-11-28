import SwiftUI

enum CountryRoute: Hashable {
    case collection(CountryCollection, editing: Bool)
    case country(String, collection: CountryCollection)
}

@MainActor
struct CountryListView: View {
    @ObservedObject var countryListModel: CountryListViewModel
    @State private var path: [CountryRoute] = []

    var body: some View {
        NavigationStack(path: $path) {
            VStack {
                SearchTextField(searchText: $countryListModel.searchText)
                CategoryPickerBar(countryListModel: countryListModel)
                if countryListModel.isLoading {
                    Spacer()
                    CustomLoadView(isLoading: true)
                    Spacer()
                } else if countryListModel.allCellModels.isEmpty {
                    Spacer()
                    Button("retry") { countryListModel.fetchData() }
                    Spacer()
                } else {
                    List(countryListModel.cellModels) { country in
                        CountryCell(
                            country: country,
                            collection: countryListModel.selectedCollection,
                            countryListModel: countryListModel
                        )
                    }
                }
                TabBarView(showingSelectedOnly: $countryListModel.showingSelectedOnly)
            }
            .navigationTitle("world_countries")
            .navigationDestination(for: CountryRoute.self) { route in
                switch route {
                case .collection(let collection, let editing):
                    CategoryDetailView(collection: collection, countryListModel: countryListModel, editing: editing) { countryID in
                        path.append(.country(countryID, collection: collection))
                    }
                case .country(let countryID, let collection):
                    CountryView(countryID: countryID, collection: collection, countryListModel: countryListModel)
                }
            }
        }
        .task {
            await countryListModel.loadIfNeeded()
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
