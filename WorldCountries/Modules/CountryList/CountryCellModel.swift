

import Foundation



struct CountryCellModel: Identifiable{
  
    
    private let country: Country
    var id = UUID()
    
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
        name = country.name.common
        flag = country.flag
        region = country.region
        
        capital = country.capital?.first
        population = "\(country.population) people"
        area = "\(country.area) km²"
        languages = country.languages?.values.sorted()
        timezones = country.timezones?.joined(separator: ", ") ?? "Unknown Timezones"
        coordinates = country.coordinates
        isFavorits = false
        self.currency = "Unknown Currency"
        setCurrency(country.currencies)
    }
    
    private mutating func setCurrency(_ currencies: [String: Currency]?) {
        if let currencies = currencies, !currencies.isEmpty {
            var currencyList: [String] = []
            for currency in currencies.values {
                let currencyString = "\(currency.name) \(currency.symbol )"
                currencyList.append(currencyString)
            }
            self.currency = currencyList.joined(separator: ", ")
        }
    }
    mutating func toggleIsFavorits(){
        isFavorits.toggle()
    }
    
}
