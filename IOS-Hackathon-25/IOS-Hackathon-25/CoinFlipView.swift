import SwiftUI
//import ConfettiSwiftUI // Import ConfettiSwiftUI

// MARK: - CoinChoice Enum
// Represents a player's choice: Heads or Tails.
enum CoinChoice: String, CaseIterable, Identifiable {
    case heads = "Heads"
    case tails = "Tails"
    var id: String { self.rawValue } // Conformance to Identifiable
}

// MARK: - CoinResult Enum
// Represents the actual outcome of the coin flip.
enum CoinResult: String, CaseIterable, Identifiable {
    case heads = "Heads"
    case tails = "Tails"
    var id: String { self.rawValue } // Conformance to Identifiable
}

// MARK: - Player Model
// Represents a player in the Coin Flip game.
struct CoinFlipPlayer: Identifiable {
    let id = UUID()
    var name: String
    var choice: CoinChoice? // Player's chosen side (Heads/Tails)
    var isWinner: Bool = false
}

// MARK: - ContentView
// The main view for the Coin Flip game UI.
struct CoinFlipView: View {
    // MARK: - State Variables
    @State private var player1Name: String = "Player 1"
    @State private var player2Name: String = "Player 2"
    // Player choices are now fixed, so we can remove the @State if they are not bound to UI elements
    // We will keep them as properties but ensure they are not user-modifiable.
    private let player1Choice: CoinChoice = .heads // Player 1 is always Heads
    private let player2Choice: CoinChoice = .tails // Player 2 is always Tails

    @State private var coinResult: CoinResult? = nil // Stores the outcome of the flip
    @State private var winnerName: String? = nil // Stores the name of the winner
    @State private var showPlayAgainButton: Bool = false
    @State private var isFlipping: Bool = false // Controls coin animation
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var confettiCounter = 0 // State variable for confetti

    var body: some View {
        NavigationView {
            ZStack {
                // Background: Dark gradient for a game/night mode feel
                Image("Bg") // <- your actual image asset name
                    .resizable()
                    .ignoresSafeArea()

                VStack(spacing: 30) {
                    Spacer()

                    Text("Coin Flip")
                        .font(.largeTitle)
                        .fontWeight(.heavy)
                        .foregroundColor(.white)
                        .shadow(radius: 5)

                    // Player 1 Input
                    VStack {
                        TextField("Player 1 Name", text: $player1Name)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)
                            .background(Color.white.opacity(0.8).cornerRadius(10))
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.words)

                        // Display fixed choice for Player 1
                        Text("Player 1 chooses: Heads")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.top, 5)
                    }

                    // Player 2 Input
                    VStack {
                        TextField("Player 2 Name", text: $player2Name)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)
                            .background(Color.white.opacity(0.8).cornerRadius(10))
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.words)

                        // Display fixed choice for Player 2
                        Text("Player 2 chooses: Tails")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.top, 5)
                    }

                    Spacer()

                    // Coin Image Display
                    imageForCoinDisplay()
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                        .rotation3DEffect(
                            .degrees(isFlipping ? 360 * 5 : 0), // Spin 5 times
                            axis: (x: 0, y: 1, z: 0) // Rotate around Y axis
                        )
                        .animation(isFlipping ? .easeOut(duration: 1.5) : .none, value: isFlipping) // Animation for flip
                        .scaleEffect(isFlipping ? 1.2 : 1.0) // Slight scale up during flip
                        .animation(isFlipping ? .easeInOut(duration: 0.75).repeatCount(2, autoreverses: true) : .none, value: isFlipping)
                        .padding(.vertical, 20)

                    // Result Display
                    if let result = coinResult {
                        Text("🪙 It's \(result.rawValue)!")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.bottom, 5)
                            .transition(.opacity) // Fade in result
                    }

                    if let winner = winnerName {
                        Text("🎉 \(winner) wins the toss!")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                            .background(Color.black.opacity(0.6).cornerRadius(15))
                            .transition(.opacity) // Fade in winner message
                    }

                    Spacer()

                    // Action Buttons
                    if !showPlayAgainButton {
                        Button(action: flipCoin) {
                            Label("Flip the Coin", systemImage: "arrow.triangle.2.circlepath")
                                .font(.title2)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .leading, endPoint: .trailing))
                                .foregroundColor(.white)
                                .cornerRadius(25)
                                .shadow(radius: 10)
                        }
                        .padding(.horizontal)
                    } else {
                        Button(action: resetGame) {
                            Label("Play Again", systemImage: "arrow.clockwise")
                                .font(.title2)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(LinearGradient(gradient: Gradient(colors: [Color.orange, Color.red]), startPoint: .leading, endPoint: .trailing))
                                .foregroundColor(.white)
                                .cornerRadius(25)
                                .shadow(radius: 10)
                        }
                        .padding(.horizontal)
                        .transition(.scale) // Animate play again button
                    }

                    Spacer()
                }
                .padding() // Add padding around the whole VStack
            }
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("Input Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }

    // MARK: - Helper Functions
    // Determines which image to display for the coin.
    // It now uses the "heads" image for the flipping/initial state and your custom assets
    // for the final result.
    private func imageForCoinDisplay() -> Image {
        if isFlipping {
            // During flip, use the "heads" image directly to animate the spinning effect.
            return Image("heads")
        } else if let result = coinResult {
            // After flip, display the actual asset based on the result.
            return Image(result == .heads ? "heads" : "tails")
        } else {
            // Initial state (before first flip or after reset), show "heads".
            return Image("heads")
        }
    }

    // MARK: - Game Logic Functions
    private func flipCoin() {
        // Basic validation for player names (not empty)
        guard !player1Name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !player2Name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            alertMessage = "Please enter names for both players."
            showingAlert = true
            return
        }

        // Reset previous results
        coinResult = nil
        winnerName = nil
        showPlayAgainButton = false
        isFlipping = true

        // Simulate a flip with a delay for animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { // Duration matches animation
            let randomResult = Bool.random() ? CoinResult.heads : CoinResult.tails
            self.coinResult = randomResult
            self.determineWinner(result: randomResult)
            self.isFlipping = false // Stop animation
            self.showPlayAgainButton = true
            self.confettiCounter += 1
        }
    }

    private func determineWinner(result: CoinResult) {
        // Determine winner based on fixed choices
        if player1Choice.rawValue == result.rawValue {
            winnerName = player1Name
        } else if player2Choice.rawValue == result.rawValue {
            winnerName = player2Name
        } else {
            // This case should not happen if choices are fixed to Heads/Tails and result is one of them.
            winnerName = "No one (should not happen with fixed choices)"
        }
    }

    private func resetGame() {
        coinResult = nil
        winnerName = nil
        showPlayAgainButton = false
        isFlipping = false
    }
}

#Preview {
    CoinFlipView()
}
