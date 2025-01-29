//
//  TabBarView.swift
//  WorldCountries
//
//  Created by Ivan Pushkov on 29.01.2025.
//

import SwiftUI

struct TabBarView: View {
    var favoritCompletion: () -> ()
    var allCompletion: () -> () 
    @State var favoritActive: Bool = true

    var body: some View {
        HStack{
            Image(systemName: "heart.fill")
                .font(.system(size: favoritActive ? 30 : 50))
                .foregroundColor(favoritActive ? Color("OfButton") : Color("OnButton"))
                .onTapGesture {
                    withAnimation {
                        if favoritActive{
                            favoritActive.toggle()
                        }
                    }
                    favoritCompletion()
                }
            Spacer()
            Image(systemName: "list.bullet.rectangle.portrait.fill")
                .font(.system(size: favoritActive ? 50 : 30))
                .foregroundColor(favoritActive ? Color("OnButton") : Color("OfButton"))
                .onTapGesture {
                    withAnimation {
                        if !favoritActive{
                            favoritActive.toggle()
                        }
                    }
                    allCompletion()
                }
                
        }
        .padding(.horizontal, 45)
        .background(Color("TabBarBg"))
    }
}


