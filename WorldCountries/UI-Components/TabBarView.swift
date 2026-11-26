import SwiftUI

struct TabBarView: View {
    @Binding var showingFavorites: Bool

    var body: some View {
        HStack {
            tab("favorites", icon: "heart.fill", isSelected: showingFavorites) {
                showingFavorites = true
            }
            Spacer()
            tab("world_countries", icon: "list.bullet.rectangle.portrait.fill", isSelected: !showingFavorites) {
                showingFavorites = false
            }
        }
        .padding(.horizontal, 45)
        .background(Color("TabBarBg"))
    }

    private func tab(_ title: LocalizedStringKey, icon: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button {
            withAnimation { action() }
        } label: {
            Label(title, systemImage: icon)
                .labelStyle(.iconOnly)
                .font(.system(size: isSelected ? 50 : 30))
                .foregroundColor(Color(isSelected ? "OnButton" : "OfButton"))
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
