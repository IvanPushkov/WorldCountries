

import SwiftUI


protocol CountryListViewModelProtocol: ObservableObject{
    var showingAlert: Bool {get set}
    var isLoading: Bool {get set}
   
    func fetchData()
}

class CountryListViewModel: CountryListViewModelProtocol{
    
    var allCellModels: [CountryCellModel] = []
    @Published var searchText: String = "" {
        didSet{
            filterData()
        }
    }
    @Published var isLoading: Bool = true
    @Published var showingAlert: Bool = false
    @Published var cellModels: [CountryCellModel] = []
    
    private let aPIManager = APIManager()
    func fetchData() {
        aPIManager.fetchAllCountries(){[self] data, error in
            if error == nil{
                allCellModels = data!.map{ CountryCellModel(country: $0)
                }
                cellModels = allCellModels
                isLoading = false
            } else {
                showingAlert = true
            }
        }
    }
    private func filterData() {
        cellModels = allCellModels
        cellModels = searchText.isEmpty
                ? cellModels
                : cellModels.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        print(cellModels.count)
    }

     func changeisFavoritIn(_ country: CountryCellModel){
        if let index = allCellModels.firstIndex(where: { $0.id == country.id }) {
                    allCellModels[index].isFavorits.toggle()
                }
    }
    
}
