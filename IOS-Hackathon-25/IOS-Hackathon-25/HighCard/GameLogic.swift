//
//  GameLogic.swift
//  IOS-Hackathon-25

import Foundation

enum GameState {
    case setup
    case waiting
    case playing
    case roundResult
    case gameOver
}

enum RoundResult {
    case playerWins
    case computerWins
    case tie
    
    var message: String {
        switch self {
        case .playerWins: return "Round Winner!"
        case .computerWins: return "Computer Wins!"
        case .tie: return "It's a Tie!"
        }
    }
}

// MARK: - Player Model
struct Player: Identifiable, Equatable {
    let id = UUID()
    let name: String
    var score: Int = 0
    var currentCard: Card?
    
    init(name: String) {
        self.name = name
    }
    
    static func == (lhs: Player, rhs: Player) -> Bool {
        return lhs.id == rhs.id
    }
}

class GameLogic: ObservableObject {
    @Published var deck = Deck()
    @Published var players: [Player] = []
    @Published var gameState: GameState = .setup
    @Published var currentRoundResult: RoundResult?
    @Published var gameMessage = "Add 2-6 players to start!"
    @Published var roundWinners: [Player] = []
    
    private let maxRounds = 10 // Adjustable based on number of players
    private var roundsPlayed = 0
    
    init() {
        // Add default players for quick testing
        addPlayer(name: "Player 1")
        addPlayer(name: "Player 2")
    }
    
    // MARK: - Player Management
    func addPlayer(name: String) {
        guard players.count < 6, !name.isEmpty else { return }
        
        // Check for duplicate names
        if players.contains(where: { $0.name.lowercased() == name.lowercased() }) {
            return
        }
        
        players.append(Player(name: name))
        updateSetupMessage()
    }
    
    func removePlayer(at index: Int) {
        guard index < players.count else { return }
        players.remove(at: index)
        updateSetupMessage()
        
        if players.count < 2 && gameState != .setup {
            gameState = .setup
            updateSetupMessage()
        }
    }
    
    func removePlayer(_ player: Player) {
        if let index = players.firstIndex(of: player) {
            removePlayer(at: index)
        }
    }
    
    func canStartGame() -> Bool {
        return players.count >= 2 && players.count <= 6
    }
    
    // MARK: - Game Flow
    func startNewGame() {
        guard canStartGame() else {
            gameState = .setup
            updateSetupMessage()
            return
        }
        
        deck.resetDeck()
        
        // Reset all players
        for i in 0..<players.count {
            players[i].score = 0
            players[i].currentCard = nil
        }
        
        roundsPlayed = 0
        gameState = .waiting
        currentRoundResult = nil
        roundWinners = []
        gameMessage = "Tap 'Draw Cards' to start the first round!"
    }
    
    func drawCards() {
        guard gameState != .gameOver && players.count >= 2 else { return }
        
        // Check if enough cards remain
        guard deck.remainingCards >= players.count else {
            endGame()
            return
        }
        
        // Draw cards for all players
        for i in 0..<players.count {
            players[i].currentCard = deck.drawCard()
        }
        
        gameState = .playing
        
        // Determine round winners
        let result = determineRoundWinners()
        currentRoundResult = result
        
        // Update scores for winners
        for winner in roundWinners {
            if let index = players.firstIndex(where: { $0.id == winner.id }) {
                players[index].score += 1
            }
        }
        
        roundsPlayed += 1
        updateRoundMessage()
        gameState = .roundResult
        
        // Check if game should end
        let maxPossibleRounds = min(maxRounds, deck.remainingCards / players.count)
        if roundsPlayed >= maxPossibleRounds || deck.remainingCards < players.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.endGame()
            }
        }
    }
    
    private func determineRoundWinners() -> RoundResult {
        let playersWithCards = players.compactMap { player -> (Player, Int)? in
            guard let card = player.currentCard else { return nil }
            return (player, card.value)
        }
        
        guard !playersWithCards.isEmpty else {
            roundWinners = []
            return .tie
        }
        
        let maxValue = playersWithCards.map { $0.1 }.max() ?? 0
        roundWinners = playersWithCards.filter { $0.1 == maxValue }.map { $0.0 }
        
        return roundWinners.count > 1 ? .tie : .playerWins
    }
    
    private func updateRoundMessage() {
        if roundWinners.count == 1 {
            gameMessage = "🎉 \(roundWinners[0].name) wins the round!"
        } else if roundWinners.count > 1 {
            let names = roundWinners.map { $0.name }.joined(separator: ", ")
            gameMessage = "🤝 Tie between: \(names)"
        } else {
            gameMessage = "Round complete!"
        }
    }
    
    private func updateSetupMessage() {
        if players.isEmpty {
            gameMessage = "Add 2-6 players to start!"
        } else if players.count == 1 {
            gameMessage = "Add at least one more player! (\(players.count)/6)"
        } else if players.count <= 6 {
            gameMessage = "Ready! Tap 'Start Game' to begin. (\(players.count)/6 players)"
        } else {
            gameMessage = "Maximum 6 players allowed!"
        }
    }
    
    private func endGame() {
        gameState = .gameOver
        
        let maxScore = players.map { $0.score }.max() ?? 0
        let winners = players.filter { $0.score == maxScore }
        
        if winners.count == 1 {
            gameMessage = "🏆 \(winners[0].name) wins the game!\nFinal Score: \(maxScore) points"
        } else {
            let winnerNames = winners.map { $0.name }.joined(separator: ", ")
            gameMessage = "🤝 Tie Game!\n\(winnerNames)\nFinal Score: \(maxScore) points each"
        }
    }
    
    func canDrawCards() -> Bool {
        return (gameState == .waiting || gameState == .roundResult) &&
               players.count >= 2 &&
               deck.remainingCards >= players.count
    }
    
    func resetForNextRound() {
        if gameState == .roundResult && canDrawCards() {
            gameState = .waiting
            currentRoundResult = nil
            roundWinners = []
            gameMessage = "Ready for next round!"
        }
    }
    
    func goToSetup() {
        gameState = .setup
        updateSetupMessage()
    }
    
    // MARK: - Game Statistics
    var cardsRemaining: Int {
        return deck.remainingCards
    }
    
    var roundsRemaining: Int {
        guard players.count > 0 else { return 0 }
        let maxPossibleRounds = min(maxRounds, deck.remainingCards / players.count)
        return max(0, maxPossibleRounds - roundsPlayed)
    }
    
    var gameProgress: Double {
        guard players.count > 0 else { return 0 }
        let totalRounds = min(maxRounds, 52 / players.count)
        return totalRounds > 0 ? Double(roundsPlayed) / Double(totalRounds) : 0
    }
    
    func getLeadingPlayers() -> [Player] {
        guard !players.isEmpty else { return [] }
        let maxScore = players.map { $0.score }.max() ?? 0
        return players.filter { $0.score == maxScore }
    }
    
    func getPlayerRank(_ player: Player) -> Int {
        let sortedPlayers = players.sorted { $0.score > $1.score }
        return (sortedPlayers.firstIndex(of: player) ?? 0) + 1
    }
}
