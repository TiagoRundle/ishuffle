//
//  BottomBarView.swift
//  iShuffle
//
//  Created by Tiago Rundle on 6/11/23.
//

import SwiftUI

struct BottomBarView: View {
    
    @EnvironmentObject var model:ViewModel
    
    @Binding var showHelp:Bool
    @Binding var showChat:Bool
    @Binding var showBet:Bool
    @Binding var showMenu:Bool
    
    var body: some View {
        
        ZStack {
            Rectangle().fill(.black)
                .edgesIgnoringSafeArea(.all)
            HStack {
                Spacer()
                Button {
                    showMenu.toggle()
                } label: {
                    Image(systemName: "list.bullet").foregroundColor(.white)
                        .font(.system(size: 40))
                }
                Spacer()
                Button {
                    showBet.toggle()
                } label: {
                    Image("poker-chips-button")
                        .resizable()
                        .frame(width: 50, height: 50)
                }
                Spacer()
                Button {
                    showChat.toggle()
                } label: {
                    if model.unreadMessages {
                        Image(systemName: "exclamationmark.bubble.fill")
                            .font(.system(size:35))
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(.red, .white)
                    }
                    else {
                        Image(systemName: "bubble.left.fill").foregroundColor(.white)
                            .font(.system(size: 35))
                    }
                }
                Spacer()
                Button {
                    showHelp.toggle()
                } label: {
                    Image(systemName: "questionmark.circle.fill").foregroundColor(.white)
                        .font(.system(size: 40))
                }
                Spacer()
            }
            .padding()
        }
        
    }
}
