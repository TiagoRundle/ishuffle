//
//  DiscardedCardsView.swift
//  iShuffle
//
//  Created by Tiago Rundle on 8/4/23.
//

import SwiftUI

struct DiscardedCardsView: View {
    
    @EnvironmentObject var model:ViewModel
    
    @Binding var showDiscard:Bool
    
    var body: some View {
        
        VStack(spacing:0) {
            HStack {
                Button() {
                    showDiscard.toggle()
                } label: {
                    Image(systemName: "xmark")
                        .foregroundColor(.white)
                        .font(.largeTitle)
                        .padding()
                }
                Spacer()
                Text("**Discard Pile**")
                    .foregroundColor(.white)
                    .font(.largeTitle)
                Spacer()
                ZStack {
                    Image(systemName: "xmark")
                        .opacity(0.0)
                        .font(.largeTitle)
                        .padding()
                    HStack (spacing:5) {
                        Text("x" + String(model.discardPile.cards.count))
                        Image("card back red")
                            .resizable()
                            .frame(width:18, height:28)
                    }
                }
            }
            .background(Color["darkGray"])
            .frame(width: 350)
            Text("Top")
                .frame(width: 350)
                .background(.gray)
            ScrollView {
                VStack {
                    ForEach(model.discardPile.cards.indices.reversed(), id: \.self) { index in
                        Image(model.discardPile.cards[index].rank + "_of_" + model.discardPile.cards[index].suit)
                            .resizable()
                            .frame(width:72, height:112)
                            .onTapGesture(count:2) {
                                if model.myCards.count >= 14 {return}
                                if (model.game!.players[model.myPlayer.id!].cards == nil) {
                                    model.game!.players[model.myPlayer.id!].cards = [Card]()
                                }
                                model.game!.players[model.myPlayer.id!].cards!.append(model.discardPile.cards[index])
                                model.discardToHand(cardAdded: model.game!.players[model.myPlayer.id!].cards!.last!, player: model.game!.players[model.myPlayer.id!])
                            }
                    }
                }
                .padding(35)
                .frame(width: 350)
            }
            .background(.ultraThinMaterial)
            .frame(height: 550)
            Text("Bottom")
                .frame(width: 350)
                .background(.gray)
        }
             
    }
    
}

struct DiscardPileView: View {
    
    @EnvironmentObject var model:ViewModel
    
    @Binding var showDiscard:Bool
    
    var body: some View {
        
        ZStack {
            RoundedRectangle(cornerRadius: 15, style: .continuous).fill(.black)
                .frame(width: 81, height: 126)
            
            Button {
                showDiscard.toggle()
            } label: {
                Image(systemName: "trash").font(.system(size: 50))
                    .foregroundColor(.white)
            }
                
        }
             
    }
    
}


