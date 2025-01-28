//
//  CountryModel.swift
//  WorldCountries
//
//  Created by Ivan Pushkov on 28.01.2025.
//

import Foundation

import Foundation
typealias Countries = [Country]

struct Country: Decodable{
    let name: Name
    let capital: [String]?
    let population: Int
    let flag: String
    let area: Double
    let region: String
    let languages: [String: String]?
    let timezones: [String]?
    let coordinates: [Double]?
    let currencies: [String: Currency]?
}

struct Name: Decodable {
    let common: String
    let official: String
}

struct Currency: Decodable{
    let name: String
    let symbol: String
}
