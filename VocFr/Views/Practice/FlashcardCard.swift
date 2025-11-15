//
//  FlashcardCard.swift
//  VocFr
//
//  Created by Claude on 15/11/2025.
//  Phase C.2: Flashcard Mode - Card Component
//

import SwiftUI

/// A flashcard that can be flipped to reveal the answer
struct FlashcardCard: View {
    let word: Word
    @Binding var isFaceUp: Bool

    @State private var rotation: Double = 0

    var body: some View {
        ZStack {
            if !isFaceUp {
                // Front side: Image
                frontSide
                    .rotation3DEffect(
                        .degrees(rotation),
                        axis: (x: 0.0, y: 1.0, z: 0.0)
                    )
            } else {
                // Back side: French word and translation
                backSide
                    .rotation3DEffect(
                        .degrees(rotation + 180),
                        axis: (x: 0.0, y: 1.0, z: 0.0)
                    )
            }
        }
        .frame(maxWidth: .infinity)
        .aspectRatio(0.75, contentMode: .fit)
        .onTapGesture {
            flipCard()
        }
        .onChange(of: isFaceUp) { _, newValue in
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                rotation = newValue ? 180 : 0
            }
        }
    }

    // MARK: - Front Side (Image)

    private var frontSide: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(
                LinearGradient(
                    colors: [Color.blue.opacity(0.6), Color.blue.opacity(0.8)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay {
                VStack(spacing: 16) {
                    Spacer()

                    // Image
                    if let image = UIImage(named: word.imageName) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity)
                            .padding(40)
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(16)
                            .shadow(radius: 4)
                    } else {
                        Image(systemName: "photo")
                            .font(.system(size: 80))
                            .foregroundColor(.white.opacity(0.5))
                    }

                    Spacer()

                    // Hint text
                    Text("flashcard.tap.to.flip".localized)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.9))
                        .padding(.bottom, 24)
                }
                .padding(20)
            }
            .shadow(radius: 10)
    }

    // MARK: - Back Side (Word Info)

    private var backSide: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(
                LinearGradient(
                    colors: [Color.green.opacity(0.6), Color.green.opacity(0.8)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay {
                VStack(spacing: 20) {
                    Spacer()

                    // French word
                    Text(word.canonical)
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)

                    // Gender if applicable
                    if let gender = word.gender {
                        Text("(\(gender.abbreviation))")
                            .font(.title3)
                            .foregroundColor(.white.opacity(0.9))
                    }

                    Divider()
                        .background(Color.white.opacity(0.5))
                        .padding(.horizontal, 40)

                    // Audio button
                    Button(action: {
                        playAudio()
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "speaker.wave.2.fill")
                            Text("flashcard.play.audio".localized)
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(25)
                    }

                    Divider()
                        .background(Color.white.opacity(0.5))
                        .padding(.horizontal, 40)

                    // Translation
                    Text(word.translation)
                        .font(.title2)
                        .foregroundColor(.white.opacity(0.95))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    Spacer()

                    // Hint text
                    Text("flashcard.tap.to.flip".localized)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.bottom, 24)
                }
                .padding(20)
                .rotation3DEffect(
                    .degrees(180),
                    axis: (x: 0.0, y: 1.0, z: 0.0)
                )
            }
            .shadow(radius: 10)
    }

    // MARK: - Actions

    private func flipCard() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            isFaceUp.toggle()
        }
    }

    private func playAudio() {
        // Find first audio segment for this word
        if let audioSegment = word.audioSegments.first {
            AudioPlayerManager.shared.playAudio(segment: audioSegment)
            print("🔊 Playing audio for: \(word.canonical)")
        } else {
            print("⚠️ No audio available for: \(word.canonical)")
        }
    }
}

// MARK: - Preview

#Preview {
    VStack {
        FlashcardCard(
            word: Word(
                id: "test",
                canonical: "la pomme",
                translation: "苹果",
                imageName: "apple",
                orderIndex: 1,
                gender: .feminine
            ),
            isFaceUp: .constant(false)
        )
        .padding()
    }
}
