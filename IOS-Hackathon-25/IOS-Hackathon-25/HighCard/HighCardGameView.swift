import SwiftUI

// MARK: - Main Game View
struct HighCardGameView: View {
    let players: [String]
    @StateObject private var gameLogic = GameLogic()
    @State private var showingRoundResult = false
    @State private var buttonScale: CGFloat = 1.0
    @State private var messageOpacity: Double = 1.0
    
    // Get player names or use defaults
    private var player1Name: String {
        players.first ?? "Player 1"
    }
    
    private var player2Name: String {
        players.count > 1 ? players[1] : "Player 2"
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background image (same as ContentView)
                Image("Bg")
                    .resizable()
                    .edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Title
                        Text("High Card Game")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.top)
                        
                        // Game stats
                        GameStatsView(
                            cardsRemaining: gameLogic.cardsRemaining,
                            roundsRemaining: gameLogic.roundsRemaining,
                            gameProgress: gameLogic.gameProgress
                        )
                        
                        // Score section
                        HStack(spacing: 50) {
                            ScoreView(
                                playerName: player1Name,
                                score: gameLogic.playerScore,
                                isWinner: gameLogic.gameState == .gameOver && gameLogic.playerScore > gameLogic.computerScore
                            )
                            
                            ScoreView(
                                playerName: player2Name,
                                score: gameLogic.computerScore,
                                isWinner: gameLogic.gameState == .gameOver && gameLogic.computerScore > gameLogic.playerScore
                            )
                        }
                        .padding(.vertical)
                        
                        // Cards section
                        VStack(spacing: 30) {
                            // Player 1 card
                            VStack {
                                Text("\(player1Name)'s Card")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                AnimatedCardView(
                                    card: gameLogic.computerCard,
                                    isRevealed: gameLogic.gameState == .playing || gameLogic.gameState == .roundResult || gameLogic.gameState == .gameOver
                                )
                            }
                            
                            // VS indicator
                            if gameLogic.gameState == .playing || gameLogic.gameState == .roundResult {
                                Text("VS")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.orange)
                                    .scaleEffect(showingRoundResult ? 1.2 : 1.0)
                                    .animation(.easeInOut(duration: 0.5).repeatCount(3), value: showingRoundResult)
                            }
                            
                            // Player 2 card
                            VStack {
                                Text("\(player2Name)'s Card")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                AnimatedCardView(
                                    card: gameLogic.playerCard,
                                    isRevealed: gameLogic.gameState == .playing || gameLogic.gameState == .roundResult || gameLogic.gameState == .gameOver
                                )
                            }
                        }
                        
                        // Game message
                        Text(gameLogic.gameMessage)
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(messageColor)
                            .multilineTextAlignment(.center)
                            .opacity(messageOpacity)
                            .padding(.horizontal)
                            .onChange(of: gameLogic.gameMessage) { _, _ in
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    messageOpacity = 0.7
                                }
                                withAnimation(.easeInOut(duration: 0.3).delay(0.1)) {
                                    messageOpacity = 1.0
                                }
                            }
                        
                        // Action buttons
                        VStack(spacing: 15) {
                            // Draw/Next button
                            if gameLogic.canDrawCards() {
                                Button(action: {
                                    impactFeedback()
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                        buttonScale = 0.95
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                            buttonScale = 1.0
                                        }
                                    }
                                    
                                    gameLogic.drawCards()
                                    showingRoundResult = true
                                    
                                    // Reset round result animation after delay
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                        showingRoundResult = false
                                        gameLogic.resetForNextRound()
                                    }
                                }) {
                                    Text(gameLogic.gameState == .waiting ? "Draw Cards" : "Next Round")
                                        .font(.title2)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(
                                            LinearGradient(
                                                gradient: Gradient(colors: [.blue, .blue.opacity(0.8)]),
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .cornerRadius(12)
                                }
                                .scaleEffect(buttonScale)
                                .disabled(gameLogic.gameState == .playing)
                            }
                            
                            // New game button
                            Button(action: {
                                impactFeedback()
                                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                    gameLogic.startNewGame()
                                    showingRoundResult = false
                                }
                            }) {
                                Text("New Game")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(
                                        LinearGradient(
                                            gradient: Gradient(colors: [.green, .green.opacity(0.8)]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .cornerRadius(12)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom)
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("High Card")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var messageColor: Color {
        switch gameLogic.currentRoundResult {
        case .playerWins:
            return .green
        case .computerWins:
            return .red
        case .tie:
            return .orange
        case .none:
            return .white
        }
    }
    
    private func impactFeedback() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
}

#Preview {
    HighCardGameView(players: ["Alice", "Bob"])
}
