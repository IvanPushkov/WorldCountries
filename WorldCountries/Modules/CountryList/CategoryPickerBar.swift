import SwiftUI

@MainActor
struct CategoryPickerBar: View {
    @ObservedObject var countryListModel: CountryListViewModel
    @State private var showingNewCategory = false
    @State private var categoryName = ""

    var body: some View {
        HStack(spacing: 4) {
            ScrollViewReader { scroll in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        categoryButton(.favorites, name: "favorites".localized)

                        ForEach(countryListModel.categories) { category in
                            categoryButton(.category(category.id), name: category.name)
                                .contextMenu {
                                    Button(role: .destructive) {
                                        countryListModel.deleteCategory(category.id)
                                    } label: {
                                        Label("delete_category", systemImage: "trash")
                                    }
                                }
                        }
                    }
                    .padding(.vertical, 4)
                }
                .onAppear { scroll.scrollTo(countryListModel.selectedCollection, anchor: .center) }
                .onChange(of: countryListModel.selectedCollection) { collection in
                    withAnimation { scroll.scrollTo(collection, anchor: .center) }
                }
                .onChange(of: countryListModel.categories.map(\.id)) { _ in
                    scroll.scrollTo(countryListModel.selectedCollection, anchor: .center)
                }
            }

            Button {
                categoryName = ""
                showingNewCategory = true
            } label: {
                actionLabel("new_category", icon: "plus")
            }

            NavigationLink(value: CountryRoute.collection(countryListModel.selectedCollection, editing: false)) {
                actionLabel("open_category", icon: "folder")
            }

            NavigationLink(value: CountryRoute.collection(countryListModel.selectedCollection, editing: true)) {
                actionLabel("edit_category", icon: "pencil")
            }
        }
        .padding(.horizontal)
        .buttonStyle(.plain)
        .alert("new_category", isPresented: $showingNewCategory) {
            TextField("category_name", text: $categoryName)
            Button("add_category") { countryListModel.createCategory(name: categoryName) }
            Button("cancel", role: .cancel) {}
        }
    }

    private func categoryButton(_ collection: CountryCollection, name: String) -> some View {
        let selected = countryListModel.selectedCollection == collection
        return Button {
            countryListModel.selectCollection(collection)
        } label: {
            Text(name)
                .lineLimit(1)
                .padding(.horizontal, 12)
                .frame(minHeight: 44)
                .foregroundStyle(selected ? Color.accentColor : Color.primary)
                .background(
                    selected ? Color.accentColor.opacity(0.15) : Color.secondary.opacity(0.1),
                    in: Capsule()
                )
        }
        .accessibilityAddTraits(selected ? .isSelected : [])
        .id(collection)
    }

    private func actionLabel(_ title: LocalizedStringKey, icon: String) -> some View {
        Label(title, systemImage: icon)
            .labelStyle(.iconOnly)
            .font(.title3)
            .foregroundStyle(Color.accentColor)
            .frame(width: 44, height: 44)
            .contentShape(Rectangle())
    }
}
