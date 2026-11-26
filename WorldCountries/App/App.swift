import SwiftUI

@main
@MainActor
struct WorldCountries: App {
    @StateObject private var countryListModel = CountryListViewModel()

    var body: some Scene {
        WindowGroup {
            CountryListView(countryListModel: countryListModel)
        }
    }
}
