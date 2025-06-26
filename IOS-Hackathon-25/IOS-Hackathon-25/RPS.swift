//
//  RPS.swift
//  IOS-Hackathon-25
//
//  Created by Josh Tsai on 2025/6/26.
//

import SwiftUI

struct RPS: View {
    let choices = ["👊", "✋", "✌️"]
    
    @State private var showPlayButton = true
    @State private var countdownText = ""
    
    @State private var showHands = false
    @State private var topHand = ""
    @State private var bottomHand = ""
    
    @State private var winnerText = ""
    
    var body: some View {
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
                }
            } else {
                Text(countdownText)
                    .font(.largeTitle)
                    .bold()
                    .opacity(countdownText.isEmpty ? 0 : 1)
                    .animation(.easeIn, value: countdownText)
            }
            
            if showHands {
                Spacer()
                Text(winnerText)
                    .font(.largeTitle)
                    .bold()
                Spacer()
                // 上方的手
                Text(topHand)
                    .font(.system(size: 100))
                    .rotationEffect(.degrees(180)) // 上面的手朝下
                Spacer()
                // 下方的手
                Text(bottomHand)
                    .font(.system(size: 100))
                Spacer()
                
                Button("Play Again") {
                    resetGame()
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
    
    func startGame() {
        showPlayButton = false
        countdownText = "Rock!"
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            countdownText = "Paper!"
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
            countdownText = "Scissors!"
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.4) {
            countdownText = ""
            showHands = true
            topHand = choices.randomElement()!
            bottomHand = choices.randomElement()!
            
            winnerText = getWinner()
        }
    }
    
    func resetGame() {
        showHands = false
        showPlayButton = true
        countdownText = ""
        topHand = ""
        bottomHand = ""
    }
    
    func getWinner() -> String {
        if topHand == bottomHand {
            return "Tie!"
        }
        let choiceNumber: [String: Int] = ["👊": 0, "✋": 1, "✌️": 2]
        
        let topNumber = choiceNumber[topHand] == 0 ? 3 : choiceNumber[topHand]
        if (topNumber == choiceNumber[bottomHand]! + 1) {
            return "Top Wins"
        } else {
            return "Bottom Wins"
        }
    }
}

#Preview {
    RPS()
}
