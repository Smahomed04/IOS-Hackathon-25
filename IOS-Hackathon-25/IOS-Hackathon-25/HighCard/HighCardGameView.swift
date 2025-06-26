//
//  HighCardGameView.swift
//  IOS-Hackathon-25
//
//  Created by Sa'd Mahomed on 26/6/2025.
//

import SwiftUI

// MARK: - Main Game View

struct HighCardGameView: View {
    @StateObject private var gameLogic = GameLogic()
    @State private var showingRoundResult = false
    @State private var buttonScale: CGFloat = 1.0
    @State private var messageOpacity: Double = 1.0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [.blue.opacity(0.1), .green.opacity(0.1)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                if gameLogic.gameState == .setup {
                    PlayerSetupView(gameLogic: gameLogic)
                } else {
                    gamePlayView(geometry: geometry)
                }
            }
        }
    }
    
    @ViewBuilder
    private func gamePlayView(geometry: GeometryProxy) -> some View {
        VStack(spacing: 16) {
            // Title and setup button
            HStack {
                VStack(alignment: .leading) {
                    Text("High Card Game")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)
                    
                    Text("\(gameLogic.players.count) Players")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button("Setup") {
                    gameLogic.goToSetup()
                }
                .buttonStyle(.bordered)
            }
            .padding(.horizontal)
            .padding(.top)
            
            // Game stats
            GameStatsView(
                cardsRemaining: gameLogic.cardsRemaining,
                roundsRemaining: gameLogic.roundsRemaining,
                gameProgress: gameLogic.gameProgress
            )
            
            // Players section
            playersView(geometry: geometry)
            
            Spacer()
            
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
            actionButtonsView()
        }
    }
    
    @ViewBuilder
    private func playersView(geometry: GeometryProxy) -> some View {
        let isCompact = gameLogic.players.count > 4 || geometry.size.width < 400
        let cardSize: CardView.CardSize = isCompact ? .small : .medium
        let columns = gridColumns(for: gameLogic.players.count, isCompact: isCompact)
        
        LazyVGrid(columns: columns, spacing: isCompact ? 12 : 20) {
            ForEach(gameLogic.players) { player in
                PlayerCardView(
                    player: player,
                    isWinner: gameLogic.roundWinners.contains(player) ||
                             (gameLogic.gameState == .gameOver && gameLogic.getLeadingPlayers().contains(player)),
                    cardSize: cardSize,
                    showCard: gameLogic.gameState == .playing ||
                             gameLogic.gameState == .roundResult ||
                             gameLogic.gameState == .gameOver
                )
                .scaleEffect(gameLogic.roundWinners.contains(player) && showingRoundResult ? 1.1 : 1.0)
                .animation(.spring(response: 0.4, dampingFraction: 0.6), value: showingRoundResult)
            }
        }
        .padding(.horizontal)
    }
    
    @ViewBuilder
    private func actionButtonsView() -> some View {
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
            
            // Action buttons row
            HStack(spacing: 12) {
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
                
                // Change players button
                Button(action: {
                    impactFeedback()
                    gameLogic.goToSetup()
                }) {
                    Text("Players")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [.orange, .orange.opacity(0.8)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                }
            }
        }
        .padding(.horizontal)
        .padding(.bottom)
    }
    
    private func gridColumns(for playerCount: Int, isComp
