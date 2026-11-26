import SwiftUI

@MainActor
struct CategoryDetailView: View {
    let collection: CountryCollection
    @ObservedObject var countryListModel: CountryListViewModel
    @State private var isEditingCountries = false
    @State private var searchText = ""

    private var title: String? {
        switch collection {
        case .favorites:
            return "favorites".localized
        case .category(let id):
            return countryListModel.categories.first { $0.id == id }?.name
        }
    }

    private var visibleCountries: [CountryCellModel] {
        let selected = countryListModel.countryIDs(in: collection)
        return countryListModel.allCellModels.filter { country in
            if isEditingCountries {
                return searchText.isEmpty || country.name.localizedStandardContains(searchText)
            }
            return selected.contains(country.id)
        }
    }

    var body: some View {
        if let title {
            VStack(spacing: 0) {
                if isEditingCountries {
                    TextField("search_countries", text: $searchText)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal)
                        .padding(.top, 8)
                }
                if countryListModel.isLoading {
                    Spacer()
                    ProgressView()
                    Spacer()
                } else if countryListModel.allCellModels.isEmpty {
                    Spacer()
                    Button("retry") { countryListModel.fetchData() }
                    Spacer()
                } else {
                    countryList
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        isEditingCountries.toggle()
                        searchText = ""
                    } label: {
                        isEditingCountries ? Text("done") : Text("edit_countries")
                    }
                    .disabled(countryListModel.allCellModels.isEmpty)
                }
            }
        } else {
            Text("category_removed")
        }
    }

    private var countryList: some View {
        let selected = countryListModel.countryIDs(in: collection)

        return List {
            if visibleCountries.isEmpty {
                (isEditingCountries ? Text("no_matching_countries") : Text("empty_category"))
                    .foregroundStyle(.secondary)
            }
            ForEach(visibleCountries) { country in
                if isEditingCountries {
                    let included = selected.contains(country.id)
                    Button {
                        countryListModel.toggleCountry(country.id, in: collection)
                    } label: {
                        HStack {
                            Text(country.flag)
                            Text(country.name)
                            Spacer()
                            Image(systemName: included ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(included ? Color.accentColor : Color.secondary)
                        }
                    }
                    .foregroundStyle(.primary)
                    .accessibilityAddTraits(included ? .isSelected : [])
                } else {
                    CountryCell(country: country, countryListModel: countryListModel)
                }
            }
        }
        .listStyle(.plain)
    }
}
