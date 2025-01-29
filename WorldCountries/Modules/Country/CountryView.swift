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
    let verticalPadding: CGFloat = 10
    var body: some View {
        HStack{
            VStack(alignment: .leading){
                Text(countryModell.capital ?? "No Capital")
                    .font(.system(size: 20))
                    .padding(.bottom, verticalPadding)
                Text(countryModell.population)
                    .font(.system(size: 20))
                    .padding(.bottom, verticalPadding)
                Text(countryModell.area)
                    .font(.system(size: 20))
                    .padding(.bottom, verticalPadding)
                Text(countryModell.currency)
                    .font(.system(size: 15))
                    .padding(.bottom, verticalPadding)
                Text((countryModell.languages?.first)!)
                    .font(.system(size: 20))
                Text(countryModell.timezones)
                    .font(.system(size: 20))
                    .padding(.bottom, verticalPadding)
            }
            Text(countryModell.flag)
                .font(.system(size: 150))
                .offset(x: 20)
            Spacer()
        }
    }
}

