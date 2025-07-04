//
//  MenuView.swift
//  iShuffle
//
//  Created by Tiago Rundle on 6/17/23.
//

import SwiftUI

struct MenuView: View {
    
    @EnvironmentObject var model:ViewModel
    
    @Binding var showMenu:Bool
    
    @Binding var showPot:Bool
    @Binding var enableChipCount:Bool
    @Binding var enableCardCount:Bool
    @Binding var enableDealerButton:Bool
    @Binding var enableDiscardPile:Bool
    @Binding var shuffleOnReset:Bool
    @Binding var reshuffleDiscardPile:Bool
    
    let picker:[String] = ["Actions", "Options"]
    
    init(showMenu:Binding<Bool>, showPot:Binding<Bool>, enableChipCount:Binding<Bool>, enableCardCount:Binding<Bool>, enableDealerButton:Binding<Bool>, enableDiscardPile:Binding<Bool>, shuffleOnReset:Binding<Bool>, reshuffleDiscardPile:Binding<Bool>) {
        self._showMenu = showMenu
        self._showPot = showPot
        self._enableChipCount = enableChipCount
        self._enableCardCount = enableCardCount
        self._enableDealerButton = enableDealerButton
        self._enableDiscardPile = enableDiscardPile
        self._shuffleOnReset = shuffleOnReset
        self._reshuffleDiscardPile = reshuffleDiscardPile
        UISegmentedControl.appearance().selectedSegmentTintColor = UIColor.blue
        UISegmentedControl.appearance().setTitleTextAttributes([.font: UIFont.systemFont(ofSize: 20)], for: .normal)
    }
    
    var body: some View {
        
        ZStack {
            
            Color.black
            
            VStack {
                
                HStack {
                    Button() {
                        showMenu.toggle()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                            .font(.largeTitle)
                            .padding()
                    }
                    Spacer()
                    Text("**Game Menu**")
                        .foregroundColor(.white)
                        .font(.largeTitle)
                    Spacer()
                    Image(systemName: "xmark")
                        .foregroundColor(.black)
                        .font(.largeTitle)
                        .padding()
                }
                
                Picker(
                    selection: $model.selection,
                    label: Text("Picker"),
                    content: {
                        ForEach(picker.indices, id: \.self) { index in
                            Text(picker[index])
                                .tag(picker[index])
                        }
                    })
                .pickerStyle(SegmentedPickerStyle())
                .frame(height: 50)
                
                Spacer()
                
                if model.selection == "Actions" {
                    
                    if (model.myPlayer.role == "host") {
                        Button() {
                            model.resetCards()
                        } label: {
                            Text("Reset Cards")
                                .frame(width: 300, height:75)
                                .foregroundColor(.white)
                                .background(.orange)
                                .cornerRadius(20)
                                .font(.title)
                                .fontWeight(.semibold)
                        }
                        
                        Button() {
                            model.shuffleDeck()
                        } label: {
                            Text("Shuffle Deck")
                                .frame(width: 300, height:75)
                                .foregroundColor(.white)
                                .background(.orange)
                                .cornerRadius(20)
                                .font(.title)
                                .fontWeight(.semibold)
                        }
                        
                        Button() {
                            model.resetChips()
                            model.activityFeed.messages.append(Message(text: "The chips have been reset...", color: "white"))
                            model.updateActivityFeed()
                        } label: {
                            Text("Reset Chips")
                                .frame(width: 300, height:75)
                                .foregroundColor(.white)
                                .background(.orange)
                                .cornerRadius(20)
                                .font(.title)
                                .fontWeight(.semibold)
                        }
                    } else {
                        Text("Only the host of the game is able to perform actions such as resetting and shuffling...")
                            .padding(30)
                    }
                    
                } else {
                    Group {
                        Toggle(isOn: $enableCardCount, label: {Text("Show Card Counts")})
                            .padding(.horizontal, 75)
                        Toggle(isOn: $enableChipCount, label: {Text("Show Chip Counts")})
                            .padding(.horizontal, 75)
                        Toggle(isOn: $showPot, label: {Text("Show Pot")})
                            .padding(.horizontal, 75)
                        if model.myPlayer.role == "host" {
                            Toggle(isOn: $shuffleOnReset, label: {Text("Shuffle on Reset")})
                                .padding(.horizontal, 75)
                            Toggle(isOn: $enableDealerButton, label: {Text("Enable Dealer Button")})
                                .padding(.horizontal, 75)
                            Toggle(isOn: $enableDiscardPile, label: {Text("Enable Discard Pile")})
                                .padding(.horizontal, 75)
                            if enableDiscardPile {
                                Toggle(isOn: $reshuffleDiscardPile, label: {Text("Reshuffle Discard Pile")})
                                    .padding(.horizontal, 75)
                            }
                        }
                    }
                    .onChange(of: model.enableDiscardPile) { newValue in
                        model.updateDiscardPileStatus()
                    }
                    .onChange(of: model.enableDealerButton) { newValue in
                        model.updateDealerButtonStatus()
                        model.dealerButton.offsetWidth = 0
                        model.dealerButton.offsetHeight = -150
                        model.dealerButton.newsetWidth = 0
                        model.dealerButton.newsetHeight = -150
                        model.updateDealerButton()
                    }
                }
            
                Spacer()
                
                Text("Join Code: " + (model.game?.joinCode ?? ""))
                    .foregroundColor(.white)
                    .font(.title)
                
                if model.myPlayer.role == "host" {
                    Button() {
                        model.leaving = true
                        model.destroyGame()
                    } label: {
                        Text("End Game")
                            .frame(width: 300, height:75)
                            .foregroundColor(.white)
                            .background(.red)
                            .cornerRadius(20)
                            .font(.title)
                            .fontWeight(.semibold)
                    }
                } else {
                    Button() {
                        model.leaving = true
                        model.removeMyPlayer()
                    } label: {
                        Text("Quit Game")
                            .frame(width: 300, height:75)
                            .foregroundColor(.white)
                            .background(.red)
                            .cornerRadius(20)
                            .font(.title)
                            .fontWeight(.semibold)
                    }
                }
                
            }
        }
    }
}
