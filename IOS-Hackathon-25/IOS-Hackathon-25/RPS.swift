import SwiftUI
import AVKit // Import AVKit for video playback

struct RPS: View {
    let choices = ["rock", "paper", "scissors"] // Corrected "scissor" to "scissors"

    @State private var showPlayButton = true
    @State private var countdownText = ""

    @State private var showHands = false
    @State private var topHand = ""
    @State private var bottomHand = ""

    // State for winner texts (these will be set AFTER video plays)
    @State private var winnerText = ""
    @State private var topPlayerResultText: String = ""
    @State private var bottomPlayerResultText: String = ""
    @State private var handAnimationTrigger: Bool = false

    // New state variables for video playback
    @State private var showVideo: Bool = false
    @State private var videoPlayer: AVPlayer?
    
    // Store outcome details temporarily before displaying after video
    @State private var pendingWinnerText: String = ""
    @State private var pendingTopPlayerResultText: String = ""
    @State private var pendingBottomPlayerResultText: String = ""


    var body: some View {
        ZStack {
            Image("Bg")
                .resizable()
                .ignoresSafeArea()

            VStack(spacing: 40) {
                if showPlayButton {
                    Button {
                        startGame()
                    } label: {
                        Text("Play")
                            .font(.largeTitle)
                            .bold()
                            .padding()
                            .frame(width: 200)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                            .scaleEffect(showPlayButton ? 1.0 : 0.8)
                            .animation(.spring(), value: showPlayButton)
                    }
                } else if showVideo {
                    // Show video player
                    if let player = videoPlayer {
                        VideoPlayer(player: player)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.black.opacity(0.8)) // Dark overlay
                            .edgesIgnoringSafeArea(.all)
                            .onAppear {
                                player.seek(to: .zero) // Rewind video to start
                                player.play()
                            }
                    }
                }
                else {
                    // Show countdown text
                    Text(countdownText)
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.white)
                        .opacity(countdownText.isEmpty ? 0 : 1)
                        .animation(.easeIn, value: countdownText)
                }

                if showHands {
                    Spacer()
                    Text(winnerText)
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.yellow)
                        .shadow(radius: 5)
                        .transition(.scale.combined(with: .opacity))
                        .animation(.spring(response: 0.7, dampingFraction: 0.5), value: winnerText)
                    Spacer()

                    Text(topPlayerResultText)
                        .font(.title)
                        .bold()
                        .foregroundColor(topPlayerResultText == "You Win!" ? .green : .red)
                        .opacity(topPlayerResultText.isEmpty ? 0 : 1)
                        .animation(.easeIn, value: topPlayerResultText)
                        .rotationEffect(.degrees(180))
                        .transition(.scale.combined(with: .opacity))
                        .animation(.spring(response: 0.7, dampingFraction: 0.5), value: topPlayerResultText)

                    Image(topHand)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .rotationEffect(.degrees(180))
                        .padding(.bottom, 20)
                        .scaleEffect(handAnimationTrigger ? 1.0 : 0.8)
                        .opacity(handAnimationTrigger ? 1.0 : 0.0)
                        .animation(.spring(response: 0.7, dampingFraction: 0.5), value: handAnimationTrigger)

                    Image(bottomHand)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .padding(.top, 20)
                        .scaleEffect(handAnimationTrigger ? 1.0 : 0.8)
                        .opacity(handAnimationTrigger ? 1.0 : 0.0)
                        .animation(.spring(response: 0.7, dampingFraction: 0.5), value: handAnimationTrigger)

                    Text(bottomPlayerResultText)
                        .font(.title)
                        .bold()
                        .foregroundColor(bottomPlayerResultText == "You Win!" ? .green : .red)
                        .opacity(bottomPlayerResultText.isEmpty ? 0 : 1)
                        .animation(.easeIn, value: bottomPlayerResultText)
                        .transition(.scale.combined(with: .opacity))
                        .animation(.spring(response: 0.7, dampingFraction: 0.5), value: bottomPlayerResultText)
                    Spacer()

                    Button("Play Again") {
                        resetGameAndStartNewRound()
                    }
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
                    .padding(.bottom, 50)
                }
            }
            .padding()
        }
    }

    func startGame() {
        showPlayButton = false
        countdownText = "Rock!"
        topPlayerResultText = ""
        bottomPlayerResultText = ""
        winnerText = "" // Clear winner text
        handAnimationTrigger = false
        showVideo = false // Ensure video is hidden at start
        videoPlayer = nil // Release previous player

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            countdownText = "Paper!"
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
            countdownText = "Scissors!"
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.4) {
            countdownText = ""
            determineOutcomeAndPlayVideo() // New function to handle video
        }
    }

    func determineOutcomeAndPlayVideo() {
        topHand = choices.randomElement()!
        bottomHand = choices.randomElement()!

        let outcome = getOutcomeDetails(top: topHand, bottom: bottomHand)
        
        pendingWinnerText = outcome.winnerText
        pendingTopPlayerResultText = outcome.topResult
        pendingBottomPlayerResultText = outcome.bottomResult

        if let videoURL = Bundle.main.url(forResource: outcome.videoName, withExtension: "mov") {
            videoPlayer = AVPlayer(url: videoURL)
            showVideo = true

            // Observe when the video finishes playing
            NotificationCenter.default.addObserver(
                forName: .AVPlayerItemDidPlayToEndTime,
                object: videoPlayer?.currentItem,
                queue: .main
            ) { _ in
                // Video finished, hide video and show game results
                self.showVideo = false
                self.displayGameResults()
                
                // Remove the observer to prevent multiple calls or memory leaks
                NotificationCenter.default.removeObserver(
                    self,
                    name: .AVPlayerItemDidPlayToEndTime,
                    object: self.videoPlayer?.currentItem
                )
                self.videoPlayer = nil // Release the player
            }
        } else {
            // Fallback if video asset is not found (e.g., in preview or missing file)
            print("Error: Video asset '\(outcome.videoName).mov' not found.")
            displayGameResults() // Skip video and show results directly
        }
    }

    func displayGameResults() {
        showHands = true
        winnerText = pendingWinnerText
        topPlayerResultText = pendingTopPlayerResultText
        bottomPlayerResultText = pendingBottomPlayerResultText
        handAnimationTrigger = true // Trigger hand reveal animation
    }

    func resetGameAndStartNewRound() {
        showHands = false
        winnerText = ""
        topPlayerResultText = ""
        bottomPlayerResultText = ""
        handAnimationTrigger = false
        showVideo = false
        videoPlayer = nil // Ensure player is released on reset

        startGame()
    }

    // This function now returns all the necessary outcome details including video name
    func getOutcomeDetails(top: String, bottom: String) -> (winnerText: String, topResult: String, bottomResult: String, videoName: String) {
        let choiceNumber: [String: Int] = ["rock": 0, "paper": 1, "scissors": 2]

        guard let topNum = choiceNumber[top],
              let bottomNum = choiceNumber[bottom] else {
            return ("Error: Invalid Hand", "", "", "tie") // Fallback
        }

        if top == bottom {
            return ("Tie!", "Tie!", "Tie!", "tie") // Video for tie
        }

        // Logic for determining winner and corresponding video
        if (topNum - bottomNum + 3) % 3 == 1 { // Top wins
            if top == "rock" {
                return ("Top Wins!", "You Win!", "You Lose!", "rockWins")
            } else if top == "paper" {
                return ("Top Wins!", "You Win!", "You Lose!", "paperWins")
            } else { // top == "scissors"
                return ("Top Wins!", "You Win!", "You Lose!", "scissorsWins")
            }
        } else { // Bottom wins
            if bottom == "rock" {
                return ("Bottom Wins!", "You Lose!", "You Win!", "rockWins")
            } else if bottom == "paper" {
                return ("Bottom Wins!", "You Lose!", "You Win!", "paperWins")
            } else { // bottom == "scissors"
                return ("Bottom Wins!", "You Lose!", "You Win!", "scissorsWins")
            }
        }
    }
}

#Preview {
    RPS()
}
