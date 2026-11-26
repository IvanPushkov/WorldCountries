import SwiftUI

@MainActor
struct CountryCell: View {
    let country: CountryCellModel
    @ObservedObject var countryListModel: CountryListViewModel

    var body: some View {
        HStack {
            NavigationLink(value: CountryRoute.country(country.id)) {
                HStack {
                    Text(country.flag)
                        .font(.system(size: 60, design: .rounded))
                        .padding(.trailing, 20)
                    VStack(alignment: .leading) {
                        Text(country.name)
                            .font(.system(size: 20, design: .rounded))
                        Text(country.region)
                            .font(.system(size: 15, design: .rounded))
                            .foregroundColor(Color("GrayText"))
                    }
                }
            }

            Button {
                withAnimation(.spring()) {
                    countryListModel.toggleFavorite(country.id)
                }
            } label: {
                Image(systemName: "heart.fill")
                    .font(.system(size: 30))
                    .scaleEffect(country.isFavorits ? 1.2 : 1.0)
                    .foregroundColor(Color(country.isFavorits ? "OnButton" : "OfButton"))
            }
            .buttonStyle(.borderless)
            .accessibilityLabel(country.isFavorits ? Text("remove_favorite") : Text("add_favorite"))
        }
    }
}
