//
//  SwiftUIView.swift
//  WorldCountries
//
//  Created by Ivan Pushkov on 29.01.2025.
//

import SwiftUI

struct SwiftUIView: View {
    var body: some View {
        let n = "no_internet".localized
       let population = "population_format".localized("\(n)")
        Text(population)
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        SwiftUIView()
    }
}
