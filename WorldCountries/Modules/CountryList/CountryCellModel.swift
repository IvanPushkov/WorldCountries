

import Foundation



struct CountryCellModel{
    private let country: Country?
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
    let coordinates: [Double]?
    
    init(country: Country) {
        self.country = country
        name = country.names.common.localized
        flag = country.flag?.emoji ?? .unloaded
        region = country.region?.localized ?? .unloaded
        
        capital = country.capitals?.first?.name.localized
        population = "population_format".localized("\(country.population)")
        area = "area_format".localized("\(country.area)")
        languages = country.languages?.sorted().map{ $0.name}
        timezones = country.timezones?.joined(separator: ", ") ?? "timezones_unknown".localized
        coordinates = [country.coordinates?.lat ?? 0.0, country.coordinates?.lng ?? 0.0]
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
    mutating func toggleIsFavorits(){
        isFavorits.toggle()
    }
    
}
