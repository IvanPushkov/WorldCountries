//
//  CountryView.swift
//  WorldCountries
//
//  Created by Ivan Pushkov on 28.01.2025.
//

import SwiftUI

@MainActor
struct CountryView: View {
    let countryID: String
    let collection: CountryCollection
    @ObservedObject var countryListModel: CountryListViewModel

    var body: some View {
        if let country = countryListModel.country(withID: countryID) {
            let isIncluded = countryListModel.isIncluded(country, in: collection)
            ScrollView {
                VStack(alignment: .leading) {
                    HStack {
                        Text(country.name)
                            .font(.system(.largeTitle, design: .rounded))
                            .padding(.bottom, 20)
                        Spacer()
                        Button {
                            withAnimation {
                                countryListModel.toggleCountry(countryID, in: collection)
                            }
                        } label: {
                            Image(systemName: "heart.fill")
                                .font(.system(size: 40))
                                .scaleEffect(isIncluded ? 1.2 : 1.0)
                                .foregroundColor(Color(isIncluded ? "OnButton" : "OfButton"))
                                .frame(width: 60, height: 60)
                                .overlay { Circle().stroke(Color("MainBg")) }
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(isIncluded ? Text("remove_from_category") : Text("add_to_category"))
                    }
                    MainCountryInformationView(countryModell: country)
                    if let coordinates = country.coordinates {
                        MapView(latitude: coordinates.latitude, longitude: coordinates.longitude)
                    }
                }
                .padding()
            }
        }
    }
}

struct MainCountryInformationView: View {
    let countryModell: CountryCellModel
    var body: some View {
        HStack{
            VStack(alignment: .leading){
                InformationText(text: countryModell.capital ?? "no_Capital".localized)
                InformationText(text: countryModell.population)
                InformationText(text: countryModell.area)
                InformationText(text: countryModell.currency)
                InformationText(text: (countryModell.languages?.first) ?? "Unknown_Language".localized)
                InformationText(text: countryModell.timezones)
            }
            Text(countryModell.flag)
                .font(.system(size: 150))
                .offset(x: 20)
            Spacer()
        }
    }
}

struct InformationText: View {
    let text: String
    let fontSize: CGFloat = 20
    var body: some View {
        Text(text)
            .font(.system(size: fontSize))
            .padding(.bottom, 20)
    }
}
