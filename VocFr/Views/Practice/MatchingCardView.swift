//
//  MatchingCardView.swift
//  VocFr
//
//  Created by Claude on 15/11/2025.
//  Phase C.1.2: Matching Game Mode - Card Component
//

import SwiftUI

struct MatchingCardView: View {
    let card: MatchingCard
    let onTap: () -> Void

    var body: some View {
        Button(action: {
            if !card.isMatched && !card.isFaceUp {
                onTap()
            }
        }) {
            ZStack {
                // Card background
                RoundedRectangle(cornerRadius: 12)
                    .fill(cardBackgroundColor)
                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)

                // Card content
                if card.isFaceUp || card.isMatched {
                    // Face up - show content
                    frontContent
                } else {
                    // Face down - show back pattern
                    backContent
                }
            }
            .rotation3DEffect(
                .degrees(card.isFaceUp || card.isMatched ? 0 : 180),
                axis: (x: 0.0, y: 1.0, z: 0.0)
            )
            .opacity(card.isMatched ? 0.6 : 1.0)
            .scaleEffect(card.isMatched ? 0.95 : 1.0)
            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: card.isFaceUp)
            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: card.isMatched)
        }
        .buttonStyle(PlainButtonStyle())
    }

    // MARK: - Card Content

    @ViewBuilder
    private var frontContent: some View {
        if card.type == .image {
            // Image card
            if !card.word.imageName.isEmpty && imageExists(named: card.word.imageName) {
                Image(card.word.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(8)
            } else {
                // Placeholder
                Image(systemName: "photo")
                    .font(.system(size: 30))
                    .foregroundColor(.gray.opacity(0.5))
            }
        } else {
            // Text card
            VStack(spacing: 4) {
                Text(card.word.canonical)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.5)
                    .lineLimit(2)
            }
            .padding(8)
        }
    }

    private var backContent: some View {
        ZStack {
            // Back pattern
            Image(systemName: "questionmark")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white.opacity(0.8))
                .rotation3DEffect(
                    .degrees(180),
                    axis: (x: 0.0, y: 1.0, z: 0.0)
                )
        }
    }

    // MARK: - Styling

    private var cardBackgroundColor: Color {
        if card.isMatched {
            return Color.green.opacity(0.3)
        } else if card.isFaceUp {
            return Color.white
        } else {
            return Color.blue.opacity(0.8)
        }
    }

    // MARK: - Helper Functions

    /// Check if an image exists in the asset catalog
    private func imageExists(named: String) -> Bool {
        #if os(iOS)
        return UIImage(named: named) != nil
        #elseif os(macOS)
        return NSImage(named: named) != nil
        #else
        return false
        #endif
    }
}

#Preview {
    let sampleWord = Word(
        id: "sample",
        canonical: "pomme",
        chinese: "苹果",
        imageName: "pomme",
        partOfSpeech: .noun,
        category: "fruit"
    )

    return VStack(spacing: 20) {
        HStack(spacing: 16) {
            // Face down
            MatchingCardView(
                card: MatchingCard(word: sampleWord, type: .image, isFaceUp: false),
                onTap: {}
            )
            .frame(width: 100, height: 100)

            // Face up - image
            MatchingCardView(
                card: MatchingCard(word: sampleWord, type: .image, isFaceUp: true),
                onTap: {}
            )
            .frame(width: 100, height: 100)

            // Face up - text
            MatchingCardView(
                card: MatchingCard(word: sampleWord, type: .text, isFaceUp: true),
                onTap: {}
            )
            .frame(width: 100, height: 100)
        }
    }
    .padding()
}
