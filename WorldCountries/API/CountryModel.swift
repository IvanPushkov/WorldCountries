//
//  CountryModel.swift
//  WorldCountries
//
//  Created by Ivan Pushkov on 28.01.2025.
//

import Foundation

struct Countries: Codable {
    let data: CountriesData
}

struct CountriesData: Codable {
    let objects: [Country]
}

struct Country: Codable {
    let names: Names
    let codes: Codes?
    let capitals: [Capital]?
    let flag: Flag?
    let region: String?
    let subregion: String?
    let area: Area?
    let population: Int?
    let timezones: [String]?
    let coordinates: Coordinates?
    let currencies: [Currency]?
    let languages: [Language]?
    let borders: [String]?
    let callingCodes: [String]?

    enum CodingKeys: String, CodingKey {
        case names, codes, capitals, flag, region, subregion,
             area, population, timezones, coordinates,
             currencies, languages, borders
        case callingCodes = "calling_codes"
    }
}

struct Names: Codable {
    let common: String
    let official: String
    let alternates: [String]?
    // `native` and `translations` can be described if needed
}

struct Codes: Codable {
    let alpha2: String?
    let alpha3: String?

    enum CodingKeys: String, CodingKey {
        case alpha2 = "alpha_2"
        case alpha3 = "alpha_3"
    }
}

struct Capital: Codable {
    let name: String
    let coordinates: Coordinates?
}

struct Coordinates: Codable {
    let lat: Double?
    let lng: Double?
}

struct Flag: Codable {
    let emoji: String?
    let urlPng: String?
    let urlSvg: String?

    enum CodingKeys: String, CodingKey {
        case emoji
        case urlPng = "url_png"
        case urlSvg = "url_svg"
    }
}

struct Area: Codable {
    let kilometers: Double?
    let miles: Double?
}

struct Currency: Codable {
    let code: String
    let name: String
    let symbol: String?
}

struct Language: Codable, Comparable {
    static func < (lhs: Language, rhs: Language) -> Bool {
        lhs.name < rhs.name
    }
    
    let name: String
    let nativeName: String?

    enum CodingKeys: String, CodingKey {
        case name
        case nativeName = "native_name"
    }
}
