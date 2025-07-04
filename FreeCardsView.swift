//
//  FreeCardsView.swift
//  iShuffle
//
//  Created by Tiago Rundle on 6/10/23.
//

import SwiftUI

struct CardArea: Codable, Equatable {
    
    var cards = [Card]()
    
}

struct FreeCardsView: View {
    
    @EnvironmentObject var model:ViewModel
    
    @State var doOnce = true
    
    func outOfBoundsY(y:CGFloat) -> Bool {
        if y > 252 || y < -252 {
            return true
        }
        return false
    }
    func outOfBoundsX(x:CGFloat) -> Bool {
        if x > (UIScreen.main.bounds.width/2 - 27) || x < -1*(UIScreen.main.bounds.width/2 - 27) {
            return true
        }
        return false
    }
    
    var body: some View {
        
        ForEach(model.freeArea.cards.indices, id: \.self) {index in
            Image(model.freeArea.cards[index].imageName)
                .resizable()
                .frame(width:54, height:84)
                .offset(x: model.freeArea.cards[index].offset.width, y: model.freeArea.cards[index].offset.height)
                .gesture(
                    DragGesture()
                        .onChanged { g in
                            if (model.freeArea.cards[index].zIndex != model.maxZ && doOnce) {
                                model.updateZIndex(cardIndex: index)
                                doOnce = false
                            }
                            if (outOfBoundsY(y: g.translation.height + model.freeArea.cards[index].newset.height) && outOfBoundsX(x: g.translation.width + model.freeArea.cards[index].newset.width)) {
                                model.freeArea.cards[index].offset = CGSize(width: model.freeArea.cards[index].offset.width, height: model.freeArea.cards[index].offset.height)
                            }
                            else if (outOfBoundsY(y: g.translation.height + model.freeArea.cards[index].newset.height)) {
                                model.freeArea.cards[index].offset = CGSize(width: g.translation.width + model.freeArea.cards[index].newset.width, height: model.freeArea.cards[index].offset.height)
                            } else if (outOfBoundsX(x: g.translation.width + model.freeArea.cards[index].newset.width)) {
                                model.freeArea.cards[index].offset = CGSize(width: model.freeArea.cards[index].offset.width, height: g.translation.height + model.freeArea.cards[index].newset.height)
                            } else {
                                model.freeArea.cards[index].offset = CGSize(width: g.translation.width + model.freeArea.cards[index].newset.width, height: g.translation.height + model.freeArea.cards[index].newset.height)
                            }
                            model.updateOffset(cardToBeUpdated: model.freeArea.cards[index], widthOffset: Int(model.freeArea.cards[index].offset.width), heightOffset: Int(model.freeArea.cards[index].offset.height))
                            
                        }
                        .onEnded { end in
                            
                            doOnce = true
                            
                            model.freeArea.cards[index].newset = model.freeArea.cards[index].offset
                            model.updateNewset(cardToBeUpdated: model.freeArea.cards[index], widthNewset: Int(model.freeArea.cards[index].newset.width), heightNewset: Int(model.freeArea.cards[index].newset.height))
                            
                            let pIndex = model.freeArea.cards[index].checkRectangles(playerCount:model.game!.players.count, screenWidth: Int(UIScreen.main.bounds.width))
                            
                            var player:Player?
                            if (pIndex == 99 || pIndex == -1) {
                                player = nil
                            }
                            else {
                                player = model.game!.players[pIndex]
                            }
                            
                            if (player?.cards?.count ?? 0 >= 14) {
                                return
                            }
                            
                            if (index == model.freeArea.cards.count - 1) {
                                model.deckToFree()
                            }
                            
                            if pIndex == -1 && model.enableDiscardPile {
                                model.discardPile.cards.append(model.freeArea.cards[index])
                                model.freeToDiscard(cardAdded: model.discardPile.cards.last!)
                                let length = model.discardPile.cards.count
                                /*if (model.discardPile.cards[length - 1].faceDown) {
                                    model.discardPile.cards[length - 1].turnCard()
                                }*/
                            } else if pIndex != 99 && pIndex != -1 {
                                
                                if (model.game!.players[pIndex].cards == nil) {
                                    model.game!.players[pIndex].cards = [Card]()
                                }
                                
                                model.game!.players[pIndex].cards!.append(model.freeArea.cards[index])
                                
                                let length = model.game!.players[pIndex].cards!.count
                                if (model.game!.players[pIndex].cards![length - 1].faceDown) {
                                    model.game!.players[pIndex].cards![length - 1].turnCard()
                                }
                                
                                model.freeToHand(cardAdded: model.game!.players[pIndex].cards!.last!, player: player!)
                                
                            }
                            
                            
                            
                        }
                )
                .onTapGesture {
                    model.freeArea.cards[index].turnCard()
                    model.updateCard(cardToUpdate: model.freeArea.cards[index])
                }
                .zIndex(Double(model.freeArea.cards[index].zIndex))
        }
    }
}
