//
//  SetGameModelView.swift
//  SetGame
//
//  Created by Nipuna Weerapperuma on 7/20/23.
//

import Foundation

class SetGameController: ObservableObject {
    typealias Card = SetGame.Card
    
    @Published private var game = SetGame()
    
    // Mark intent
    
    var cards: Array<Card> {
        game.playingCards
    }

    var deck: Array<Card> {
        game.deck
    }

    var discardedCards: Array<Card> {
        game.discardedCards
    }        
    
    func choose(_ card: Card) {
        game.choose(card)
    }
    
    func dealCard() { // Replace cards if it makes a set or add the cards
        game.dealCard()
    }
    
    func newGame() {
        game = SetGame()
    }
    
    func deckEmpty() -> Bool {
        return game.deckEmpty
    }
    
}
