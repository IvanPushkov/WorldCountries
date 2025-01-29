

import SwiftUI

struct CountryListView: View {
    @StateObject var countryListModel = CountryListViewModel()
    
    var body: some View {
        ZStack{
            if countryListModel.isLoading{
                CustomLoadView(isLoading: countryListModel.isLoading)
    
            } else {
                NavigationStack{
                    SearchTextField(searchText: $countryListModel.searchText)
                    List($countryListModel.cellModels, id: \.name) { $countryCellModel in
                        CountryCell(countryCellModel: $countryCellModel, completion: { cellModel in
                            countryListModel.changeIsFavoritIn(cellModel)
                        })
                            .background{
                                NavigationLink(destination: CountryView(countryModell: $countryCellModel, complection: {cellModel in
                                    countryListModel.changeIsFavoritIn(cellModel)
                                })){
                                }
                                    .opacity(0)
                            }
                    }
                    TabBarView(favoritCompletion: countryListModel.returnFavoriteCountries, allCompletion: countryListModel.returnAllCountries)
                    .navigationTitle("world_countries")
                }
            }
        }
        .onAppear(){
            countryListModel.fetchData()
        }
        .alert(isPresented: $countryListModel.showingAlert){
            Alert(title: Text("no_internet"),
                  message: Text("connection_error"),
                  dismissButton: .default(Text("retry")){
                countryListModel.fetchData()
            })
        }
    }
}

