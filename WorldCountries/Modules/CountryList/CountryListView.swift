

import SwiftUI

struct CountryListView: View {
    @StateObject var countryListModel = CountryListViewModel()
    
    var body: some View {
        ZStack{
            if countryListModel.isLoading{
                CustomLoadView()
                    .rotationEffect(Angle(degrees: countryListModel.isLoading ? 360 : 0))
                    .animation(.linear(duration: 1).repeatForever(), value: countryListModel.isLoading)
            } else {
                NavigationStack{
                    SearchTextField(searchText: $countryListModel.searchText)
                    List($countryListModel.cellModels, id: \.name) { $countryCellModel in
                        CountryCell(countryCellModel: $countryCellModel, complection: { cellModel in
                            countryListModel.changeisFavoritIn(cellModel)
                        })
                            .background{
                                NavigationLink(destination: CountryView(countryModell: $countryCellModel, complection: {cellModel in
                                    countryListModel.changeisFavoritIn(cellModel)
                                })){
                                }
                                    .opacity(0)
                            }
                    }
                    TabBarView(favoritComplection: countryListModel.returnFavoritCountries, allComplection: countryListModel.returnAllCuntries)
                    .navigationTitle("World Countries")
                }
            }
        }
        .onAppear(){
            countryListModel.fetchData()
        }
        .alert(isPresented: $countryListModel.showingAlert){
            Alert(title: Text("Отсутствие интернета"), message: Text("Ошибка подключения"), dismissButton: .default(Text("Попробовать еще раз")){
                countryListModel.fetchData()
            })
        }
    }
}


struct SearchTextField : View{
    @Binding var searchText: String
    var body: some View{
        TextField("Search", text: $searchText)
            .textFieldStyle(.roundedBorder)
            .padding(5)
    }
}


