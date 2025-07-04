//
//  HelpView.swift
//  iShuffle
//
//  Created by Tiago Rundle on 6/7/23.
//

import SwiftUI

struct HelpView: View {
    
    @EnvironmentObject var model:ViewModel
    
    @Binding var showHelp:Bool
    
    var body: some View {
        ZStack {
            Color.black
            VStack {
                HStack {
                    Button() {
                        showHelp.toggle()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                            .font(.largeTitle)
                            .padding()
                    }
                    Spacer()
                    Text("**How to Play**")
                        .foregroundColor(.white)
                        .font(.largeTitle)
                    Spacer()
                    Image(systemName: "xmark")
                        .foregroundColor(.black)
                        .font(.largeTitle)
                        .padding()
                }
                ScrollView {
                    Text("About")
                        .font(.title2)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(.gray)
                        .padding(.bottom)
                        .padding(.leading)
                        .padding(.trailing)
                    Text("The purpose of iShuffle is to simulate a real life deck of cards. If you have ever found yourself wanting to play cards, only to be disappointed after not being able to find a physical deck, this could be the solution you were looking for! Unlike other card game apps, there are no rules programmed into iShuffle, so it is up to the player(s) to enforce the rules just like in real life.")
                        .padding(.leading)
                        .padding(.trailing)
                        .font(.title3)
                        .padding()
                    Text("Playing Area")
                        .font(.title2)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(.gray)
                        .padding()
                    Text("The playing area consists of the majority of the screen, and it is visible to all players. When you flip or move a card in the playing area, other players will see it happening in real time. To add cards to a player's hand, simply drag and drop a card into the colored box that corresponds to that player. These colored boxes are where cards are transferred from the playing area to the hand and vice versa.")
                        .padding(.leading)
                        .padding(.trailing)
                        .font(.title3)
                        .padding()
                    Text("Hand")
                        .font(.title2)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(.gray)
                        .padding()
                    Text("Your hand is represented by the light brown box at the bottom of the screen, and it is visible only to you. You can swap the order of your cards by swiping them for organiztion. To remove a card from your hand, double tap it. The removed card will then be transported face down to the colored box in the \"playing area\" that corresponds to you.")
                        .padding(.leading)
                        .padding(.trailing)
                        .font(.title3)
                        .padding()
                    Text("Discard Pile")
                        .font(.title2)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(.gray)
                        .padding()
                    Text("If you choose to play with the built-in discard pile, simply drag cards to the box marked with a trash can icon to discard them. Pressing on the trash can icon will bring up all of the cards in the discard pile, double tap on any of these to take a discarded card and put it into your hand. When the deck runs out and there are cards in the discard pile, you can click on the refresh button to \"flip over\" the discard pile and reshuffle the deck.")
                        .padding(.leading)
                        .padding(.trailing)
                        .font(.title3)
                        .padding()
                    
                    Group {
                        Text("Game Menu")
                            .font(.title2)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(.gray)
                            .padding()
                        Text("Use the menu to reset cards, shuffle cards, reset the chips, quit the game, and toggle options on and off.")
                            .padding(.leading)
                            .padding(.trailing)
                            .font(.title3)
                            .padding()
                        Text("Betting")
                            .font(.title2)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(.gray)
                            .padding()
                        Text("Use the betting window to bet chips and take chips from the pot. It can also be used to view the chip counts of all players and keep track of bets using the activity feed.")
                            .padding(.leading)
                            .padding(.trailing)
                            .font(.title3)
                            .padding()
                        Text("Game Chat")
                            .font(.title2)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(.gray)
                            .padding()
                        Text("Although iShuffle is best played with voice communication, the chat can be used to communicate with remote players via messaging.")
                            .padding(.leading)
                            .padding(.trailing)
                            .font(.title3)
                            .padding()
                    }
                    
                }
                Spacer()
            }
        }
    }
}

