//
//  DiceGame.swift
//  IOS-Hackathon-25
//
//  Created by Tlaitirang Rathete on 26/6/2025.
//

import SwiftUI

struct DiceGame: View {
    let players: [String]
    @Environment(\.presentationMode) var presentationMode
    
    @State private var diceValues: [Int] = []
    @State private var activePlayers: [String] = []
    @State private var isRolling = false
    @State private var gameState: GameState = .ready
    @State private var winner: String = ""
    @State private var tiedPlayers: [String] = []
    @State private var showWinner = false
    @State private var showTie = false
    
    enum GameState {
        case ready, rolling, finished, tie
    }
    
    var body: some View {
        ZStack {
            // Background
            Image("Bg")
                .resizable()
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                // Title
                Text("Dice")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top)
                
                Spacer()
                
                // Dice Grid
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 20), count: 2), spacing: 20) {
                    ForEach(0..<activePlayers.count, id: \.self) { index in
                        VStack(spacing: 8) {
                            // Dice
                            ZStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white)
                                    .frame(width: 140, height: 140)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.black, lineWidth: 2)
                                    )
                                    .shadow(color: winner == activePlayers[index] ? .yellow : .clear, radius: winner == activePlayers[index] ? 20 : 0)
                                    .scaleEffect(winner == activePlayers[index] ? 1.1 : 1.0)
                                    .animation(.easeInOut(duration: 0.5), value: winner)
                                
                                if index < diceValues.count {
                                    DiceFaceView(value: diceValues[index])
                                        .scaleEffect(isRolling ? 0.8 : 1.0)
                                        .rotationEffect(.degrees(isRolling ? 360 : 0))
                                        .animation(.easeInOut(duration: 0.5), value: isRolling)
                                }
                            }
                            
                            // Player Name
                            Text(activePlayers[index])
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(winner == activePlayers[index] ? .yellow : .white)
                                .shadow(color: winner == activePlayers[index] ? .yellow : .clear, radius: winner == activePlayers[index] ? 10 : 0)
                                .scaleEffect(winner == activePlayers[index] ? 1.2 : 1.0)
                                .animation(.easeInOut(duration: 0.5), value: winner)
                        }
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Game Controls
                VStack(spacing: 20) {
                    if gameState == .ready || gameState == .tie {
                        Button(action: rollDice) {
                            Text(gameState == .tie ? "Roll Again" : "Roll Dice")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(isRolling ? Color.gray : Color.blue)
                                .cornerRadius(12)
                        }
                        .disabled(isRolling)
                        .padding(.horizontal)
                    }
                    
                    if gameState == .finished {
                        Button(action: resetGame) {
                            Text("Play Again")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .cornerRadius(12)
                        }
                        .padding(.horizontal)
                    }
                    
                    // Back to Home Button
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Back to Home")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.black.opacity(0.7))
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 30)
            }
            
            // Winner Popup
            if showWinner {
                ZStack {
                    Color.black.opacity(0.7)
                        .edgesIgnoringSafeArea(.all)
                    
                    VStack(spacing: 20) {
                        Text("🎉 WINNER! 🎉")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.yellow)
                        
                        Text(winner)
                            .font(.title)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                        
                        Button("Continue") {
                            showWinner = false
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 30)
                        .padding(.vertical, 10)
                        .background(Color.green)
                        .cornerRadius(8)
                    }
                    .padding()
                    .background(Color.black.opacity(0.8))
                    .cornerRadius(20)
                    .shadow(color: .yellow, radius: 20)
                }
                .scaleEffect(showWinner ? 1.0 : 0.1)
                .animation(.spring(response: 0.5, dampingFraction: 0.6), value: showWinner)
            }
            
            // Tie Popup
            if showTie {
                ZStack {
                    Color.black.opacity(0.7)
                        .edgesIgnoringSafeArea(.all)
                    
                    VStack(spacing: 20) {
                        Text("TIE!")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.orange)
                        
                        Text("Tied Players:")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        ForEach(tiedPlayers, id: \.self) { player in
                            Text(player)
                                .font(.title2)
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 8)
                                .background(Color.orange)
                                .cornerRadius(8)
                        }
                        
                        Text("Others eliminated!")
                            .font(.subheadline)
                            .foregroundColor(.red)
                        
                        Button("Roll Again") {
                            showTie = false
                            gameState = .tie
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 30)
                        .padding(.vertical, 10)
                        .background(Color.blue)
                        .cornerRadius(8)
                    }
                    .padding()
                    .background(Color.black.opacity(0.8))
                    .cornerRadius(20)
                    .shadow(color: .orange, radius: 20)
                }
                .scaleEffect(showTie ? 1.0 : 0.1)
                .animation(.spring(response: 0.5, dampingFraction: 0.6), value: showTie)
            }
        }
        .onAppear {
            setupGame()
        }
    }
    
    private func setupGame() {
        activePlayers = Array(players.prefix(min(players.count, 6)))
        diceValues = Array(repeating: 1, count: activePlayers.count)
        gameState = .ready
        winner = ""
    }
    
    private func resetGame() {
        setupGame()
        showWinner = false
        showTie = false
    }
    
    private func rollDice() {
        isRolling = true
        gameState = .rolling
        
        // Animate the rolling
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // Generate random dice values
            diceValues = (0..<activePlayers.count).map { _ in Int.random(in: 1...6) }
            isRolling = false
            checkWinner()
        }
    }
    
    private func checkWinner() {
        let maxValue = diceValues.max() ?? 1
        let winnersIndices = diceValues.enumerated().compactMap { index, value in
            value == maxValue ? index : nil
        }
        
        if winnersIndices.count == 1 {
            // Single winner
            winner = activePlayers[winnersIndices[0]]
            gameState = .finished
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                showWinner = true
            }
        } else {
            // Tie - multiple players with same highest score
            tiedPlayers = winnersIndices.map { activePlayers[$0] }
            activePlayers = tiedPlayers
            diceValues = Array(repeating: 1, count: activePlayers.count)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                showTie = true
            }
        }
    }
}

