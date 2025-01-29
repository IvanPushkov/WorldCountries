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
    var body: some View {
        
        VStack(alignment: .leading) {
            Text(countryModell.name)
                .font(.system(.title))
            Text(countryModell.capital ?? "No Capital")
                .font(.system(size: 20))
            Text(countryModell.area)
                .font(.system(size: 20))
            Text(countryModell.currency)
                .font(.system(size: 20))
            Text((countryModell.languages?.first)!)
                .font(.system(size: 20))
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
        }
    }


