//
//  ContentView.swift
//  iShuffle
//
//  Created by Tiago Rundle on 2/10/23.
//

import SwiftUI

public let alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

struct ContentView:View {
    
    @State var textFieldText = ""
    @State private var create : Bool = false
    @State private var join : Bool = false

    @EnvironmentObject var model:ViewModel
    
    var body: some View {
        
        NavigationStack {
            
            GeometryReader { geo in
                ZStack {
                    Image("Solid - Dark Green")
                        .resizable()
                        .edgesIgnoringSafeArea(.all)
                    
                    VStack (spacing:20) {
                        
                        Spacer()
                        
                        TextField("", text: $textFieldText)
                            .placeholder(when: textFieldText.isEmpty) {
                                Text("Your Display Name:").foregroundColor(.gray)
                            }
                            .padding()
                            .frame(width: 300, height:75)
                            .foregroundColor(.black)
                            .background(Color.white.cornerRadius(10))
                            .font(.title)
                            .disableAutocorrection(true)
                            .autocapitalization(.none)
                            .onChange(of: textFieldText) { newValue in
                                model.myPlayer.displayName = newValue
                            }
                        
                        Spacer()
                        
                        Image(uiImage: UIImage(named: "AppIcon") ?? UIImage())
                            .resizable()
                            .cornerRadius(25)
                            .frame(width:200, height:200)
                        
                        Text("iShuffle")
                            .font(.largeTitle)
                        
                        Spacer()
                        
                        Button() {
                            join = true
                        } label: {
                            Text("Join a Game")
                                .frame(width: 300, height:75)
                                .foregroundColor(.white)
                                .background(.red)
                                .cornerRadius(20)
                                .font(.title)
                                .fontWeight(.semibold)
                        }
                        
                        Button() {
                            create = true
                        } label: {
                            Text("Create a Game")
                                .frame(width: 300, height:75)
                                .foregroundColor(.white)
                                .background(.red)
                                .cornerRadius(20)
                                .font(.title)
                                .fontWeight(.semibold)
                        }
                        
                        Spacer()
                        
                    }
                    .navigationDestination(isPresented: $create) {
                        CreateView(begin: $model.gameHasBegun)
                    }
                    .navigationDestination(isPresented: $join) {
                        JoinView(join: $model.joinedGame)
                    }
                }
            }
            .ignoresSafeArea(.keyboard)
            
        }
        .environmentObject(model)
    }
}

struct CreateView:View {
    
    @State private var code = String(alphabet.randomElement()!) + String(alphabet.randomElement()!) + String(alphabet.randomElement()!) + String(alphabet.randomElement()!)
    @State private var goingBack = true
    
    @Binding var begin:Bool
    
    @EnvironmentObject var model:ViewModel
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        
        NavigationView {
            
            ZStack {
                
                Image("Solid - Dark Green")
                    .resizable()
                    .edgesIgnoringSafeArea(.all)
                    .onDisappear() {
                        if goingBack {
                            model.destroyGame()
                        }
                    }
                
                VStack(spacing: 15) {
                    
                    Text("Your Code: " + code)
                        .font(.largeTitle)
                        .foregroundColor(.black)
                        .onAppear() {
                            if model.leaving == false {
                                model.createGame(joinCode: code)
                            } else {
                                model.leaving = false
                                dismiss()
                            }
                        }
                    
                    Spacer()
                    
                    if (model.game != nil) {
                        ForEach(model.game!.players.indices, id: \.self) { index in
                            Text(model.game!.players[index].displayName)
                                .frame(width:300, height:60)
                                .foregroundColor(.black)
                                .background(Color.white)
                                .font(.title)
                                .cornerRadius(20)
                        }
                    }
                    
                    Spacer()
                    
                    Picker(
                        selection: $model.numDecks,
                        label: Text(""),
                        content: {
                            Text("1 deck").tag(1)
                                .font(.largeTitle)
                            Text("2 decks").tag(2)
                                .font(.largeTitle)
                            Text("3 decks").tag(3)
                                .font(.largeTitle)
                            Text("4 decks").tag(4)
                                .font(.largeTitle)
                    })
                    .scaleEffect(2.0)
                    
                    Button {
                        goingBack = false
                        model.beginGame()
                    } label: {
                        Text("START")
                            .padding()
                            .frame(width: 300, height: 75)
                            .background(Color.red.cornerRadius(20))
                            .foregroundColor(.white)
                            .fontWeight(.semibold)
                            .font(.title)
                    }
                }
                .navigationDestination(isPresented: $begin) {
                    GameView()
                }
                
            }
        }
        .environmentObject(model)
    }
    
}

struct JoinView:View {
    
    @State var textFieldText:String = ""
    
    @Binding var join:Bool
    
    @EnvironmentObject var model:ViewModel
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        
        NavigationView {
            
            ZStack {
                
                Image("Solid - Dark Green")
                    .resizable()
                    .edgesIgnoringSafeArea(.all)
                    .onAppear {
                        if model.leaving {
                            model.leaving = false
                            dismiss()
                        }
                    }
                
                VStack (spacing: 20) {
                    
                    TextField("", text: $textFieldText)
                        .placeholder(when: textFieldText.isEmpty) {
                            Text("Enter a Join Code...").foregroundColor(.gray)
                        }
                        .padding()
                        .frame(width: 300, height:75)
                        .foregroundColor(.black)
                        .background(Color.white.cornerRadius(10))
                        .font(.title)
                        .disableAutocorrection(true)
                        .autocapitalization(.none)
                    
                    Button {
                        model.tryAddingMyPlayer(tryCode: textFieldText)
                    } label: {
                        Text("JOIN")
                            .padding()
                            .frame(width:300, height: 75)
                            .background(Color.red.cornerRadius(20))
                            .foregroundColor(.white)
                            .fontWeight(.semibold)
                            .font(.title)
                    }

                }
                .navigationDestination(isPresented: $join) {
                    WaitView()
                }
            }
            .ignoresSafeArea(.keyboard)
        }
        .environmentObject(model)
    }
    
}

