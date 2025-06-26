//
//  CardView.swift
//  IOS-Hackathon-25
//

import SwiftUI

struct CardView: View {
    let card: Card?
    let isRevealed: Bool
    let animationOffset: CGFloat
    
    init(card: Card?, isRevealed: Bool = true, animationOffset: CGFloat = 0) {
        self.card = card
        self.isRevealed = isRevealed
        self.animationOffset = animationOffset
    }
    
    var body: some View {
        ZStack {
            // Card background
            RoundedRectangle(cornerRadius: 12)
                .fill(cardBackgroundColor)
                .frame(width: 100, height: 140)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(cardBorderColor, lineWidth: 2)
                )
            
            if let card = card, isRevealed {
                // Card content
                VStack(spacing: 4) {
                    // Top rank and suit
                    HStack {
                        Text(card.rank.displayValue)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(card.suit.color == .red ? .red : .black)
                        Spacer()
                    }
                    
                    // Center suit symbol
                    Text(card.suit.rawValue)
                        .font(.system(size: 32))
                    
                    // Bottom rank and suit (rotated)
                    HStack {
                        Spacer()
                        Text(card.rank.displayValue)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(card.suit.color == .red ? .red : .black)
                            .rotationEffect(.degrees(180))
                    }
                }
                .padding(8)
            } else if card != nil && !isRevealed {
                // Card back design
                VStack {
                    Image(systemName: "diamond.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.blue)
                    Text("🂠")
                        .font(.system(size: 20))
                }
            } else {
                // Empty card placeholder
                Text("?")
                    .font(.system(size: 48, weight: .light))
                    .foregroundColor(.gray)
            }
        }
        .offset(x: animationOffset)
        .shadow(color: .black.opacity(0.2), radius: 4, x: 2, y: 2)
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
    @State private var animationOffset: CGFloat = 0
    @State private var scale: CGFloat = 1.0
    @State private var rotation: Double = 0
    
    var body: some View {
        CardView(card: card, isRevealed: isRevealed, animationOffset: animationOffset)
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
