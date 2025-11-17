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
                // Image placeholder
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.purple.opacity(0.1))
                        .frame(height: 250)

                    VStack {
                        Image(systemName: "photo")
                            .font(.system(size: 60))
                            .foregroundColor(.purple.opacity(0.5))

                        if let imageName = page.imageName {
                            Text(imageName)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.horizontal)

                // Text content
                VStack(spacing: 16) {
                    // French text
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("🇫🇷")
                                .font(.title3)
                            Text("storybook.french".localized)
                                .font(.headline)
                                .foregroundColor(.secondary)

                            Spacer()

                            // Audio button
                            if page.audioFileName != nil {
                                Button(action: onPlayAudio) {
                                    Image(systemName: "speaker.wave.2.fill")
                                        .font(.title3)
                                        .foregroundColor(.purple)
                                }
                            }
                        }

                        Text(page.contentFrench)
                            .font(.title3)
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                    }

                    // Chinese text
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("🇨🇳")
                                .font(.title3)
                            Text("storybook.chinese".localized)
                                .font(.headline)
                                .foregroundColor(.secondary)
                        }

                        Text(page.contentChinese)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal)
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
