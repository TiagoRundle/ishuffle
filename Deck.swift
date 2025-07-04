//
//  Deck.swift
//  iShuffle
//
//  Created by Tiago Rundle on 3/5/23.
//

import SwiftUI
import Foundation

struct Deck: Codable, Equatable {
    
    var cards = [Card]()
    
    init(decks:Int) {
        let maxZ = -1 + decks*52
        let suits = ["spades", "clubs", "diamonds", "hearts"]
        let ranks = ["ace", "2", "3", "4", "5", "6", "7", "8", "9", "10", "jack", "queen", "king"]
        var count = 0
        var i = 0
        while i < decks {
            for suit in suits {
                for rank in ranks {
                    cards.append(Card(id: count, s:suit, r:rank, z: maxZ - count))
                    count += 1
                }
            }
            i += 1
        }
    }
    
}
