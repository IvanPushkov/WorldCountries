

import SwiftUI


struct SearchTextField : View{
    @Binding var searchText: String
    var body: some View{
        TextField("Search", text: $searchText)
            .textFieldStyle(.roundedBorder)
            .padding(5)
    }
}
