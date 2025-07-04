//
//  PlayerRectangleView.swift
//  iShuffle
//
//  Created by Tiago Rundle on 3/31/23.
//

import SwiftUI

struct PlayerRectangleView:View {
    
    @EnvironmentObject var model:ViewModel
    
    var id:Int
    var center:CGSize
    var color:String
    
    var body: some View {
        
        ZStack {
            Color[color]
            VStack (spacing: 3) {
                if model.game?.players.count ?? 0 > id {
                    Text(model.game?.players[id].displayName ?? "")
                        .foregroundColor(.black)
                        .font(.largeTitle)
                        .scaledToFit()
                        .minimumScaleFactor(0.01)
                        .lineLimit(1)
                        .padding(.horizontal, 5)
                
                    if model.enableCardCount {
                        HStack (spacing:5) {
                            Text("x" + String(model.game?.players[id].cards?.count ?? 0))
                                .foregroundColor(.black)
                            Image("card back red")
                                .resizable()
                                .frame(width:18, height:28)
                        }
                    }
                    if model.enableChipCount {
                        HStack (spacing:5) {
                            Text("x" + String(model.game?.players[id].chipCount ?? 0))
                                .foregroundColor(.black)
                            Image("poker-chip")
                                .resizable()
                                .frame(width:25, height: 25)
                        }
                    }
                }
            }
        }
        .cornerRadius(15)
        .offset(x:center.width, y:center.height)
        
    }
    
    init(playerID:Int) {
        id = playerID
        let distance = UIScreen.main.bounds.width/2 - 50
        switch id {
            case 0:
                center = CGSize(width: distance * -1, height: -189)
                color = "red"
            case 1:
                center = CGSize(width: distance * -1, height: -63)
                color = "orange"
            case 2:
                center = CGSize(width: distance * -1, height: 63)
                color = "lightOrange"
            case 3:
                center = CGSize(width: distance * -1, height: 189)
                color = "yellow"
            case 4:
                center = CGSize(width: distance, height: -189)
                color = "green"
            case 5:
                center = CGSize(width: distance, height: -63)
                color = "blue"
            case 6:
                center = CGSize(width: distance, height: 63)
                color = "lightPurple"
            case 7:
                center = CGSize(width: distance, height: 189)
                color = "purple"
            default:
                color = "UH OH!!"
                center = CGSize(width: 0, height: 0)
        }
    }
    
}
