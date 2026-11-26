

import Foundation



struct CountryCellModel: Identifiable {
    let id: String
    var isFavorits: Bool
    let name: String
    let flag: String
    let region: String
    let capital: String?
    let population: String
    let area: String
    let languages: [String]?
    var currency: String
    let timezones: String
    let coordinates: (latitude: Double, longitude: Double)?
    
    init(country: Country) {
        let code = [country.codes?.alpha3, country.codes?.alpha2]
            .compactMap { $0 }
            .first { !$0.isEmpty }
        id = code.map { "iso:\($0.uppercased())" } ?? "name:\(country.names.common)"
        name = country.names.common.localized
        flag = country.flag?.emoji ?? .unloaded
        region = country.region?.localized ?? .unloaded
        
        capital = country.capitals?.first?.name.localized
        population = "population_format".localized("\(country.population)")
        area = "area_format".localized("\(country.area)")
        languages = country.languages?.sorted().map{ $0.name}
        timezones = country.timezones?.joined(separator: ", ") ?? "timezones_unknown".localized
        if let latitude = country.coordinates?.lat, let longitude = country.coordinates?.lng,
           (-90...90).contains(latitude), (-180...180).contains(longitude) {
            coordinates = (latitude, longitude)
        } else {
            coordinates = nil
        }
        isFavorits = false
        currency = "currency_unknown".localized
        setCurrency(country.currencies)
    }
    
    private mutating func setCurrency(_ currencies: [Currency]?) {
        if let currencies = currencies, !currencies.isEmpty {
            var currencyList: [String] = []
            for currency in currencies {
                let currencyString = "currency_format".localized(currency.name, currency.symbol ?? .unloaded)
                currencyList.append(currencyString)
            }
            self.currency = currencyList.joined(separator: ", ")
        }
    }
}
