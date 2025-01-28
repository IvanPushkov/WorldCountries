

import SwiftUI


protocol CountryListViewModelProtocol: ObservableObject{
    var showingAlert: Bool {get set}
    var isLoading: Bool {get set}
    var cellModels: [CountryCellModel] {get set}
    
    func fetchData()
}

class CountryListViewModel: CountryListViewModelProtocol{
    @Published var isLoading: Bool = true
    @Published var cellModels: [CountryCellModel] = []
    @Published var showingAlert: Bool = false
    private let aPIManager = APIManager()
    func fetchData() {
        aPIManager.fetchAllCountries(){[self] data, error in
            if error == nil{
                cellModels = data!.map{ CountryCellModel(country: $0)
                }
                isLoading = false
            } else {
                showingAlert = true
            }
        }
    }
    
    
}
