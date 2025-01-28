

import SwiftUI
import UIKit
struct CountryCell: View{
     var countryCellModel: CountryCellModel
    @State private var isFavorits: Bool
    
    init(countryCellModell: CountryCellModel){
        self.countryCellModel = countryCellModell
        self.isFavorits = countryCellModell.isFavorits
    }
    
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
                    .foregroundColor(Color.gray)
            }
            Spacer()
            
            ZStack {
                Circle()
                    .frame(width: 60, height: 60)
                    .foregroundColor(Color.primary)
                Image(systemName: "heart.fill")
                    .font(.system(size: 30))
                    .scaleEffect(isFavorits ? 1.2 : 1.0)
                .foregroundColor(isFavorits ? .red : .gray)
                .animation(.default, value: isFavorits)
            }
            .onTapGesture {
                isFavorits.toggle()
            }
        }
    }
    
}