struct WaitView:View {
    
    @EnvironmentObject var model:ViewModel
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        
        if model.gameHasBegun {
            GameView()
        }
        else {
            
            NavigationView {
                
                ZStack {
                    
                    Image("Solid - Dark Green")
                        .resizable()
                        .edgesIgnoringSafeArea(.all)
                        .onAppear() {
                            if model.joining == false {
                                model.removeMyPlayer()
                                model.leaving = true
                                dismiss()
                            }
                        }
                        .onDisappear() {
                            model.joining = false
                            if model.gameHasBegun == false {
                                model.removeMyPlayer()
                            }
                        }
                    
                    VStack {
                        ProgressView("Waiting to join...")
                            .tint(.black)
                            .scaleEffect(2)
                            .foregroundColor(.black)
                            .font(.headline)
                            .onAppear() {
                                model.checkGameStart()
                                model.observePlayers()
                            }
                    }
                    
                }
            }
            .environmentObject(model)
        }
    }
    
}

struct GameView: View {

    @EnvironmentObject var model:ViewModel
    
    @State var showChat:Bool = false
    @State var showHelp:Bool = false
    @State var showBet:Bool = false
    @State var showMenu:Bool = false
    @State var showDiscard:Bool = false
    
    //@State var location:CGPoint = CGPoint(x: UIScreen.main.bounds.width/2, y: UIScreen.main.bounds.height/2)
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        
        ZStack {
            
            if showMenu {
                MenuView(showMenu: $showMenu, showPot:$model.showPot, enableChipCount:$model.enableChipCount, enableCardCount:$model.enableCardCount, enableDealerButton: $model.enableDealerButton, enableDiscardPile: $model.enableDiscardPile, shuffleOnReset: $model.shuffleOnReset, reshuffleDiscardPile: $model.reshuffleDiscardPile)
                    .padding(.top, 150)
                    .transition(.move(edge: .bottom))
                    .animation(.spring())
                    .zIndex(2.0)
            }
            
            if showBet {
                BetView(showBet: $showBet)
                    .padding(.top, 25)
                    .transition(.move(edge: .bottom))
                    .animation(.spring())
                    .zIndex(2.0)
            }
            
            if showChat {
                ChatView(showChat: $showChat)
                    .padding(.top, 100)
                    .transition(.move(edge: .bottom))
                    .animation(.spring())
                    .zIndex(2.0)
            }
            
            if showHelp {
                HelpView(showHelp: $showHelp)
                    .padding(.top, 100)
                    .transition(.move(edge: .bottom))
                    .animation(.spring())
                    .zIndex(2.0)
            }
            
            if showDiscard {
                DiscardedCardsView(showDiscard: $showDiscard)
                    .zIndex(2.0)
                    .offset(y:-40)
            }
            
            ZStack {
                Image("Solid - Dark Green")
                    .resizable()
                    .edgesIgnoringSafeArea(.all)
                    .onChange(of: model.gameHasBegun) { _ in
                        dismiss()
                    }
                    .onChange(of: model.gameChat.messages.count) { count in
                        if count > 0 {
                            model.unreadMessages = true
                        }
                    }
                ZStack {
                    if model.enableDiscardPile {
                        DiscardPileView(showDiscard: $showDiscard)
                            .frame(height: 100)
                            .offset(y:170)
                    }
                    ForEach(model.game?.players.indices ?? 0..<0, id: \.self) {index in
                        PlayerRectangleView(playerID: index)
                            .frame(width:90, height:120)
                    }
                    .frame(maxWidth:UIScreen.main.bounds.width)
                    RoundedRectangle(cornerRadius: 15, style: .continuous)
                        .foregroundColor(.black)
                        .frame(width:81, height:126)
                    if (model.discardPile.cards.count != 0) {
                        Image("refresh")
                            .resizable()
                            .frame(width: 45, height: 45)
                            .onTapGesture {
                                if (model.deck.cards.count == 0) {
                                    model.turnDiscardPile()
                                }
                            }
                    }
                    if model.deck.cards.count > 0 {
                        Image(model.deck.cards[0].imageName)
                            .resizable()
                            .frame(width:54, height:84)
                    }
                    FreeCardsView()
                    if model.showPot {
                        HStack (spacing:5) {
                            Text("x" + String(model.pot))
                                .foregroundColor(.white)
                            Image("poker-chip")
                                .resizable()
                                .frame(width:25, height: 25)
                        }
                        .frame(height:100)
                        .offset(y:85)
                    }
                }
                if model.enableDealerButton {
                    DealerButtonView()
                }
            }
            .navigationBarHidden(true)
            .safeAreaInset(edge: .bottom) {
                VStack (spacing:0) {
                    HandView()
                        .frame(height: 175)
                    BottomBarView(showHelp:$showHelp, showChat:$showChat, showBet:$showBet, showMenu:$showMenu)
                        .frame(height:75)
                }
            }
            .ignoresSafeArea(.keyboard)
        }
        .environmentObject(model)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(ViewModel())
    }
}
