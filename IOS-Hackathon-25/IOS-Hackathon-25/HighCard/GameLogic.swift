//
//  GameLogic.swift
//  IOS-Hackathon-25

import Foundation

// MARK: - Game State and Logic

enum GameState {
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
        case .playerWins: return "You Win!"
        case .computerWins: return "Computer Wins!"
        case .tie: return "It's a Tie!"
        }
    }
}

class GameLogic: ObservableObject {
    @Published var deck = Deck()
    @Published var playerCard: Card?
    @Published var computerCard: Card?
    @Published var playerScore = 0
    @Published var computerScore = 0
    @Published var gameState: GameState = .waiting
    @Published var currentRoundResult: RoundResult?
    @Published var gameMessage = "Tap 'Draw Cards' to start!"
    
    private let maxRounds = 26 // Half the deck
    private var roundsPlayed = 0
    
    func startNewGame() {
        deck.resetDeck()
        playerCard = nil
        computerCard = nil
        playerScore = 0
        computerScore = 0
        roundsPlayed = 0
        gameState = .waiting
        currentRoundResult = nil
        gameMessage = "Tap 'Draw Cards' to start!"
    }
    
    func drawCards() {
        guard gameState != .gameOver else { return }
        
        // Draw cards for both players
        playerCard = deck.drawCard()
        computerCard = deck.drawCard()
        
        guard let playerCard = playerCard, let computerCard = computerCard else {
            endGame()
            return
        }
        
        gameState = .playing
        
        // Determine round winner
        let result = determineRoundWinner(playerCard: playerCard, computerCard: computerCard)
        currentRoundResult = result
        
        // Update scores
        switch result {
        case .playerWins:
            playerScore += 1
        case .computerWins:
            computerScore += 1
        case .tie:
            break // No score change
        }
        
        roundsPlayed += 1
        gameMessage = result.message
        gameState = .roundResult
        
        // Check if game should end
        if roundsPlayed >= maxRounds || deck.isEmpty {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.endGame()
            }
        }
    }
    
    private func determineRoundWinner(playerCard: Card, computerCard: Card) -> RoundResult {
        if playerCard.value > computerCard.value {
            return .playerWins
        } else if computerCard.value > playerCard.value {
            return .computerWins
        } else {
            return .tie
        }
    }
    
    private func endGame() {
        gameState = .gameOver
        
        if playerScore > computerScore {
            gameMessage = "🎉 You won the game! Final Score: \(playerScore)-\(computerScore)"
        } else if computerScore > playerScore {
            gameMessage = "💻 Computer won the game! Final Score: \(computerScore)-\(playerScore)"
        } else {
            gameMessage = "🤝 It's a tie game! Final Score: \(playerScore)-\(computerScore)"
        }
    }
    
    func canDrawCards() -> Bool {
        return gameState == .waiting || (gameState == .roundResult && !deck.isEmpty && roundsPlayed < maxRounds)
    }
    
    func resetForNextRound() {
        if gameState == .roundResult && canDrawCards() {
            gameState = .waiting
            currentRoundResult = nil
            gameMessage = "Draw next cards!"
        }
    }
    
    // Game statistics
    var cardsRemaining: Int {
        return deck.remainingCards
    }
    
    var roundsRemaining: Int {
        return max(0, maxRounds - roundsPlayed)
    }
    
    var gameProgress: Double {
        return Double(roundsPlayed) / Double(maxRounds)
    }
}
