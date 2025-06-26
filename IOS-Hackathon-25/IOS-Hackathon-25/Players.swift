//
//  Players.swift
//  IOS-Hackathon-25
//
//  Created by Tlaitirang Rathete on 26/6/2025.
//

import Foundation
import SwiftData

@Model
class Player: Identifiable {
    var id = UUID()
    var numberOfPlayers: Int
    var playerNames: [String]
    var selectedGameType: String
    var createdAt: Date
    
    init(
        numberOfPlayers: Int,
        playerNames: [String],
        selectedGameType: String = "Random"
    ) {
        self.numberOfPlayers = numberOfPlayers
        self.playerNames = playerNames
        self.selectedGameType = selectedGameType
        self.createdAt = Date()
    }
}
