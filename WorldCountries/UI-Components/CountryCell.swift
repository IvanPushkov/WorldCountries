import SwiftUI

@MainActor
struct CountryCell: View {
    let country: CountryCellModel
    let collection: CountryCollection
    @ObservedObject var countryListModel: CountryListViewModel

    var body: some View {
        let isIncluded = countryListModel.isIncluded(country, in: collection)
        HStack {
            NavigationLink(value: CountryRoute.country(country.id, collection: collection)) {
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
                    countryListModel.toggleCountry(country.id, in: collection)
                }
            } label: {
                Image(systemName: "heart.fill")
                    .font(.system(size: 30))
                    .scaleEffect(isIncluded ? 1.2 : 1.0)
                    .foregroundColor(Color(isIncluded ? "OnButton" : "OfButton"))
            }
            .buttonStyle(.borderless)
            .accessibilityLabel(isIncluded ? Text("remove_from_category") : Text("add_to_category"))
        }
    }
}
