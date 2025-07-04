//
//  ViewModel.swift
//  iShuffle
//
//  Created by Tiago Rundle on 2/11/23.
//

import Foundation
import FirebaseDatabase
import FirebaseDatabaseSwift

public class ViewModel: ObservableObject {
    
    let ref = Database.database().reference()
    
    let suits = ["spades", "clubs", "diamonds", "hearts"]
    let ranks = ["ace", "2", "3", "4", "5", "6", "7", "8", "9", "10", "jack", "queen", "king"]
    
    @Published var game:Game? = nil
    @Published var deck = Deck(decks: 1)
    @Published var numDecks = 1
    @Published var myPlayer = Player(displayName: "")
    @Published var myCards = [Card]()
    @Published var gameHasBegun = false
    @Published var joinedGame = false
    @Published var joining = false
    @Published var leaving = false
    @Published var unreadMessages = false
    @Published var gameChat:Feed = Feed(type: "chat")
    @Published var activityFeed:Feed = Feed(type: "activity")
    @Published var pot = 0
    
    @Published var enableDiscardPile:Bool = false
    @Published var enableCardCount:Bool = true
    @Published var enableChipCount:Bool = false
    @Published var enableDealerButton:Bool = false
    @Published var showPot = false
    @Published var shuffleOnReset:Bool = true
    @Published var reshuffleDiscardPile:Bool = true
    @Published var dealerButton:DealerButton = DealerButton()
    
    @Published var freeArea = CardArea()
    @Published var discardPile = CardArea()
    
    @Published var selection:String = "Actions"
    
    @Published var maxZ = -1
    
    var dealerHandle:DatabaseHandle?
    var checkStartHandle:DatabaseHandle?
    var playersHandle:DatabaseHandle?
    var freeCardsHandle:DatabaseHandle?
    var deckCardsHandle:DatabaseHandle?
    var myCardsHandle:DatabaseHandle?
    var maxZHandle:DatabaseHandle?
    var chatHandle:DatabaseHandle?
    var activityHandle:DatabaseHandle?
    var potHandle:DatabaseHandle?
    var checkDealerButtonHandle:DatabaseHandle?
    var checkDiscardPileHandle:DatabaseHandle?
    
    func deckToFree() {
        
        if (deck.cards.count == 0) {
            return
        }
        
        var fbDeck = deck
        
        for index in fbDeck.cards.indices {
            if index == 0 {
                fbDeck.cards[index].id! = freeArea.cards.count
            }
            else {
                fbDeck.cards[index].id! -= 1
            }
        }
        
        freeArea.cards.append(fbDeck.cards.removeFirst())
        ref.child("Games").child(game!.id).child("freeArea").setValue(freeArea.toDictionary)
        ref.child("Games").child(game!.id).child("deck").setValue(fbDeck.toDictionary)
        
    }
    
    func freeToDiscard(cardAdded:Card) {
        
        for index in freeArea.cards.indices {
            if freeArea.cards[index].id! > cardAdded.id! {
                freeArea.cards[index].id! -= 1
            }
        }
        
        freeArea.cards.remove(at: cardAdded.id!)
        let length = discardPile.cards.count
        discardPile.cards[length - 1].id = length - 1
        ref.child("Games").child(game!.id).child("freeArea").setValue(freeArea.toDictionary)
        ref.child("Games").child(game!.id).child("discardPile").setValue(discardPile.toDictionary)
    }
    
    func discardToHand(cardAdded:Card, player:Player) {
        
        for index in discardPile.cards.indices {
            if discardPile.cards[index].id! > cardAdded.id! {
                discardPile.cards[index].id! -= 1
            }
        }
        
        discardPile.cards.remove(at: cardAdded.id!)
        let length = game!.players[player.id!].cards!.count
        game!.players[player.id!].cards![length - 1].id = nil
        ref.child("Games").child(game!.id).child("discardPile").setValue(discardPile.toDictionary)
        ref.child("Games").child(game!.id).child("Players").child(player.role!).setValue(game!.players[player.id!].toDictionary)
    }
    
