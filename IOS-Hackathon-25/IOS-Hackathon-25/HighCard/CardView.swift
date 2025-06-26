//
//  CardView.swift
//  IOS-Hackathon-25
//

import SwiftUI

struct CardView: View {
    let card: Card?
    let isRevealed: Bool
    let animationOffset: CGFloat
    let size: CardSize
    
    enum CardSize {
        case small, medium, large
        
        var dimensions: (width: CGFloat, height: CGFloat) {
            switch self {
            case .small: return (70, 98)
            case .medium: return (85, 119)
            case .large: return (100, 140)
            }
        }
        
        var fontSize: CGFloat {
            switch self {
            case .small: return 10
            case .medium: return 12
            case .large: return 14
            }
        }
        
        var suitSize: CGFloat {
            switch self {
            case .small: return 20
            case .medium: return 26
            case .large: return 32
            }
        }
    }
    
    init(card: Card?, isRevealed: Bool = true, animationOffset: CGFloat = 0, size: CardSize = .large) {
        self.card = card
        self.isRevealed = isRevealed
        self.animationOffset = animationOffset
        self.size = size
    }
    
    var body: some View {
        ZStack {
            // Card background
            RoundedRectangle(cornerRadius: size == .small ? 8 : 12)
                .fill(cardBackgroundColor)
                .frame(width: size.dimensions.width, height: size.dimensions.height)
                .overlay(
                    RoundedRectangle(cornerRadius: size == .small ? 8 : 12)
                        .stroke(cardBorderColor, lineWidth: size == .small ? 1 : 2)
                )
            
            if let card = card, isRevealed {
                // Card content
                VStack(spacing: size == .small ? 2 : 4) {
                    // Top rank and suit
                    HStack {
                        Text(card.rank.displayValue)
                            .font(.system(size: size.fontSize, weight: .bold))
                            .foregroundColor(card.suit.color == .red ? .red : .black)
                        Spacer()
                    }
                    
                    Spacer()
                    
                    // Center suit symbol
                    Text(card.suit.rawValue)
                        .font(.system(size: size.suitSize))
                    
                    Spacer()
                    
                    // Bottom rank and suit (rotated)
                    HStack {
                        Spacer()
                        Text(card.rank.displayValue)
                            .font(.system(size: size.fontSize, weight: .bold))
                            .foregroundColor(card.suit.color == .red ? .red : .black)
                            .rotationEffect(.degrees(180))
                    }
                }
                .padding(size == .small ? 4 : 8)
            } else if card != nil && !isRevealed {
                // Card back design
                VStack {
                    Image(systemName: "diamond.fill")
                        .font(.system(size: size.suitSize * 0.8))
                        .foregroundColor(.blue)
                    Text("🂠")
                        .font(.system(size: size.suitSize * 0.6))
                }
            } else {
                // Empty card placeholder
                Text("?")
                    .font(.system(size: size.suitSize, weight: .light))
                    .foregroundColor(.gray)
            }
        }
        .offset(x: animationOffset)
        .shadow(color: .black.opacity(0.2), radius: size == .small ? 2 : 4, x: 1, y: 1)
    }
    
    private var cardBackgroundColor: Color {
        if card == nil {
            return Color(.systemGray6)
        }
        return .white
    }
    
    private var cardBorderColor: Color {
        if card == nil {
            return Color(.systemGray4)
        }
        return .black.opacity(0.3)
    }
}

struct AnimatedCardView: View {
    let card: Card?
    let isRevealed: Bool
    let size: CardView.CardSize
    @State private var animationOffset: CGFloat = 0
    @State private var scale: CGFloat = 1.0
    @State private var rotation: Double = 0
    
    init(card: Card?, isRevealed: Bool = true, size: CardView.CardSize = .large) {
        self.card = card
        self.isRevealed = isRevealed
        self.size = size
    }
    
    var body: some View {
        CardView(card: card, isRevealed: isRevealed, animationOffset: animationOffset, size: size)
            .scaleEffect(scale)
            .rotationEffect(.degrees(rotation))
            .onAppear {
                if card != nil {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        animationOffset = 0
                        scale = 1.0
                    }
                }
            }
            .onChange(of: card) { oldCard, newCard in
                if newCard != nil && oldCard != newCard {
                    // Slide in animation
                    animationOffset = -200
                    scale = 0.8
                    rotation = -10
                    
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                        animationOffset = 0
                        scale = 1.0
                        rotation = 0
                    }
                }
            }
    }
}

