//
//  Player.swift
//  iShuffle
//
//  Created by Tiago Rundle on 2/16/23.
//

import Foundation
import SwiftUI

struct Player: Codable, Equatable {
    
    var id:Int? = nil
    var role:String? = nil
    var displayName:String = ""
    var cards:[Card]? = nil
    var color:String? = nil
    var chipCount = 1000

}

extension Encodable {
    var toDictionary: [String: Any]?{
        guard let data = try? JSONEncoder().encode(self) else {
            return nil
        }
        
        return try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
    }
}

extension Color {
    
    static subscript(name: String) -> Color {
        switch name {
            case "red":
                return Color.myRed
            case "orange":
                return Color.myOrange
            case "lightOrange":
                return Color.myLightOrange
            case "yellow":
                return Color.myYellow
            case "green":
                return Color.myGreen
            case "blue":
                return Color.myBlue
            case "lightPurple":
                return Color.myLightPurple
            case "purple":
                return Color.myPurple
            case "darkGray":
                return Color.myGray
            default:
                return Color.white
        }
    }
    
    public static let myRed:Color = Color(UIColor(red:250/255, green: 144/255, blue: 136/255, alpha: 1.0))
    public static let myOrange:Color = Color(UIColor(red:251/255, green: 174/255, blue: 125/255, alpha: 1.0))
    public static let myLightOrange:Color = Color(UIColor(red:253/255, green: 229/255, blue: 152/255, alpha: 1.0))
    public static let myYellow:Color = Color(UIColor(red:248/255, green: 254/255, blue: 180/255, alpha: 1.0))
    public static let myGreen:Color = Color(UIColor(red:179/255, green: 245/255, blue: 187/255, alpha: 1.0))
    public static let myBlue:Color = Color(UIColor(red:214/255, green: 245/255, blue: 255/255, alpha: 1.0))
    public static let myLightPurple:Color = Color(UIColor(red:225/255, green: 202/255, blue: 246/255, alpha: 1.0))
    public static let myPurple:Color = Color(UIColor(red:209/255, green: 189/255, blue: 255/255, alpha: 1.0))
    public static let myGray:Color = Color(UIColor(red:99/255, green: 102/255, blue: 106/255, alpha: 1.0))
    
}
