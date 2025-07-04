//
//  HandView.swift
//  iShuffle
//
//  Created by Tiago Rundle on 6/10/23.
//

import SwiftUI

struct HandView: View {
    
    @EnvironmentObject var model:ViewModel
    
    @State private var columns = Array(repeating: GridItem(spacing:5), count:1)
    
    @State private var taps:Int = 0
    
    var body: some View {
        
        ZStack {
            
            RoundedCorner(radius: 25, corners: [.topLeft, .topRight])
                .foregroundColor(.brown)
                .frame(height: 175)
                .onChange(of: model.myPlayer.cards?.count) { cardCount in
                    if cardCount == 0 {
                        model.myCards = [Card]()
                    }
                }
                .onChange(of: model.myCards.count) { cardCount in
                    if cardCount < 8 {
                        columns = Array(repeating: GridItem(spacing:5), count: cardCount)
                    }
                }
            
            LazyVGrid(columns:columns, spacing:5) {
                ForEach(model.myCards, id: \.self) { card in
                    Image(card.rank + "_of_" + card.suit)
                        .resizable()
                        .frame(width:50, height:77)
                        .onTapGesture (count: 2) {
                            taps += 1
                            if taps == 1 {
                                var removedCard = model.myCards.remove(at: model.myCards.firstIndex(of: card)!)
                                if removedCard.faceDown == false {
                                    removedCard.turnCard()
                                }
                                removedCard.moveToRectangle(id: model.myPlayer.id ?? 99, screenWidth: UIScreen.main.bounds.width)
                                model.handToFree(cardAdded: removedCard)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    taps = 0
                                }
                            }
                        }
                        .gesture(DragGesture(minimumDistance: 3.0, coordinateSpace: .local)
                            .onEnded { value in
                                let sourceIndex = model.myCards.firstIndex(of: card)!
                                var destinationIndex = sourceIndex
                                switch (value.translation.width, value.translation.height) {
                                    case(...0, -30...30): destinationIndex = sourceIndex - 1
                                    case(0..., -30...30): destinationIndex = sourceIndex + 1
                                    case(-100...100, ...0): destinationIndex = sourceIndex - 7
                                    case(-100...100, 0...): destinationIndex = sourceIndex + 7
                                    default: print("no clue")
                                }
                                if (destinationIndex > -1 && destinationIndex < model.myCards.count) {
                                    model.myCards.swapAt(destinationIndex, sourceIndex)
                                }
                            }
                        )
                        .animation(.spring())
                }
            }
            .padding()
        }
        
    }
    
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {//ext and struct: choose which corners are round
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}

struct RoundedCorner: Shape {

    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
    
}

