//
//  TabBarView.swift
//  WorldCountries
//
//  Created by Ivan Pushkov on 29.01.2025.
//

import SwiftUI

struct TabBarView: View {
    var favoritComplection: () -> ()
    var allComplection: () -> () 
    @State var favoritActive: Bool = true

    var body: some View {
        HStack{
            Image(systemName: "heart.fill")
                .font(.system(size: favoritActive ? 30 : 50))
                .foregroundColor(favoritActive ? Color.black : Color.red)
                .onTapGesture {
                    withAnimation {
                        if favoritActive{
                            favoritActive.toggle()
                        }
                    }
                    favoritComplection()
                }
            Spacer()
            Image(systemName: "list.bullet.rectangle.portrait.fill")
                .font(.system(size: favoritActive ? 50 : 30))
                .foregroundColor(favoritActive ? Color.red : Color.black)
                .onTapGesture {
                    withAnimation {
                        if !favoritActive{
                            favoritActive.toggle()
                        }
                    }
                    allComplection()
                }
                
        }
        .padding(.horizontal, 45)
        .background(.gray)
    }
}


