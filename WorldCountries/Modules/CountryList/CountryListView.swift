import SwiftUI

enum CountryRoute: Hashable {
    case collection(CountryCollection, editing: Bool)
    case country(String, collection: CountryCollection)
}

@MainActor
struct CountryListView: View {
    @ObservedObject var countryListModel: CountryListViewModel
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var path: [CountryRoute] = []
    @State private var showsLoadingAnimation = false

    var body: some View {
        NavigationStack(path: $path) {
            VStack {
                SearchTextField(searchText: $countryListModel.searchText)
                CategoryPickerBar(countryListModel: countryListModel)
                catalogContent
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
        .task(id: countryListModel.isLoading) {
            await updateLoadingAnimation()
        }
        .alert("connection_error", isPresented: $countryListModel.showingConnectionError) {
            Button("retry") { countryListModel.fetchData() }
            Button("cancel", role: .cancel) {}
        }
        .alert("storage_error", isPresented: $countryListModel.showingStorageError) {
            Button("ok", role: .cancel) {}
        }
    }

    private var catalogContent: some View {
        ZStack {
            if !countryListModel.allCellModels.isEmpty {
                List(countryListModel.cellModels) { country in
                    CountryCell(
                        country: country,
                        collection: countryListModel.selectedCollection,
                        countryListModel: countryListModel
                    )
                }
            } else if !countryListModel.isLoading {
                Button("retry") { countryListModel.fetchData() }
            }

            if showsLoadingAnimation {
                CustomLoadView(isLoading: countryListModel.isLoading)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(uiColor: .systemBackground))
                    .allowsHitTesting(false)
                    .accessibilityHidden(!countryListModel.isLoading)
                    .transition(.opacity)
                    .zIndex(1)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func updateLoadingAnimation() async {
        if countryListModel.isLoading {
            do {
                try await Task.sleep(for: .milliseconds(180))
            } catch {
                return
            }
            guard !Task.isCancelled, countryListModel.isLoading else { return }
            showsLoadingAnimation = true
        } else {
            withAnimation(reduceMotion ? nil : .easeOut(duration: 0.28)) {
                showsLoadingAnimation = false
            }
        }
    }
}
