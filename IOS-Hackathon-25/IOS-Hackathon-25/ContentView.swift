//
//  ContentView.swift
//  IOS-Hackathon-25
//
//  Created by Tlaitirang Rathete on 26/6/2025.
//
import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var players: [Player]
    
    @State private var numberOfPlayers: Int = 2
    @State private var playerNames: [String] = ["Player 1", "Player 2"]
    @State private var selectedGameType: String = "Coin Flip"
    @State private var showingGame = false
    
    let gameTypes = ["Coin Flip", "Rock, Paper, Scissors", "Roulette", "Dice", "High Card", "Random"]
    
    var availableGameTypes: [String] {
        if numberOfPlayers > 5 {
            return ["Roulette"]
        } else if numberOfPlayers > 2 {
            return gameTypes.filter { $0 != "Coin Flip" && $0 != "Rock, Paper, Scissors" }
        } else {
            return gameTypes
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Image("Bg")
                    .resizable()
                    .edgesIgnoringSafeArea(.all)
                VStack(spacing: 20) {
                    // App Title
                    Text("Luck's Up")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.top)
                    
                    ScrollView {
                        VStack(spacing: 20) {
                            // Number of Players Section
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Number of Players")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                HStack {
                                    Button("-") {
                                        if numberOfPlayers > 2 {
                                            numberOfPlayers -= 1
                                            updatePlayerNames()
                                        }
                                    }
                                    .frame(width: 40, height: 40)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .clipShape(Circle())
                                    .disabled(numberOfPlayers <= 2)
                                    
                                    Text("\(numberOfPlayers)")
                                        .font(.title2)
                                        .fontWeight(.semibold)
                                        .frame(minWidth: 50)
                                    
                                    Button("+") {
                                        if numberOfPlayers < 10 {
                                            numberOfPlayers += 1
                                            updatePlayerNames()
                                        }
                                    }
                                    .frame(width: 40, height: 40)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .clipShape(Circle())
                                    .disabled(numberOfPlayers >= 10)
                                }
                            }
                            .padding()
                            .background(Color.gray.opacity(0.8))
                            .cornerRadius(12)
                            
                            // Player Names Section
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Player Names")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                ForEach(0..<numberOfPlayers, id: \.self) { index in
                                    TextField("Player \(index + 1)", text: Binding(
                                        get: {
                                            index < playerNames.count ? playerNames[index] : "Player \(index + 1)"
                                        },
                                        set: { newValue in
                                            if index < playerNames.count {
                                                playerNames[index] = newValue
                                            }
                                        }
                                    ))
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                }
                            }
                            .padding()
                            .background(Color.gray.opacity(0.8))
                            .cornerRadius(12)
                            
                            // Game Type Selection
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Game Type")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                Picker("Game Type", selection: $selectedGameType) {
                                    ForEach(availableGameTypes, id: \.self) { gameType in
                                        Text(gameType).tag(gameType)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                .padding()
                                .background(Color.white)
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                                
                                // Game restrictions info
                                if numberOfPlayers > 5 {
                                    Text("Only Roulette available for 6+ players")
                                        .font(.caption)
                                        .foregroundColor(.orange)
                                } else if numberOfPlayers > 2 {
                                    Text("Coin Flip and Rock, Paper, Scissors disabled for 3+ players")
                                        .font(.caption)
                                        .foregroundColor(.orange)
                                }
                            }
                            .padding()
                            .background(Color.gray.opacity(0.8))
                            .cornerRadius(12)
                            
                            // Start Game Button
                            Button(action: {
                                startGame()
                            }) {
                                Text("Start Game")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.green)
                                    .cornerRadius(12)
                            }
                            .padding(.top, 10)
                            
                            // Previous Games Section (if any exist)
                            if !players.isEmpty {
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("Previous Games")
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    
                                    ForEach(players.prefix(3)) { player in
                                        HStack {
                                            VStack(alignment: .leading) {
                                                Text("\(player.numberOfPlayers) players - \(player.selectedGameType)")
                                                    .font(.subheadline)
                                                Text(player.playerNames.joined(separator: ", "))
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                                    .lineLimit(1)
                                            }
                                            Spacer()
                                            Button("Load") {
                                                loadPreviousGame(player)
                                            }
                                            .font(.caption)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(Color.blue)
                                            .foregroundColor(.white)
                                            .cornerRadius(6)
                                        }
                                        .padding(.vertical, 4)
                                    }
                                }
                                .padding()
                                .background(Color.gray.opacity(0.8))
                                .cornerRadius(12)
                            }
                        }
                        .padding()
                    }
                }
            }
        }
        .onChange(of: numberOfPlayers) { _ in
            updateSelectedGameType()
        }
        .sheet(isPresented: $showingGame) {
            GameView(
                players: playerNames,
                gameType: selectedGameType
            )
        }
    }
    
    private func updatePlayerNames() {
        if numberOfPlayers > playerNames.count {
            // Add new players
            for i in playerNames.count..<numberOfPlayers {
                playerNames.append("Player \(i + 1)")
            }
        } else if numberOfPlayers < playerNames.count {
            // Remove excess players
            playerNames = Array(playerNames.prefix(numberOfPlayers))
        }
    }
    
    private func updateSelectedGameType() {
        if !availableGameTypes.contains(selectedGameType) {
            selectedGameType = availableGameTypes.first ?? "Random"
        }
    }
    
    private func startGame() {
        // Save the current game setup to SwiftData
        let newPlayer = Player(
            numberOfPlayers: numberOfPlayers,
            playerNames: playerNames,
            selectedGameType: selectedGameType
        )
        
        modelContext.insert(newPlayer)
        
        do {
            try modelContext.save()
            print("Game saved successfully")
        } catch {
            print("Failed to save game: \(error)")
        }
        
        // Start the game
        print("Starting \(selectedGameType) with players: \(playerNames)")
        showingGame = true
    }
    
    private func loadPreviousGame(_ player: Player) {
        numberOfPlayers = player.numberOfPlayers
        playerNames = player.playerNames
        selectedGameType = player.selectedGameType
    }
}

// Placeholder GameView - you'll need to implement this
struct GameView: View {
    let players: [String]
    let gameType: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Playing \(gameType)")
                    .font(.largeTitle)
                    .padding()
                
                Text("Players: \(players.joined(separator: ", "))")
                    .padding()
                
                // Add your game logic here
                
                Spacer()
            }
            .navigationTitle(gameType)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Player.self, inMemory: true)
}
