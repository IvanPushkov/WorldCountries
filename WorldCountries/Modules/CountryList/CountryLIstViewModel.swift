

import SwiftUI


protocol CountryListViewModelProtocol: ObservableObject{
    var showingAlert: Bool {get set}
    var isLoading: Bool {get set}
   
    func fetchData()
}

class CountryListViewModel: CountryListViewModelProtocol{
    let coreDataManager =  CoreDataManager.shared
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
                markFavorit()
                cellModels = allCellModels
                allCellModels.forEach { print($0.capital ?? "") }
                allCellModels.forEach { print($0.currency) }
                allCellModels.forEach { print($0.languages ?? "") }
                allCellModels.forEach { print($0.region) }
                isLoading = false
            } else {
                showingAlert = true
            }
        }
    }
    private func markFavorit(){
        var markedModels = [CountryCellModel]()
        for model in allCellModels{
            var copy = model
            if coreDataManager.fetchCountries().contains(model.name){
                copy.isFavorits = true
            }
            markedModels.append(copy)
        }
        allCellModels = markedModels
    }
    
    private func filterData() {
        cellModels = allCellModels
        cellModels = searchText.isEmpty ? cellModels : cellModels.filter {
            $0.name.lowercased().contains(searchText.lowercased())
        }
    }
    
    func changeIsFavoritIn(_ country: CountryCellModel){
        if let index = allCellModels.firstIndex(where: { $0.name == country.name }) {
                    allCellModels[index].isFavorits.toggle()
                }
        country.isFavorits ? coreDataManager.saveNewCountry(country: country) : coreDataManager.deleteCountry(country: country)
    }
    func returnFavoriteCountries(){
        var favorits = [CountryCellModel]()
        for cellModel in allCellModels{
            if cellModel.isFavorits{
                favorits.append(cellModel)
            }
        }
        cellModels = favorits
    }
    func returnAllCountries(){
        cellModels = allCellModels
    }
    
}
