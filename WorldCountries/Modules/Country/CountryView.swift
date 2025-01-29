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
                            .frame(width: 60, height: 60)
                            .foregroundColor(Color.primary)
                        Image(systemName: "heart.fill")
                            .font(.system(size: 30))
                            .scaleEffect(countryModell.isFavorits ? 1.2 : 1.0)
                            .foregroundColor(countryModell.isFavorits ? .red : .gray)
                            .animation(.default, value: countryModell.isFavorits)
                    }
                    .onTapGesture {
                        complection(countryModell)
                        countryModell.isFavorits.toggle()
                    }
                }
                HStack{
                    VStack{
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
                }
                if let latitude = countryModell.coordinates?.first, let longitude = countryModell.coordinates?.last  {
                    MapView(latitude: latitude, longitude: longitude)
                }
            }
            .padding()
        }
    }
    
}


