//
//  StorybookReaderView.swift
//  VocFr
//
//  Created by Claude on 17/11/2025.
//  Storybook reader with page navigation
//

import SwiftUI
import AVFoundation

struct StorybookReaderView: View {
    let storybook: Storybook

    @Environment(\.dismiss) private var dismiss
    @State private var currentPageIndex = 0
    @State private var audioPlayer: AVAudioPlayer?

    private var sortedPages: [StoryPage] {
        storybook.pages.sorted { $0.pageNumber < $1.pageNumber }
    }

    private var currentPage: StoryPage? {
        guard currentPageIndex < sortedPages.count else { return nil }
        return sortedPages[currentPageIndex]
    }

    var body: some View {
        VStack(spacing: 0) {
            // Progress bar
            HStack(spacing: 4) {
                ForEach(0..<sortedPages.count, id: \.self) { index in
                    Capsule()
                        .fill(index <= currentPageIndex ? Color.purple : Color.gray.opacity(0.3))
                        .frame(height: 4)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)

            // Page content
            TabView(selection: $currentPageIndex) {
                ForEach(Array(sortedPages.enumerated()), id: \.element.pageNumber) { index, page in
                    StorybookPageView(page: page, onPlayAudio: {
                        playAudio(for: page)
                    })
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .onChange(of: currentPageIndex) { _, newValue in
                stopAudio()
                // Auto-play audio for new page
                if newValue < sortedPages.count {
                    playAudio(for: sortedPages[newValue])
                }
            }
            .onAppear {
                // Auto-play audio for first page
                if let firstPage = sortedPages.first {
                    playAudio(for: firstPage)
                }
            }

            // Navigation controls
            HStack {
                // Previous button
                Button(action: previousPage) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("storybook.previous".localized)
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(currentPageIndex > 0 ? Color.purple : Color.gray)
                    .cornerRadius(12)
                }
                .disabled(currentPageIndex == 0)

                Spacer()

                // Page indicator
                Text("\(currentPageIndex + 1) / \(sortedPages.count)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Spacer()

                // Next button
                Button(action: nextPage) {
                    HStack {
                        Text(currentPageIndex < sortedPages.count - 1 ? "storybook.next".localized : "storybook.finish".localized)
                        Image(systemName: currentPageIndex < sortedPages.count - 1 ? "chevron.right" : "checkmark")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.purple)
                    .cornerRadius(12)
                }
            }
            .padding()
        }
        .navigationTitle(storybook.title)
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            stopAudio()
        }
    }

    // MARK: - Navigation Methods

    private func previousPage() {
        if currentPageIndex > 0 {
            withAnimation {
                currentPageIndex -= 1
            }
        }
    }

    private func nextPage() {
        if currentPageIndex < sortedPages.count - 1 {
            withAnimation {
                currentPageIndex += 1
            }
        } else {
            // Last page - dismiss the view
            dismiss()
        }
    }

    // MARK: - Audio Methods

    private func playAudio(for page: StoryPage) {
        guard let audioFileName = page.audioFileName else { return }

        // Try to find audio file
        if let audioURL = Bundle.main.url(forResource: audioFileName.replacingOccurrences(of: ".mp3", with: ""), withExtension: "mp3") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: audioURL)
                audioPlayer?.play()
                print("🔊 Playing audio: \(audioFileName)")
            } catch {
                print("❌ Failed to play audio: \(error)")
            }
        } else {
            print("⚠️  Audio file not found: \(audioFileName)")
        }
    }

    private func stopAudio() {
        audioPlayer?.stop()
        audioPlayer = nil
    }
}

// MARK: - Storybook Page View

struct StorybookPageView: View {
    let page: StoryPage
    let onPlayAudio: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Page illustration
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.purple.opacity(0.1))
                        .frame(height: 250)

                    if let imageName = page.imageName, !imageName.isEmpty {
                        Image(imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 250)
                            .cornerRadius(12)
                    } else {
                        VStack {
                            Image(systemName: "photo")
                                .font(.system(size: 60))
                                .foregroundColor(.purple.opacity(0.5))
                            Text("No image available")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.horizontal)

                // Text content with subtitle styling
                VStack(spacing: 16) {
                    // Audio button at top
                    HStack {
                        Spacer()
                        if page.audioFileName != nil {
                            Button(action: onPlayAudio) {
                                HStack(spacing: 8) {
                                    Image(systemName: "speaker.wave.2.fill")
                                    Text("Play")
                                }
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(Color.purple)
                                .cornerRadius(20)
                            }
                        }
                        Spacer()
                    }

                    // French text with subtitle styling
                    Text(page.contentFrench)
                        .font(.custom("EB Garamond", size: 22))
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .shadow(color: .black.opacity(0.8), radius: 2, x: 0, y: 1)
                        .shadow(color: .black.opacity(0.8), radius: 4, x: 0, y: 2)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.black.opacity(0.7))
                        )
                        .padding(.horizontal, 24)
                }
                .padding(.horizontal, 8)
            }
            .padding(.vertical)
        }
    }
}

// MARK: - Preview

#Preview {
    let sampleStorybook = Storybook(
        id: "sample",
        title: "À l'école",
        titleInChinese: "在学校",
        uniteId: "unite1",
        isUnlocked: true,
        requiredGems: 0,
        orderIndex: 1,
        coverImageName: nil
    )

    let page1 = StoryPage(
        pageNumber: 1,
        contentFrench: "C'est mon premier jour à l'école.",
        contentChinese: "这是我在学校的第一天。",
        imageName: "school_day1",
        audioFileName: "audio1.mp3"
    )

    let page2 = StoryPage(
        pageNumber: 2,
        contentFrench: "Je vois un bureau, une chaise et un tableau.",
        contentChinese: "我看到一张课桌、一把椅子和一块黑板。",
        imageName: "school_classroom",
        audioFileName: "audio2.mp3"
    )

    sampleStorybook.pages = [page1, page2]

    return NavigationStack {
        StorybookReaderView(storybook: sampleStorybook)
    }
}
