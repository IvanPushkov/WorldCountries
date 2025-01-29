//
//  CountryView.swift
//  WorldCountries
//
//  Created by Ivan Pushkov on 28.01.2025.
//

import SwiftUI

struct CountryView: View {
    @Binding var countryModell: CountryCellModel
    var complection: (CountryCellModel)-> ()
    var verticalPadding: CGFloat = 10
    var body: some View {
        
        ScrollView {
            VStack(alignment: .leading) {
                HStack {
                    Text(countryModell.name)
                        .font(.system(.largeTitle, design: .rounded))
                        .padding(.bottom, 20)
                    Spacer()
                    ZStack{
                        Circle()
                            .stroke()
                            .frame(width: 60, height: 60)
                            .foregroundColor(Color("MainBg"))
                        Image(systemName: "heart.fill")
                            .font(.system(size: 40))
                            .scaleEffect(countryModell.isFavorits ? 1.2 : 1.0)
                            .foregroundColor(countryModell.isFavorits ?  Color("OnButton"): Color("OfButton") )
                            .animation(.default, value: countryModell.isFavorits)
                    }
                    .offset(y: -10)
                    .onTapGesture {
                        complection(countryModell)
                        countryModell.isFavorits.toggle()
                    }
                }
                MainCountryInformationView(countryModell: countryModell)
                if let latitude = countryModell.coordinates?.first, let longitude = countryModell.coordinates?.last  {
                    MapView(latitude: latitude, longitude: longitude)
                }
            }
            .padding()
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
