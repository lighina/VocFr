//
//  MatchingGameView.swift
//  VocFr
//
//  Created by Claude on 15/11/2025.
//  Phase C.1.2: Matching Game Mode
//

import SwiftUI
import SwiftData

struct MatchingGameView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: MatchingGameViewModel

    init(section: Section) {
        self._viewModel = State(initialValue: MatchingGameViewModel(section: section, modelContext: nil))
    }

    var body: some View {
        GeometryReader { geometry in
            let isLandscape = geometry.size.width > geometry.size.height
            let columns = isLandscape ? [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ] : [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ]

            // Calculate card size based on available height
            // Landscape: 3 rows, Portrait: 4 rows
            let numberOfRows: CGFloat = isLandscape ? 3 : 4
            let headerHeight: CGFloat = 120
            let spacing: CGFloat = 12
            let totalSpacing = spacing * (numberOfRows - 1)
            let availableHeight = geometry.size.height - headerHeight - totalSpacing - 40 // 40 for padding
            let cardHeight = availableHeight / numberOfRows

            VStack(spacing: 16) {
                if viewModel.isCompleted {
                    completedView
                } else {
                    gameView(columns: columns, geometry: geometry, cardHeight: cardHeight)
                }
            }
            .padding()
            .navigationTitle("matching.game.title".localized(viewModel.sectionName))
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .semibold))
                            Text(viewModel.sectionName.capitalized)
                                .font(.system(size: 16))
                        }
                    }
                }
            }
            .onAppear {
                // Set modelContext after view appears
                viewModel = MatchingGameViewModel(section: viewModel.section, modelContext: modelContext)
            }
        }
    }

    // MARK: - Game View

    private func gameView(columns: [GridItem], geometry: GeometryProxy, cardHeight: CGFloat) -> some View {
        VStack(spacing: 20) {
            // Header with stats
            gameHeader

            // Instructions
            if viewModel.matchedPairs == 0 && viewModel.attempts == 0 {
                Text("matching.game.instruction".localized)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            // Cards grid - dynamic layout based on orientation, sized by height
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(viewModel.cards) { card in
                    MatchingCardView(card: card) {
                        withAnimation {
                            viewModel.selectCard(card)
                        }
                    }
                    .frame(height: cardHeight)
                    .aspectRatio(1.0, contentMode: .fit)
                }
            }
            .padding(.horizontal)
            .id(viewModel.refreshTrigger)  // Force refresh when cards change

            Spacer()
        }
    }

    // MARK: - Game Header

    private var gameHeader: some View {
        VStack(spacing: 12) {
            // Time and Score
            HStack {
                // Timer
                HStack(spacing: 6) {
                    Image(systemName: "clock")
                        .foregroundColor(.blue)
                    Text(viewModel.formattedTime)
                        .font(.system(size: 18, weight: .semibold, design: .monospaced))
                        .foregroundColor(.primary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color(.systemGray6))
                .cornerRadius(20)

                Spacer()

                // Score
                HStack(spacing: 6) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text("\(viewModel.score)")
                        .font(.system(size: 18, weight: .semibold, design: .monospaced))
                        .foregroundColor(.primary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color(.systemGray6))
                .cornerRadius(20)
            }

            // Progress
            HStack {
                Text("matching.game.progress".localized)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text(viewModel.progressText)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.green)
            }
            .padding(.horizontal)
        }
    }

    // MARK: - Completed View

    private var completedView: some View {
        VStack(spacing: 24) {
            // Success icon with animation
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)
                .scaleEffect(1.0)
                .onAppear {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
                        // Animation handled by SwiftUI
                    }
                }

            Text("matching.game.completed.title".localized)
                .font(.largeTitle)
                .fontWeight(.bold)

            // Stats
            VStack(spacing: 16) {
                // Time
                HStack(spacing: 8) {
                    Image(systemName: "clock")
                        .foregroundColor(.blue)
                    Text("matching.game.time".localized)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(viewModel.formattedTime)
                        .fontWeight(.semibold)
                }
                .padding(.horizontal)

                // Attempts
                HStack(spacing: 8) {
                    Image(systemName: "hand.tap")
                        .foregroundColor(.orange)
                    Text("matching.game.attempts".localized)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(viewModel.attempts)")
                        .fontWeight(.semibold)
                }
                .padding(.horizontal)

                Divider()

                // Total Score
                HStack(spacing: 12) {
                    Image(systemName: "star.fill")
                        .font(.title)
                        .foregroundColor(.yellow)

                    Text("matching.game.total.score".localized(viewModel.score))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.yellow.opacity(0.2))
                )
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemGray6))
            )

            // Retry button
            Button("practice.button.retry".localized) {
                withAnimation {
                    viewModel.restartGame()
                }
            }
            .buttonStyle(.borderedProminent)
            .padding(.top)

            Spacer()
        }
        .padding()
    }
}

#Preview {
    NavigationView {
        MatchingGameView(section: Section(id: "test", name: "Test Section", orderIndex: 1))
    }
    .modelContainer(for: [Section.self, Word.self], inMemory: true)
}
