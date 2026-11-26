import SwiftUI
import UIKit

@MainActor
struct CategoryDetailView: View {
    let collection: CountryCollection
    @ObservedObject var countryListModel: CountryListViewModel
    let openCountry: (String) -> Void
    @State private var isEditing: Bool
    @State private var categoryName: String
    @State private var searchText = ""

    init(
        collection: CountryCollection,
        countryListModel: CountryListViewModel,
        editing: Bool,
        openCountry: @escaping (String) -> Void
    ) {
        self.collection = collection
        self.countryListModel = countryListModel
        self.openCountry = openCountry
        _isEditing = State(initialValue: editing)
        _categoryName = State(initialValue: countryListModel.collectionName(collection) ?? "")
    }

    private var visibleCountries: [CountryCellModel] {
        let selected = countryListModel.countryIDs(in: collection)
        return countryListModel.allCellModels.filter { country in
            if isEditing {
                return searchText.isEmpty || country.name.localizedStandardContains(searchText)
            }
            return selected.contains(country.id)
        }
    }

    var body: some View {
        if let title = countryListModel.collectionName(collection) {
            let selected = countryListModel.countryIDs(in: collection)
            let selectable = Set(countryListModel.allCellModels.lazy.map(\.id))
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    CategoryWorldMap(
                        selectedIDs: selected,
                        tappableIDs: isEditing ? selectable : selectable.intersection(selected),
                        colorRGB: countryListModel.mapColor(in: collection),
                        onDoubleTap: beginEditing
                    ) { countryID in
                        if isEditing {
                            countryListModel.toggleCountry(countryID, in: collection)
                        } else {
                            openCountry(countryID)
                        }
                    }
                    .frame(height: min(300, geometry.size.height * 0.45))
                    countryList
                }
            }
            .navigationTitle(isEditing ? "edit_category".localized : title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if isEditing {
                        Button("done", action: finishEditing)
                            .disabled(collection != .favorites && categoryName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    } else {
                        Button(action: beginEditing) {
                            Label("edit_category", systemImage: "pencil")
                        }
                    }
                }
            }
        } else {
            Text("category_removed")
        }
    }

    private func beginEditing() {
        guard !isEditing else { return }
        categoryName = countryListModel.collectionName(collection) ?? ""
        isEditing = true
    }

    private func finishEditing() {
        if case .category(let id) = collection {
            guard countryListModel.renameCategory(id, to: categoryName) else { return }
        }
        isEditing = false
        searchText = ""
    }

    private var colorSelection: Binding<Color> {
        Binding {
            let rgb = countryListModel.mapColor(in: collection)
            return Color(
                red: Double((rgb >> 16) & 255) / 255,
                green: Double((rgb >> 8) & 255) / 255,
                blue: Double(rgb & 255) / 255
            )
        } set: { color in
            var red: CGFloat = 0
            var green: CGFloat = 0
            var blue: CGFloat = 0
            guard UIColor(color).getRed(&red, green: &green, blue: &blue, alpha: nil) else { return }
            let rgb = (colorByte(red) << 16) | (colorByte(green) << 8) | colorByte(blue)
            countryListModel.setMapColor(rgb, in: collection)
        }
    }

    private func colorByte(_ component: CGFloat) -> Int32 {
        Int32((min(1, max(0, component)) * 255).rounded())
    }

    private var countryList: some View {
        let selected = countryListModel.countryIDs(in: collection)

        return List {
            if isEditing {
                Section {
                    if case .category = collection {
                        LabeledContent("category_name") {
                            TextField("category_name", text: $categoryName)
                                .multilineTextAlignment(.trailing)
                                .submitLabel(.done)
                                .onSubmit(finishEditing)
                        }
                    }
                    ColorPicker("category_map_color", selection: colorSelection, supportsOpacity: false)

                    if !countryListModel.allCellModels.isEmpty {
                        TextField("search_countries", text: $searchText)
                    }
                }
            }

            if countryListModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
            } else if countryListModel.allCellModels.isEmpty {
                Button("retry") { countryListModel.fetchData() }
            } else {
                if visibleCountries.isEmpty {
                    (isEditing ? Text("no_matching_countries") : Text("empty_category"))
                        .foregroundStyle(.secondary)
                }
                ForEach(visibleCountries) { country in
                    if isEditing {
                        countryChoice(country, included: selected.contains(country.id))
                    } else {
                        CountryCell(country: country, collection: collection, countryListModel: countryListModel)
                    }
                }
            }
        }
        .listStyle(.plain)
    }

    private func countryChoice(_ country: CountryCellModel, included: Bool) -> some View {
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
    }
}
