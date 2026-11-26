import SwiftUI

@MainActor
struct CategoryListView: View {
    @ObservedObject var countryListModel: CountryListViewModel
    @State private var showingNewCategory = false
    @State private var categoryName = ""

    var body: some View {
        List {
            NavigationLink(value: CountryRoute.collection(.favorites)) {
                Label("favorites", systemImage: "heart.fill")
            }

            ForEach(countryListModel.categories) { category in
                NavigationLink(value: CountryRoute.collection(.category(category.id))) {
                    Label {
                        Text(category.name)
                    } icon: {
                        Image(systemName: "folder")
                    }
                }
            }
            .onDelete { offsets in
                let ids = Set(offsets.map { countryListModel.categories[$0].id })
                countryListModel.deleteCategories(ids: ids)
            }
        }
        .navigationTitle("categories")
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                if !countryListModel.categories.isEmpty {
                    EditButton()
                }
                Button {
                    categoryName = ""
                    showingNewCategory = true
                } label: {
                    Label("new_category", systemImage: "plus")
                }
            }
        }
        .alert("new_category", isPresented: $showingNewCategory) {
            TextField("category_name", text: $categoryName)
            Button("add_category") { countryListModel.createCategory(name: categoryName) }
            Button("cancel", role: .cancel) {}
        }
    }
}
