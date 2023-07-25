//
//  SetGameView.swift
//  SetGame
//
//  Created by Nipuna Weerapperuma on 7/20/23.
//

import SwiftUI

struct SetGameView: View {
    @ObservedObject var game: SetGameController
    @Namespace private var dealingNamespace

    var body: some View {
        Text("Set!").font(.largeTitle)
        gameBody
        newGameButton
        HStack {
            deckBody
            Spacer()
            discardedBody
        }.padding()
    }

    private func dealAnimation(for card: SetGameController.Card) -> Animation {
        var delay = 0.0
        if let index = game.deck.firstIndex(where: {$0.id == card.id}) {
            delay = Double(index) * (CardConstants.totalDealDuration / Double(3))
        }
        return Animation.easeInOut(duration: CardConstants.dealDuration).delay(delay)
    }
    
    private func zIndex(of card: SetGameController.Card, from source: Array<SetGameController.Card>) -> Double {
        Double(source.firstIndex(where: {$0.id == card.id}) ?? 0)
    }

    var gameBody: some View {
        AspectVGrid(items: game.cards, aspectRatio: CardConstants.aspectRatio) { card in //Creating your own custom Container View to dynamically size/fit cards
            CardView(card: card)
                .matchedGeometryEffect(id: card.id, in: dealingNamespace)
                .transition(AnyTransition.asymmetric(insertion: .identity, removal: .scale))
                .padding(4)
                .onTapGesture {
                    withAnimation {
                        game.choose(card)
                    }
                }
        }
        .padding(.horizontal)
    }

    var deckBody: some View {
        ZStack {
            ForEach(game.deck) { card in
                RoundedRectangle(cornerRadius: 20)
                    .fill(.pink)
                    .matchedGeometryEffect(id: card.id, in: dealingNamespace) // Matches animation of this view with one above
                    .transition(AnyTransition.asymmetric(insertion: .opacity, removal: .identity))
                    .zIndex(zIndex(of: card, from: game.deck)) // So card in deck is in a certain order
            }
        }
        .frame(width: CardConstants.undealtWidth, height: CardConstants.undealtHeight)
        .foregroundColor(.red)
        .onTapGesture {
            for card in game.deck.prefix(3) {
                withAnimation(dealAnimation(for: card)) { // We do multiple card-dealing animations at once, but with varying delays to give appearance of dealing one at a time
                    game.dealCard()
                }
            }
        }
    }

    var discardedBody: some View {
        ZStack {
            ForEach(game.discardedCards) { card in
                CardView(card: card)
                    .matchedGeometryEffect(id: card.id, in: dealingNamespace) // Matches animation of this view with one above
                    .transition(AnyTransition.asymmetric(insertion: .opacity, removal: .identity))
                    .zIndex(zIndex(of: card, from: game.discardedCards)) // So card in deck is in a certain order
            }
        }
        .frame(width: CardConstants.undealtWidth, height: CardConstants.undealtHeight)
        .foregroundColor(.red)
    }

    var newGameButton: some View {
        Button("New Game") { game.newGame() }
    }

    private struct CardConstants {
        static let color = Color.red
        static let aspectRatio: CGFloat = 2/3
        static let dealDuration: Double = 0.5
        static let totalDealDuration: Double = 1
        static let undealtHeight: CGFloat = 90
        static let undealtWidth = undealtHeight * aspectRatio
    }

}

struct CardView: View {
    let card: SetGameController.Card
    
    let cardShape = RoundedRectangle(cornerRadius: DrawingsConstants.cornerRadius)
    let cardColor = Color.white
    let cardBorderColor: Color
    let numShapes: Int
    let opacity: Double
    let shapeColor: Color
    
    init(card: SetGameController.Card) {
        self.card = card
        
        if card.isPartOfSet == ThreeState.stateTwo { self.cardBorderColor = Color.green }
        else if card.isPartOfSet == ThreeState.stateOne { self.cardBorderColor = Color.red }
        else if card.isSelected { self.cardBorderColor = Color.yellow }
        else { self.cardBorderColor = Color.gray }

        
        if card.number == ThreeState.stateTwo { self.numShapes = 3 }
        else if card.number == ThreeState.stateOne { self.numShapes = 2 }
        else { self.numShapes = 1}
        
        if card.color == ThreeState.stateTwo { self.shapeColor = Color.blue }
        else if card.color == ThreeState.stateOne { self.shapeColor = Color.orange }
        else { self.shapeColor = Color.pink}
        
        if card.shading == ThreeState.stateTwo { self.opacity = 1.0 }
        else if card.shading == ThreeState.stateOne { self.opacity = 0.5 }
        else { self.opacity = 0.0}
        
    }
    
    var body: some View {
        GeometryReader(content: { geometry in
            ZStack { // Struct with it's content variable defined by the function (alignment is default)

                cardShape.fill().foregroundColor(cardColor)
                cardShape.strokeBorder(lineWidth: DrawingsConstants.lineWidth).foregroundColor(cardBorderColor)
                VStack {
                    let shapeDict: [ThreeState: AnyShape] = [ThreeState.stateZero: AnyShape(Rectangle()), ThreeState.stateOne: AnyShape(Capsule()), ThreeState.stateTwo: AnyShape(Diamond())]
                    ForEach(0..<numShapes, id: \.self) { _ in
                        ZStack {
                            shapeDict[card.shape]!.fill(shapeColor).opacity(opacity).aspectRatio(CGSize(width: 1, height: 0.5), contentMode: .fit)
                            shapeDict[card.shape]!.stroke(shapeColor, lineWidth: DrawingsConstants.lineWidth).aspectRatio(CGSize(width: 1, height: 0.5), contentMode: .fit)
                        }
                    }
                }.padding()

            }
            
            .scaleEffect(CGFloat(card.isPartOfSet == ThreeState.stateOne ? 1.05 : 1))
            .rotationEffect(Angle.degrees(card.isPartOfSet == ThreeState.stateTwo ? 360 : 0))
        })
    }
    
    private func font (in size: CGSize) -> Font {
        Font.system(size: min(size.width, size.height) * DrawingsConstants.fontScale)
    }
    
    private struct DrawingsConstants {
        static let cornerRadius: CGFloat = 15
        static let lineWidth: CGFloat = 3
        static let fontScale: CGFloat = 0.7
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let game = SetGameController()
        SetGameView(game: game)
            .preferredColorScheme(.dark)
        SetGameView(game: game)
            .preferredColorScheme(.light)
    }
}
