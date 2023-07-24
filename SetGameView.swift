//
//  SetGameView.swift
//  SetGame
//
//  Created by Nipuna Weerapperuma on 7/20/23.
//

import SwiftUI

struct SetGameView: View {
    @ObservedObject var game: SetGameController
    
    var body: some View {
          Text("Set!").font(.largeTitle)
            AspectVGrid(items: game.cards, aspectRatio: 2/3) { card in //Creating your own custom Container View to dynamically size/fit cards
                CardView(card: card)
                        .padding(4)
                        .onTapGesture {
                            game.choose(card)
                        }
            }
            .padding(.horizontal)
            Button {
                game.dealCards()
            } label: {
                Text("Deal 3 More Cards")
            }
            .disabled(game.deckEmpty())
            Button {
                game.newGame()
            } label: {
                Text("New Game")
            }
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
