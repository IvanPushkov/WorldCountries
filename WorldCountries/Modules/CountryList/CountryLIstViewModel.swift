

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
        isLoading = true
        aPIManager.fetchAllCountries { data, error in
            guard error == nil, let data = data else {
                self.showingAlert = true
                return
            }
            self.allCellModels = data.data.objects.map { CountryCellModel(country: $0) }
            self.markFavorit()
            self.cellModels = self.allCellModels
            self.isLoading = false
            self.showingAlert = false
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
