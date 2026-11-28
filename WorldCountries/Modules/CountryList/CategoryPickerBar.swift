import SwiftUI

@MainActor
struct CategoryPickerBar: View {
    @ObservedObject var countryListModel: CountryListViewModel
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorScheme) private var colorScheme
    @ScaledMetric(relativeTo: .subheadline) private var cardHeight: CGFloat = 44
    @State private var showingNewCategory = false
    @State private var categoryName = ""

    var body: some View {
        HStack(spacing: 4) {
            categoryCarousel

            Button {
                categoryName = ""
                showingNewCategory = true
            } label: {
                actionLabel("new_category", icon: "plus")
            }

            NavigationLink(value: CountryRoute.collection(countryListModel.selectedCollection)) {
                actionLabel("open_category", icon: "folder")
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

    private var categoryCarousel: some View {
        ScrollViewReader { scroll in
            GeometryReader { viewport in
                let cardWidth = min(200, viewport.size.width * 0.68)
                let inset = (viewport.size.width - cardWidth) / 2

                carouselScrollView(cardWidth: cardWidth, center: viewport.size.width / 2, inset: inset)
                .coordinateSpace(name: "categoryCarousel")
                .background(Color(uiColor: .systemBackground))
                .onAppear {
                    scroll.scrollTo(countryListModel.selectedCollection, anchor: .center)
                }
                .onChange(of: countryListModel.selectedCollection) { collection in
                    withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.25)) {
                        scroll.scrollTo(collection, anchor: .center)
                    }
                }
                .onChange(of: countryListModel.categories.map(\.id)) { _ in
                    scroll.scrollTo(countryListModel.selectedCollection, anchor: .center)
                }
            }
            .frame(height: cardHeight)
        }
    }

    @ViewBuilder
    private func carouselScrollView(cardWidth: CGFloat, center: CGFloat, inset: CGFloat) -> some View {
        let cards = carouselCards(cardWidth: cardWidth, center: center)
        let fallback = ScrollView(.horizontal, showsIndicators: false) {
            cards.padding(.horizontal, inset)
        }

        // Scroll targets require the SwiftUI SDK from Xcode 15 or newer.
        #if compiler(>=5.9)
        if #available(iOS 17, *) {
            ScrollView(.horizontal, showsIndicators: false) {
                cards.scrollTargetLayout()
            }
            .contentMargins(.horizontal, inset, for: .scrollContent)
            .scrollTargetBehavior(.viewAligned)
        } else {
            fallback
        }
        #else
        fallback
        #endif
    }

    private func carouselCards(cardWidth: CGFloat, center: CGFloat) -> some View {
        LazyHStack(spacing: 8) {
            categoryCard(.favorites, name: "favorites".localized, width: cardWidth, center: center)
                .id(CountryCollection.favorites)

            ForEach(countryListModel.categories) { category in
                let collection = CountryCollection.category(category.id)
                categoryCard(collection, name: category.name, width: cardWidth, center: center)
                    .contextMenu {
                        Button(role: .destructive) {
                            countryListModel.deleteCategory(category.id)
                        } label: {
                            Label("delete_category", systemImage: "trash")
                        }
                    }
                    .id(collection)
            }
        }
    }

    private func categoryCard(_ collection: CountryCollection, name: String, width: CGFloat, center: CGFloat) -> some View {
        let selected = countryListModel.selectedCollection == collection
        let colors = cardColors(rgb: countryListModel.mapColor(in: collection), selected: selected)
        return GeometryReader { card in
            let distance = abs(card.frame(in: .named("categoryCarousel")).midX - center)
            let progress = min(distance / max(width, 1), 1)

            Button {
                countryListModel.selectCollection(collection)
            } label: {
                Text(name)
                    .font(.subheadline.weight(.medium))
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 12)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .foregroundStyle(colors.text)
                    .background(colors.fill, in: Capsule())
                    .overlay {
                        Capsule().strokeBorder(Color.primary.opacity(selected ? 0.20 : 0.08))
                    }
                    .contentShape(Capsule())
            }
            .scaleEffect(reduceMotion ? 1 : 1 - 0.14 * progress)
            .accessibilityAddTraits(selected ? .isSelected : [])
        }
        .frame(width: width, height: cardHeight)
    }

    private func cardColors(rgb: Int32, selected: Bool) -> (fill: Color, text: Color) {
        let red = Double((rgb >> 16) & 255) / 255
        let green = Double((rgb >> 8) & 255) / 255
        let blue = Double(rgb & 255) / 255
        let opacity = selected ? 1.0 : 0.45
        let background = colorScheme == .dark ? 0.0 : 1.0

        // Choose readable text against the color as it appears over the carousel background.
        func linearized(_ channel: Double) -> Double {
            let blended = channel * opacity + background * (1 - opacity)
            return blended <= 0.04045 ? blended / 12.92 : pow((blended + 0.055) / 1.055, 2.4)
        }

        let luminance = 0.2126 * linearized(red) + 0.7152 * linearized(green) + 0.0722 * linearized(blue)
        let fill = Color(red: red, green: green, blue: blue).opacity(opacity)
        return (fill, luminance > 0.179 ? .black : .white)
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
