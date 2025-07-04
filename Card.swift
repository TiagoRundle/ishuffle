//
//  Card.swift
//  iShuffle
//
//  Created by Tiago Rundle on 3/3/23.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

struct Card: Codable, Equatable, Hashable {
    
    static var colors = ["yellow", "blue", "pink", "white", "orange", "green", "purple", "red"]
    
    var id:Int?
    let suit:String
    let rank:String
    var imageName = "card back red"
    var faceDown = true
    var offset = CGSize.zero
    var newset = CGSize.zero
    var isDragging = false
    var zIndex:Int
    
    init(id:Int, s:String, r:String, z:Int) {
        suit = s
        rank = r
        self.id = id
        zIndex = z
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    mutating func turnCard() {
        if (faceDown) {
            imageName = rank + "_of_" + suit
        }
        else {
            imageName = "card back red"
        }
        faceDown.toggle()
    }
    
    mutating func moveToRectangle(id:Int, screenWidth:CGFloat) {
        let distance = screenWidth/2 - 50
        switch id {
            case 0:
                offset.width = distance * -1
                offset.height = -189
            case 1:
                offset.width = distance * -1
                offset.height = -63
            case 2:
                offset.width = distance * -1
                offset.height = 63
            case 3:
                offset.width = distance * -1
                offset.height = 189
            case 4:
                offset.width = distance
                offset.height = -189
            case 5:
                offset.width = distance
                offset.height = -63
            case 6:
                offset.width = distance
                offset.height = 63
            case 7:
                offset.width = distance
                offset.height = 189
            default:
                offset.width = 0
                offset.height = 0
        }
        newset = offset
    }
    
    func checkRectangles(playerCount:Int, screenWidth:Int) -> Int {
        let distance = screenWidth/2 - 50
        
        if (Int(offset.height) > 170-20 && Int(offset.height) < 170+20 && Int(offset.width) < 14 && Int(offset.width) > -14) {
            return -1
        }
        
        if (Int(offset.height) > -189-14 && Int(offset.height) < -189+14 && Int(offset.width) < (distance * -1)+14) {
            return 0
        }
        
        if (playerCount > 1 && Int(offset.height) > -63-14 && Int(offset.height) < -63+14 && Int(offset.width) < (distance * -1)+14) {
            return 1
        }
        
        if (playerCount > 2 && Int(offset.height) > 63-14 && Int(offset.height) < 63+14 && Int(offset.width) < (distance * -1)+14) {
            return 2
        }
        
        if (playerCount > 3 && Int(offset.height) > 189-14 && Int(offset.height) < 189+14 && Int(offset.width) < (distance * -1)+14) {
            return 3
        }
        
        if (playerCount > 4 && Int(offset.height) > -189-14 && Int(offset.height) < -189+14 && Int(offset.width) > distance-14) {
            return 4
        }
        
        if (playerCount > 5 && Int(offset.height) > -63-14 && Int(offset.height) < -63+14 && Int(offset.width) > distance-14) {
            return 5
        }
        
        if (playerCount > 6 && Int(offset.height) > 63-14 && Int(offset.height) < 63+14 && Int(offset.width) > distance-14) {
            return 6
        }
        
        if (playerCount > 7 && Int(offset.height) > 189-14 && Int(offset.height) < 189+14 && Int(offset.width) > distance-14) {
            return 7
        }
        
        return 99
        
    }
    
}

/*extension UTType {
    static var layer: UTType { UTType (exportedAs: "com.exmple.layer")}
}

extension Card: Transferable {
    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .layer)
    }
}*/
