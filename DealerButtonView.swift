//
//  DealerButtonView.swift
//  iShuffle
//
//  Created by Tiago Rundle on 6/29/23.
//

import SwiftUI

struct DealerButtonView: View {
    
    @EnvironmentObject var model:ViewModel
    
    var body: some View {
        
        ZStack {
            Circle()
                .frame(width: 75, height: 75)
            Image("dealer-button")
                .resizable()
                .frame(width:75, height:75)
        }
        .offset(x: model.dealerButton.offsetWidth, y: model.dealerButton.offsetHeight)
        .gesture(
            DragGesture()
                .onChanged({g in
                    
                    if (g.translation.height + model.dealerButton.newsetHeight > 252) {
                        model.dealerButton.offsetWidth = g.translation.width + model.dealerButton.newsetWidth
                        model.dealerButton.offsetHeight = model.dealerButton.offsetHeight
                        
                    } else {
                        model.dealerButton.offsetWidth = g.translation.width + model.dealerButton.newsetWidth
                        model.dealerButton.offsetHeight = g.translation.height + model.dealerButton.newsetHeight
                    }
                    model.updateDealerButton()
                    
                })
                .onEnded({ end in

                    model.dealerButton.newsetWidth = model.dealerButton.offsetWidth
                    model.dealerButton.newsetHeight = model.dealerButton.offsetHeight
                    model.updateDealerButton()
                    
                })
        )
    }
}

struct DealerButton: Codable, Equatable {
    var offsetWidth:CGFloat = 0
    var offsetHeight:CGFloat = -150
    var newsetWidth:CGFloat = 0
    var newsetHeight:CGFloat = -150
}