struct PlayerCardView: View {
    let player: Player
    let isWinner: Bool
    let cardSize: CardView.CardSize
    let showCard: Bool
    
    init(player: Player, isWinner: Bool = false, cardSize: CardView.CardSize = .medium, showCard: Bool = true) {
        self.player = player
        self.isWinner = isWinner
        self.cardSize = cardSize
        self.showCard = showCard
    }
    
    var body: some View {
        VStack(spacing: 8) {
            // Player name and score
            VStack(spacing: 2) {
                Text(player.name)
                    .font(cardSize == .small ? .caption : .headline)
                    .fontWeight(.semibold)
                    .foregroundColor(isWinner ? .green : .primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                
                Text("\(player.score)")
                    .font(cardSize == .small ? .caption : .title2)
                    .fontWeight(.bold)
                    .foregroundColor(isWinner ? .green : .primary)
                    .background(
                        Circle()
                            .fill(isWinner ? Color.green.opacity(0.2) : Color.clear)
                            .frame(width: cardSize == .small ? 30 : 40, height: cardSize == .small ? 30 : 40)
                    )
            }
            
            // Player's card
            if showCard {
                AnimatedCardView(
                    card: player.currentCard,
                    isRevealed: true,
                    size: cardSize
                )
            }
        }
    }
}

struct ScoreView: View {
    let playerName: String
    let score: Int
    let isWinner: Bool
    
    var body: some View {
        VStack(spacing: 4) {
            Text(playerName)
                .font(.headline)
                .foregroundColor(isWinner ? .green : .primary)
            
            Text("\(score)")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(isWinner ? .green : .primary)
                .background(
                    Circle()
                        .fill(isWinner ? Color.green.opacity(0.2) : Color.clear)
                        .frame(width: 60, height: 60)
                )
        }
    }
}

struct GameStatsView: View {
    let cardsRemaining: Int
    let roundsRemaining: Int
    let gameProgress: Double
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "square.stack.3d.up")
                    .foregroundColor(.blue)
                Text("Cards: \(cardsRemaining)")
                    .font(.caption)
                
                Spacer()
                
                Image(systemName: "timer")
                    .foregroundColor(.orange)
                Text("Rounds: \(roundsRemaining)")
                    .font(.caption)
            }
            
            // Progress bar
            ProgressView(value: gameProgress)
                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                .frame(height: 4)
        }
        .padding(.horizontal)
    }
}

struct PlayerSetupView: View {
    @ObservedObject var gameLogic: GameLogic
    @State private var newPlayerName = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Player Setup")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top)
            
            Text("Add 2-6 players to start the game")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            // Add player section
            VStack(spacing: 12) {
                HStack {
                    TextField("Enter player name", text: $newPlayerName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onSubmit {
                            addPlayer()
                        }
                    
                    Button("Add") {
                        addPlayer()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(newPlayerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || gameLogic.players.count >= 6)
                }
                .padding(.horizontal)
                
                Text("Players: \(gameLogic.players.count)/6")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Current players list
            if !gameLogic.players.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Current Players:")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                        ForEach(Array(gameLogic.players.enumerated()), id: \.element.id) { index, player in
                            HStack {
                                Text(player.name)
                                    .font(.subheadline)
                                
                                Spacer()
                                
                                Button(action: {
                                    gameLogic.removePlayer(at: index)
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.red)
                                }
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            
            Spacer()
            
            // Game message
            Text(gameLogic.gameMessage)
                .font(.title3)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            // Start game button
            Button(action: {
                gameLogic.startNewGame()
            }) {
                Text("Start Game")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: gameLogic.canStartGame() ? [.green, .green.opacity(0.8)] : [.gray, .gray.opacity(0.8)]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
            }
            .disabled(!gameLogic.canStartGame())
            .padding(.horizontal)
            .padding(.bottom)
        }
        .alert("Invalid Name", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func addPlayer() {
        let trimmedName = newPlayerName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedName.isEmpty else {
            alertMessage = "Player name cannot be empty"
            showingAlert = true
            return
        }
        
        guard gameLogic.players.count < 6 else {
            alertMessage = "Maximum 6 players allowed"
            showingAlert = true
            return
        }
        
        guard !gameLogic.players.contains(where: { $0.name.lowercased() == trimmedName.lowercased() }) else {
            alertMessage = "Player name already exists"
            showingAlert = true
            return
        }
        
        gameLogic.addPlayer(name: trimmedName)
        newPlayerName = ""
    }
}