struct DiceFaceView: View {
    let value: Int
    
    var body: some View {
        let positions = getDotPositions(for: value)
        
        ZStack {
            ForEach(0..<positions.count, id: \.self) { index in
                Circle()
                    .fill(Color.black)
                    .frame(width: 16, height: 16)
                    .position(positions[index])
            }
        }
        .frame(width: 120, height: 120)
    }
    
    private func getDotPositions(for value: Int) -> [CGPoint] {
        let size: CGFloat = 120
        let dotSize: CGFloat = 16
        let padding: CGFloat = 25
        
        switch value {
        case 1:
            return [CGPoint(x: size/2, y: size/2)]
        case 2:
            return [
                CGPoint(x: padding, y: padding),
                CGPoint(x: size - padding, y: size - padding)
            ]
        case 3:
            return [
                CGPoint(x: padding, y: padding),
                CGPoint(x: size/2, y: size/2),
                CGPoint(x: size - padding, y: size - padding)
            ]
        case 4:
            return [
                CGPoint(x: padding, y: padding),
                CGPoint(x: size - padding, y: padding),
                CGPoint(x: padding, y: size - padding),
                CGPoint(x: size - padding, y: size - padding)
            ]
        case 5:
            return [
                CGPoint(x: padding, y: padding),
                CGPoint(x: size - padding, y: padding),
                CGPoint(x: size/2, y: size/2),
                CGPoint(x: padding, y: size - padding),
                CGPoint(x: size - padding, y: size - padding)
            ]
        case 6:
            return [
                CGPoint(x: padding, y: padding),
                CGPoint(x: size - padding, y: padding),
                CGPoint(x: padding, y: size/2),
                CGPoint(x: size - padding, y: size/2),
                CGPoint(x: padding, y: size - padding),
                CGPoint(x: size - padding, y: size - padding)
            ]
        default:
            return [CGPoint(x: size/2, y: size/2)]
        }
    }
}

#Preview {
    DiceGame(players: ["Alice", "Bob", "Charlie", "Diana"])
}
