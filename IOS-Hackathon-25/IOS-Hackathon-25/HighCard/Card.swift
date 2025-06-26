//
//  Card.swift
//  IOS-Hackathon-25
//

import Foundation

// MARK: - Card Data Models

enum Suit: String, CaseIterable {
    case hearts = "♥️"
    case diamonds = "♦️"
    case clubs = "♣️"
    case spades = "♠️"
    
    var color: CardColor {
        switch self {
        case .hearts, .diamonds:
            return .red
        case .clubs, .spades:
            return .black
        }
    }
}

enum CardColor {
    case red, black
}

enum Rank: Int, CaseIterable, Comparable {
    case two = 2, three, four, five, six, seven, eight, nine, ten
    case jack = 11, queen, king, ace
    
    var displayValue: String {
        switch self {
        case .jack: return "J"
        case .queen: return "Q"
        case .king: return "K"
        case .ace: return "A"
        default: return String(rawValue)
        }
    }
    
    static func < (lhs: Rank, rhs: Rank) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}

struct Card: Identifiable, Equatable {
    let id = UUID()
    let suit: Suit
    let rank: Rank
    
    var displayString: String {
        return "\(rank.displayValue)\(suit.rawValue)"
    }
    
    var value: Int {
        return rank.rawValue
    }
}

struct Deck {
    private var cards: [Card] = []
    
    init() {
        resetDeck()
    }
    
    mutating func resetDeck() {
        cards = []
        for suit in Suit.allCases {
            for rank in Rank.allCases {
                cards.append(Card(suit: suit, rank: rank))
            }
        }
        shuffle()
    }
    
    mutating func shuffle() {
        cards.shuffle()
    }
    
    mutating func drawCard() -> Card? {
        return cards.isEmpty ? nil : cards.removeLast()
    }
    
    var remainingCards: Int {
        return cards.count
    }
    
    var isEmpty: Bool {
        return cards.isEmpty
    }
}
