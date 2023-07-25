//
//  SetGameModel.swift
//  SetGame
//
//  Created by Nipuna Weerapperuma on 7/20/23.
//

import Foundation


struct SetGame {
    // Conceptualize how to represent deck of cards, playing cards, and discarded/won cards
    // You could have 3 arrays to move cards from one to the other
    // Or you can track 3 states of the cards in 1 array
    private(set) var deck: [Card]
    private(set) var playingCards: [Card]
    private var discardedCards: [Card]
    var deckEmpty: Bool {
        deck.count == 0
    }
    private var setPresent: Bool {
        playingCards.filter{$0.isPartOfSet == ThreeState.stateTwo}.count == 3
    }
    private var nonSetPresent: Bool {
        playingCards.filter{$0.isPartOfSet == ThreeState.stateOne}.count == 3
    }
    private var selectedCardIndices: [Int] {
        playingCards.indices.filter{playingCards[$0].isSelected}
    }
    
    init() {
        deck = []
        playingCards = []
        discardedCards = []
        
        for id in 0..<81 { // Initialize the deck
            var ternary = String(id, radix: 3) // Represents id in base 3 (ternary)
            for _ in 0..<(4-ternary.count) { // Adjusts to size 4
                ternary = "0" + ternary
            }
            deck.append(Card( //Need to come up with logic to initialize the deck
                
                shape: ThreeState.init(encoding: ternary[0]),
                number: ThreeState.init(encoding: ternary[1]),
                shading: ThreeState.init(encoding: ternary[2]),
                color: ThreeState.init(encoding: ternary[3]),
                id: id
                            )
            )
        }
            
        deck.shuffle() // Randomize the deck
        
        for _ in 0..<12 { // Initialize 12 playing cards (removing from deck)
            playingCards.append(deck.removeLast())
        }
        
    }
    
    mutating func evaluateSet() { // Checks if 3 cards are a set (also updates state if they are or are not)
        let checkCardIndices = selectedCardIndices 
        
        if checkCardIndices.count == 3 {
            var shapeSet: Set<ThreeState> = []
            var numberSet: Set<ThreeState> = []
            var shadingSet: Set<ThreeState> = []
            var colorSet: Set<ThreeState> = []
            
            for index in checkCardIndices {
                shapeSet.insert(playingCards[index].shape)
                numberSet.insert(playingCards[index].number)
                shadingSet.insert(playingCards[index].shading)
                colorSet.insert(playingCards[index].color)
            }
            
            // If the 3 cards form a set
            if (shapeSet.count == 1 || shapeSet.count == 3) && // Shapes all same or different
                (numberSet.count == 1 || numberSet.count == 3) && // Number of shapes all shame or different
                (shadingSet.count == 1 || shadingSet.count == 3) && //Shading all same or different
                (colorSet.count == 1 || colorSet.count == 3) { //Color all same or different
                for index in checkCardIndices {
                    playingCards[index].isPartOfSet = ThreeState.stateTwo // Mark cards as a set
                }
            } else { // If the 3 cards form a non-set
                for index in checkCardIndices {
                    playingCards[index].isPartOfSet = ThreeState.stateOne // Mark cards as non-set
                }
            }
        }

    }

    mutating func discardCards() { // Assuming we pick a 4th card after a set/non-set formed
        if setPresent {
            let matchedSet = playingCards.filter { $0.isPartOfSet == ThreeState.stateTwo }
            playingCards.removeAll(where: { $0.isPartOfSet == ThreeState.stateTwo })
            discardedCards.append(contentsOf: matchedSet)
        }
    }
    
    mutating func dealCard() { // Deals a card
        if !deckEmpty { // Just a safety check (but should only be called if deck is not empty)
            if setPresent {
                let discardCardIndex = playingCards.firstIndex(where: {$0.isPartOfSet == ThreeState.stateTwo})
                playingCards[index] = deck.removeLast()
                discardedCards.append(discardCard)      
            } else {
                playingCards.append(deck.removeLast())
            }
        }
    }
    
    mutating func choose(_ card: Card) {
        let numCardsSelected = selectedCardIndices.count
        if let chosenIndex = playingCards.firstIndex(where: {$0.id == card.id}), numCardsSelected <= 3 // Find corresponding card's index
        {
            
            if numCardsSelected <= 1 || numCardsSelected == 2 && playingCards[chosenIndex].isSelected { // If there's 0-1 cards picked or 2 cards picked and you're reselecting
                    playingCards[chosenIndex].isSelected.toggle() // Toggle chosen card's selection
            }
            else if numCardsSelected == 2 { // If picking 3rd, new card
                playingCards[chosenIndex].isSelected = true // Pick third card
                evaluateSet() // Evaluates if 3 cards are a set, de-selects the cards
            }
            else { // 3 cards are picked, selecting 4th one
                for i in selectedCardIndices {
                    playingCards[i].isSelected = false
                }
                playingCards[chosenIndex].isSelected = true
                discardCards()
            }
            
            
        }
    }
    
    struct Card: Identifiable {
        var isPartOfSet: ThreeState = ThreeState.stateZero // Possible states: not-evaluated, forms a set, forms a non-set
        var isSelected = false // Is the card selected
        let shape: ThreeState
        let number: ThreeState
        let shading: ThreeState
        let color: ThreeState
        let id: Int
    }
}

enum ThreeState: Hashable {
    case stateZero
    case stateOne
    case stateTwo
    
    init(encoding: Character) {
        switch encoding {
        case "0":
            self = .stateZero
        case "1":
            self = .stateOne
        case "2":
            self = .stateTwo
        default:
            fatalError("Invalid encoding")
        }
    }
}

extension StringProtocol {
    subscript(offset: Int) -> Character {
        self[index(startIndex, offsetBy: offset)]
    }
}
