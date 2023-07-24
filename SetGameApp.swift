//
//  SetGameApp.swift
//  SetGame
//
//  Created by Nipuna Weerapperuma on 7/20/23.
//

import SwiftUI

@main
struct SetGameApp: App {
    var body: some Scene {
        WindowGroup {
            let game = SetGameController()
            SetGameView(game: game)
        }
    }
}
