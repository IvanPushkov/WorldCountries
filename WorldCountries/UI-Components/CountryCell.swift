

import SwiftUI

struct CountryCell: View{
    @Binding var countryCellModel: CountryCellModel
    var completion: (CountryCellModel)-> ()
    
    var body: some View{
        HStack {
            Text(countryCellModel.flag)
                .font(.system(size: 60, design: .rounded))
                .padding(.trailing, 20)
                
            VStack(alignment: .leading){
                Text(countryCellModel.name)
                    .font(.system(size: 20, design: .rounded))
                Text(countryCellModel.region)
                    .font(.system(size: 15, design: .rounded))
                    .foregroundColor(Color("GrayText"))
            }
            Spacer()
                Image(systemName: "heart.fill")
                    .font(.system(size: 30))
                    .scaleEffect(countryCellModel.isFavorits ? 1.2 : 1.0)
                    .foregroundColor(countryCellModel.isFavorits ? Color("OnButton") : Color("OfButton"))
            .onTapGesture {
                withAnimation(.spring()) {
                    countryCellModel.toggleIsFavorits()
                    completion(self.countryCellModel)
                }
            }
        }
    }
    
}
