//
//  CountryView.swift
//  WorldCountries
//
//  Created by Ivan Pushkov on 28.01.2025.
//

import SwiftUI

struct CountryView: View {
    var countryModell: CountryCellModel
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
        }
    }
}

//struct CountryView_Previews: PreviewProvider {
//    static var previews: some View {
//        CountryView()
//    }
//}
