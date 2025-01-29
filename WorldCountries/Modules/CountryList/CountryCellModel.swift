

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
        name = country.name.common.localized
        flag = country.flag
        region = country.region
        
        capital = country.capital?.first
        population = "population_format".localized("\(country.population)")
        area = "area_format".localized("\(country.area)")
        languages = country.languages?.values.sorted()
        timezones = country.timezones?.joined(separator: ", ") ?? "timezones_unknown".localized
        coordinates = country.latlng
        isFavorits = false
        currency = "currency_unknown".localized
        setCurrency(country.currencies)
    }
    
    private mutating func setCurrency(_ currencies: [String: Currency]?) {
        if let currencies = currencies, !currencies.isEmpty {
            var currencyList: [String] = []
            for currency in currencies.values {
                let currencyString = "currency_format".localized(currency.name, currency.symbol)
                currencyList.append(currencyString)
            }
            self.currency = currencyList.joined(separator: ", ")
        }
    }
    mutating func toggleIsFavorits(){
        isFavorits.toggle()
    }
    
}
