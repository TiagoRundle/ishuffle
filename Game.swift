//
//  Game.swift
//  iShuffle
//
//  Created by Tiago Rundle on 2/17/23.
//

import Foundation

struct Game: Codable {
    
    var id:String
    var players = [Player]()
    var joinCode:String
    
}
