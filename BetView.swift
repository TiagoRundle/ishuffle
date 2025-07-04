//
//  BetView.swift
//  iShuffle
//
//  Created by Tiago Rundle on 6/13/23.
//

import SwiftUI

struct BetView: View {
    
    @EnvironmentObject var model:ViewModel
    
    @Binding var showBet:Bool
    
    @State var betValue:Double = 5
    @State var takeValue:Double = 0
    @State var betSelection:String = "Bet"
    @State var activitySelection:String = "Activity Feed"
    
    let activityPicker:[String] = ["Activity Feed", "Chip Counts"]
    let betPicker:[String] = ["Bet", "Take"]
    
    init(showBet:Binding<Bool>) {
        self._showBet = showBet
        UISegmentedControl.appearance().selectedSegmentTintColor = UIColor.blue
        UISegmentedControl.appearance().setTitleTextAttributes([.font: UIFont.systemFont(ofSize: 20)], for: .normal)
    }
    
    var body: some View {
        
        ZStack {
            
            Color.black
            
            VStack (spacing: 10) {

                HStack {
                    Button() {
                        showBet.toggle()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                            .font(.largeTitle)
                            .padding()
                    }
                    Spacer()
                    Text("**Betting**")
                        .foregroundColor(.white)
                        .font(.largeTitle)
                    Spacer()
                    Image(systemName: "xmark")
                        .foregroundColor(.black)
                        .font(.largeTitle)
                        .padding()
                }
                
                Picker(
                    selection: $activitySelection,
                    label: Text("Picker"),
                    content: {
                        ForEach(activityPicker.indices, id: \.self) { index in
                            Text(activityPicker[index])
                                .tag(activityPicker[index])
                        }
                    })
                .pickerStyle(SegmentedPickerStyle())
                .frame(height: 25)
                
                if activitySelection == "Activity Feed" {
                    ScrollViewReader { proxy in
                        ScrollView {
                            VStack (alignment: .leading, spacing: 0) {
                                HStack {
                                    Text(model.activityFeed.messages[0].text)
                                        .padding(.bottom, 15)
                                        .font(.title3)
                                        .padding(.leading, 20)
                                    Spacer()
                                }
                                
                                ForEach(model.activityFeed.messages.indices, id: \.self) { index in
                                    if index != 0 {
                                        Text(model.activityFeed.messages[index].text)
                                            .foregroundColor(Color[model.activityFeed.messages[index].color])
                                            .font(.title3)
                                            .padding(.leading, 20)
                                    }
                                }
                                .padding(.bottom, 15)
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .preferredColorScheme(.dark)
                        .onAppear {
                            withAnimation {
                                proxy.scrollTo(model.activityFeed.messages.count - 1, anchor: .bottom)
                            }
                        }
                        .onChange(of: model.activityFeed.messages.count - 1) { id in
                            withAnimation {
                                proxy.scrollTo(id, anchor: .bottom)
                            }
                        }
                    }
                } else {
                    Spacer()
                    VStack (spacing: 5) {
                        ForEach(0..<8) { index in
                            if index >= model.game!.players.count {
                                Text("--------")
                            } else {
                                Text(model.game!.players[index].displayName + ": " + String(model.game!.players[index].chipCount))
                                    .font(.title3)
                                    .foregroundColor(Color[model.game!.players[index].color!])
                                    .bold()
                            }
                        }
                    }
                    Spacer()
                }
                
                HStack (spacing: 40) {
                    Text("My Chips: " + String(model.game!.players[model.myPlayer.id!].chipCount))
                        .font(.title3)
                        .foregroundColor(.white)
                    Text("Pot: " + String(model.pot))
                        .font(.title3)
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50) //75
                .background(.gray)
                
                Picker(
                    selection: $betSelection,
                    label: Text("Picker"),
                    content: {
                        ForEach(betPicker.indices, id: \.self) { index in
                            Text(betPicker[index])
                                .tag(betPicker[index])
                        }
                    })
                .pickerStyle(SegmentedPickerStyle())
                .frame(height: 75)
                .onChange(of: betSelection) { _ in
                    takeValue = Double(model.pot)
                }
                
                if betSelection == "Bet" {
                    if model.game!.players[model.myPlayer.id!].chipCount > 0 {
                        HStack(spacing: 20) {
                            Button ("-") {
                                if betValue > 5 {
                                    betValue -= 5
                                }
                            }
                            .foregroundColor(.white)
                            .font(.system(size: 60))
                            .padding(.leading)
                            if model.game!.players[model.myPlayer.id!].chipCount > 5 {
                                Slider(value: $betValue, in: 5...Double(model.game!.players[model.myPlayer.id!].chipCount), step:5.0)
                            } else {
                                Slider(value: $betValue, in: 5...5)
                            }
                            Button("+") {
                                if betValue < Double(model.game!.players[model.myPlayer.id!].chipCount) {
                                    betValue += 5
                                }
                            }
                            .foregroundColor(.white)
                            .font(.system(size: 50))
                            .padding(.trailing)
                        }
                        Button {
                            model.activityFeed.messages.append(Message(text: "> " + model.myPlayer.displayName + " has bet " + String(format: "%.0f", betValue), color: model.myPlayer.color!))
                            model.updateActivityFeed()
                            model.game!.players[model.myPlayer.id!].chipCount -= Int(betValue)
                            model.pot += Int(betValue)
                            model.updateChips(player:model.game!.players[model.myPlayer.id!])
                            betValue = 5
                        } label: {
                            Text("Bet " + String(format: "%.0f", betValue))
                                .frame(maxWidth: .infinity)
                                .frame(height: 100)
                                .font(.largeTitle)
                                .background(.green)
                                .foregroundColor(.white)
                        }
                    } else {
                        Text("You have no more chips to bet!")
                            .font(.largeTitle)
                            .frame(maxWidth: .infinity)
                            .frame(height: 182)
                            .background(.red)
                    }
                } else {
                    if model.pot > 0 {
                        HStack(spacing: 20) {
                            Button ("-") {
                                if takeValue > 5 {
                                    takeValue -= 5
                                }
                            }
                            .foregroundColor(.white)
                            .font(.system(size: 60))
                            .padding(.leading)
                            if model.pot > 5 {
                                Slider(value: $takeValue, in: 5...Double(model.pot), step: 5.0)
                            } else {
                                Slider(value: $takeValue, in: 5...5)
                            }
                            Button("+") {
                                if takeValue < Double(model.pot) {
                                    takeValue += 5
                                }
                            }
                            .foregroundColor(.white)
                            .font(.system(size: 50))
                            .padding(.trailing)
                        }
                        Button {
                            model.activityFeed.messages.append(Message(text: "> " + model.myPlayer.displayName + " has taken " + String(format: "%.0f", takeValue) + " from the pot", color: model.myPlayer.color!))
                            model.updateActivityFeed()
                            model.game!.players[model.myPlayer.id!].chipCount += Int(takeValue)
                            model.pot -= Int(takeValue)
                            model.updateChips(player:model.game!.players[model.myPlayer.id!])
                            betSelection = "Bet"
                        } label: {
                            Text("Take " + String(format: "%.0f", takeValue))
                                .frame(maxWidth: .infinity)
                                .frame(height: 100)
                                .font(.largeTitle)
                                .background(.orange)
                                .foregroundColor(.white)
                        }
                    } else {
                        Text("The pot is empty!")
                            .font(.largeTitle)
                            .frame(maxWidth: .infinity)
                            .frame(height: 182)
                            .background(.red)
                    }
                }
                
            }
        }
        .preferredColorScheme(.dark)
        
    }
}

extension UISegmentedControl {
    override open func didMoveToSuperview() {
        super.didMoveToSuperview()
        self.setContentHuggingPriority(.defaultLow, for: .vertical)
    }
}