    func freeToHand(cardAdded:Card, player:Player) {
        
        for index in freeArea.cards.indices {
            if freeArea.cards[index].id! > cardAdded.id! {
                freeArea.cards[index].id! -= 1
            }
        }
        
        freeArea.cards.remove(at: cardAdded.id!)
        let length = game!.players[player.id!].cards!.count
        game!.players[player.id!].cards![length - 1].id = nil
        ref.child("Games").child(game!.id).child("freeArea").setValue(freeArea.toDictionary)
        ref.child("Games").child(game!.id).child("Players").child(player.role!).setValue(game!.players[player.id!].toDictionary)
    }
    
    func handToFree(cardAdded:Card) {
        
        var card = cardAdded
        card.id = 0
        
        for index in freeArea.cards.indices {
            freeArea.cards[index].id! += 1
        }
        
        freeArea.cards.insert(card, at: 0)
        
        maxZ += 1
        freeArea.cards[0].zIndex = maxZ
        game!.players[myPlayer.id!].cards = myCards
        ref.child("Games").child(game!.id).child("freeArea").setValue(freeArea.toDictionary)
        ref.child("Games").child(game!.id).child("Players").child(myPlayer.role!).setValue(game!.players[myPlayer.id!].toDictionary)
        
    }
    
    func tryAddingMyPlayer(tryCode:String) {
        
        ref.child("Games").observeSingleEvent(of: .value) { snapshot in
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                for child in snapshots {
                    let code = child.childSnapshot(forPath: "JoinCode").value as? String
                    if (code == tryCode && child.childSnapshot(forPath: "Players").childrenCount < 8) {
                        
                        self.myPlayer.id = Int(child.childSnapshot(forPath: "Players").childrenCount)
                        self.myPlayer.color = {
                            switch self.myPlayer.id {
                            case 1: return "orange"
                            case 2:return "lightOrange"
                            case 3: return "yellow"
                            case 4: return "green"
                            case 5:return "blue"
                            case 6: return "lightPurple"
                            case 7: return "purple"
                            default: return "white"
                            }
                        }()
                        self.myPlayer.role = "guest" + String(self.myPlayer.id!)
                        self.ref.child("Games").child(child.key).child("Players").child(self.myPlayer.role!).setValue(self.myPlayer.toDictionary)
                        self.joinedGame = true
                        self.joining = true
                        self.game = Game(id: child.key, joinCode: tryCode)
                        
                        self.observeChat()
                        self.observeActivityFeed()
                        self.observePlayers()
                        self.observeFreeCards()
                        self.observeDeckCards()
                        self.observeDiscardPile()
                        self.observeMyCards()
                        self.observeMaxZ()
                        self.observePot()
                        self.observeDealerButton()
                        self.checkDealerButton()
                        self.checkDiscardPile()
                        
                    }
                    
                }
            }
        }
        
    }
    
    func removeMyPlayer() {
        
        if game != nil {
            ref.removeObserver(withHandle: checkStartHandle!) //maybe fix all of these eventually
            ref.removeObserver(withHandle: playersHandle!)
            ref.removeObserver(withHandle: freeCardsHandle!)
            ref.child("Games").child(game!.id).child("Players").child(myPlayer.role!).child("cards").removeObserver(withHandle: myCardsHandle!)
            ref.removeObserver(withHandle: maxZHandle!)
            ref.removeObserver(withHandle: chatHandle!)
            ref.removeObserver(withHandle: activityHandle!)
            
            ref.child("Games").child(game!.id).child("Players").child(myPlayer.role!).removeValue()
        }
                               
        joinedGame = false
        gameHasBegun = false
        myCards = [Card]()
        deck = Deck(decks: 1)
        numDecks = 1
        myPlayer = Player(displayName: myPlayer.displayName)
        pot = 0
        freeArea = CardArea()
        discardPile = CardArea()
        enableCardCount = true
        enableChipCount = false
        enableDealerButton = false
        showPot = false
        shuffleOnReset = true
        unreadMessages = false
        game = nil
        
    }
    
    func destroyGame() {
        gameHasBegun = false
        myCards = [Card]()
        ref.child("Games").child(game!.id).removeValue()
        deck = Deck(decks: 1)
        numDecks = 1
        myPlayer = Player(displayName: myPlayer.displayName)
        pot = 0
        freeArea = CardArea()
        discardPile = CardArea()
        enableCardCount = true
        enableChipCount = false
        enableDealerButton = false
        showPot = false
        shuffleOnReset = true
        unreadMessages = false
        game = nil
    }
    
    func createGame(joinCode:String) {
        
        game = Game(id: "public_" + joinCode, joinCode: joinCode)
        gameChat = Feed(type: "chat")
        unreadMessages = false
        activityFeed = Feed(type: "activity")
        myPlayer.role = "host"
        myPlayer.id = 0
        myPlayer.color = "red"
        game!.players.append(myPlayer)
        ref.child("Games").child(game!.id).child("HasBegun?").setValue(false)
        ref.child("Games").child(game!.id).child("JoinCode").setValue(joinCode)
        ref.child("Games").child(game!.id).child("GameChat").setValue(gameChat.toDictionary)
        ref.child("Games").child(game!.id).child("ActivityFeed").setValue(activityFeed.toDictionary)
        ref.child("Games").child(game!.id).child("Pot").setValue(0)
        ref.child("Games").child(game!.id).child("Players").child("host").setValue(game!.players[0].toDictionary)
        ref.child("Games").child(game!.id).child("DealerButton").setValue(dealerButton.toDictionary)
        ref.child("Games").child(game!.id).child("enableDealerButton?").setValue(false)
        ref.child("Games").child(game!.id).child("enableDiscardPile?").setValue(false)
        
        observeChat()
        observeActivityFeed()
        observePlayers()
        observePot()
        observeDealerButton()
        
    }
    
    func beginGame() {
        gameHasBegun = true
        maxZ = -1 + numDecks*52
        deck = Deck(decks: numDecks)
        deck.cards.shuffle()
        ref.child("Games").child(game!.id).child("deck").setValue(deck.toDictionary)
        ref.child("Games").child(game!.id).child("maxZ").setValue(maxZ)
        ref.child("Games").child(game!.id).updateChildValues(["HasBegun?": true])
        
        deckToFree()
        
        observeDiscardPile()
        observeFreeCards()
        observeDeckCards()
        observeMyCards()
        observeMaxZ()
    }
    
    func checkGameStart() {
        if (game == nil) {
            return
        }
        checkStartHandle = ref.child("Games").child(game!.id).child("HasBegun?").observe(.value) {snapshot in
            self.gameHasBegun = snapshot.value as? Bool ?? false
        }
    }
    
    func checkDealerButton() {
        if (game == nil) {
            return
        }
        checkDealerButtonHandle = ref.child("Games").child(game!.id).child("enableDealerButton?").observe(.value) {snapshot in
            self.enableDealerButton = snapshot.value as? Bool ?? false
        }
    }
    
    func checkDiscardPile() {
        if (game == nil) {
            return
        }
        checkDealerButtonHandle = ref.child("Games").child(game!.id).child("enableDiscardPile?").observe(.value) {snapshot in
            self.enableDiscardPile = snapshot.value as? Bool ?? false
        }
    }
    
    func turnDiscardPile() {
        if reshuffleDiscardPile {
            discardPile.cards.shuffle()
        }
        deck.cards = discardPile.cards
        discardPile = CardArea()
        for index in deck.cards.indices {
            if deck.cards[index].faceDown == false {
                deck.cards[index].turnCard()
            }
            deck.cards[index].offset = .zero
            deck.cards[index].newset = .zero
        }
        ref.child("Games").child(game!.id).child("deck").setValue(deck.toDictionary)
        ref.child("Games").child(game!.id).child("discardPile").setValue(discardPile.toDictionary)
        deckToFree()
    }
    
    func shuffleDeck() {
        if (game == nil) {
            return
        }
        var fbDeck = deck
        var fbFree = freeArea
        var freeCard = fbFree.cards.removeLast()
        if !freeCard.faceDown {
            freeCard.turnCard()
        }
        fbDeck.cards.append(freeCard)
        fbDeck.cards.shuffle()
        var topCard = fbDeck.cards.removeFirst()
        topCard.id = fbFree.cards.count
        fbFree.cards.append(topCard)
        for index in fbDeck.cards.indices {
            fbDeck.cards[index].id = index
        }
        ref.child("Games").child(game!.id).child("freeArea").setValue(fbFree.toDictionary)
        ref.child("Games").child(game!.id).child("deck").setValue(fbDeck.toDictionary)
    }
    
    func resetCards() {
        if (game == nil) {
            return
        }
        myCards = [Card]()
        deck = Deck(decks: numDecks)
        if shuffleOnReset {
            deck.cards.shuffle()
        }
        ref.child("Games").child(game!.id).child("deck").setValue(deck.toDictionary)
        for player in game!.players {
            ref.child("Games").child(game!.id).child("Players").child(player.role!).child("cards").removeValue()
        }
        freeArea = CardArea()
        ref.child("Games").child(game!.id).child("freeArea").setValue(freeArea.toDictionary)
        discardPile = CardArea()
        ref.child("Games").child(game!.id).child("discardPile").setValue(discardPile.toDictionary)
        deckToFree()
    }
    
    func resetChips() {
        if (game == nil) {
            return
        }
        pot = 0
        ref.child("Games").child(game!.id).child("Pot").setValue(0)
        for i in game!.players.indices {
            game!.players[i].chipCount = 1000
            ref.child("Games").child(game!.id).child("Players").child(game!.players[i].role!).child("chipCount").setValue(1000)
        }
    }
    
    func updateDealerButton() {
        if (game == nil) {
            return
        }
        ref.child("Games").child(game!.id).child("DealerButton").updateChildValues(["offsetWidth":Int(dealerButton.offsetWidth), "offsetHeight":Int(dealerButton.offsetHeight), "newsetWidth":Int(dealerButton.newsetWidth), "newsetHeight":Int(dealerButton.newsetHeight)])
    }
    
    func updateDealerButtonStatus() {
        if (game == nil) {
            return
        }
        ref.child("Games").child(game!.id).child("enableDealerButton?").setValue(enableDealerButton)
    }
    
    func updateDiscardPileStatus() {
        if (game == nil) {
            return
        }
        ref.child("Games").child(game!.id).child("enableDiscardPile?").setValue(enableDiscardPile)
    }
    
    func updateCard(cardToUpdate:Card) {
        if (game == nil) {
            return
        }
        ref.child("Games").child(game!.id).child("freeArea").child("cards").updateChildValues([String(cardToUpdate.id!):cardToUpdate.toDictionary!])
    }
    
    func updateChat() {
        if (game == nil) {
            return
        }
        ref.child("Games").child(game!.id).child("GameChat").setValue(gameChat.toDictionary)
    }
    
    func updateActivityFeed() {
        if (game == nil) {
            return
        }
        ref.child("Games").child(game!.id).child("ActivityFeed").setValue(activityFeed.toDictionary)
    }
    
    func updateChips(player:Player) {
        if (game == nil) {
            return
        }
        ref.child("Games").child(game!.id).child("Pot").setValue(pot)
        ref.child("Games").child(game!.id).child("Players").child(player.role!).child("chipCount").setValue(player.chipCount)
    }
    
    func updateOffset(cardToBeUpdated:Card, widthOffset:Int, heightOffset:Int) { //updates database data with game data
        if (game == nil) {
            return
        }
        ref.child("Games").child(game!.id).child("freeArea").child("cards").child(String(cardToBeUpdated.id!)).child("offset").updateChildValues(["0":widthOffset, "1":heightOffset])
    }
    
    func updateNewset(cardToBeUpdated:Card, widthNewset:Int, heightNewset:Int) { //updates database data with game data
        if (game == nil) {
            return
        }
        ref.child("Games").child(game!.id).child("freeArea").child("cards").child(String(cardToBeUpdated.id!)).child("newset").updateChildValues(["0":widthNewset, "1":heightNewset])
    }
    
    func updateZIndex(cardIndex:Int) {
        if (game == nil) {
            return
        }
        maxZ += 1
        ref.child("Games").child(game!.id).updateChildValues(["maxZ": maxZ])
        ref.child("Games").child(game!.id).child("freeArea").child("cards").child(String(cardIndex)).updateChildValues(["zIndex":maxZ])
    }
    
    func updateDeck() {
        if (game == nil) {
            return
        }
        ref.child("Games").child(game!.id).child("deck").setValue(deck.toDictionary)
    }
    
    func observeDealerButton() {
        if (game == nil) {
            return
        }
        dealerHandle = ref.child("Games").child(game!.id).child("DealerButton").observe(.value) { snapshot in
            if let result = try? snapshot.data(as: DealerButton.self) {
                self.dealerButton = result
            } else {return}
                
        }
    }
    
    func observeMaxZ() {
        if (game == nil) {
            return
        }
        maxZHandle = ref.child("Games").child(game!.id).child("maxZ").observe(.value) { snapshot in
            self.maxZ = snapshot.value as? Int ?? 0
        }
    }
    
    func observeChat() {
        if (game == nil) {
            return
        }
        chatHandle = ref.child("Games").child(game!.id).child("GameChat").child("messages").observe(.value) { parentSnapshot in
            guard let children = parentSnapshot.children.allObjects as? [DataSnapshot] else {
                return
            }
            self.gameChat.messages = children.compactMap({ snapshot in
                return try? snapshot.data(as: Message.self)
            })
        }
    }
    
    func observeActivityFeed() {
        if (game == nil) {
            return
        }
        activityHandle = ref.child("Games").child(game!.id).child("ActivityFeed").child("messages").observe(.value) { parentSnapshot in
            guard let children = parentSnapshot.children.allObjects as? [DataSnapshot] else {
                return
            }
            self.activityFeed.messages = children.compactMap({ snapshot in
                return try? snapshot.data(as: Message.self)
            })
        }
    }
    
    func observePlayers() {
        if (game == nil) {
            return
        }
        playersHandle = ref.child("Games").child(game!.id).child("Players").queryOrdered(byChild: "id").observe(.value) { parentSnapshot in
            guard let children = parentSnapshot.children.allObjects as? [DataSnapshot] else {
                return
            }
            self.game?.players = children.compactMap({ snapshot in
                return try? snapshot.data(as: Player.self)
            })
        }
    }
    
    func observeFreeCards() { //updates game data with database data
        if (game == nil) {
            return
        }
        freeCardsHandle = ref.child("Games").child(game!.id).child("freeArea").child("cards").observe(.value) { parentSnapshot in
            guard let children = parentSnapshot.children.allObjects as? [DataSnapshot] else {
                return
            }
            self.freeArea.cards = children.compactMap({ snapshot in
                return try? snapshot.data(as: Card.self)
            })
        }
    }
    
    func observeDeckCards() { //updates game data with database data
        if (game == nil) {
            return
        }
        deckCardsHandle = ref.child("Games").child(game!.id).child("deck").child("cards").observe(.value) { parentSnapshot in
            guard let children = parentSnapshot.children.allObjects as? [DataSnapshot] else {
                return
            }
            self.deck.cards = children.compactMap({ snapshot in
                return try? snapshot.data(as: Card.self)
            })
        }
    }
    
    func observeDiscardPile() { //updates game data with database data
        if (game == nil) {
            return
        }
        deckCardsHandle = ref.child("Games").child(game!.id).child("discardPile").child("cards").observe(.value) { parentSnapshot in
            guard let children = parentSnapshot.children.allObjects as? [DataSnapshot] else {
                return
            }
            self.discardPile.cards = children.compactMap({ snapshot in
                return try? snapshot.data(as: Card.self)
            })
        }
    }
    
    
    
    func observeMyCards() {
        if (game == nil) {
            return
        }
        myCardsHandle = ref.child("Games").child(game!.id).child("Players").child(myPlayer.role!).child("cards").observe(.childAdded) { snapshot in
            self.myCards.append(try! snapshot.data(as: Card.self))
        }
        ref.child("Games").child(game!.id).child("Players").child(myPlayer.role!).child("cards").observe(.value) { parentSnapshot in
            guard let children = parentSnapshot.children.allObjects as? [DataSnapshot] else {
                return
            }
            self.myPlayer.cards = children.compactMap({ snapshot in
                return try? snapshot.data(as: Card.self)
            })
        }
    }
    
    func observePot() {
        if (game == nil) {
            return
        }
        potHandle = ref.child("Games").child(game!.id).child("Pot").observe(.value) { snapshot in
            self.pot = snapshot.value as? Int ?? 0
        }
    }
}
