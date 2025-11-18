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

            // Page content with native swipe gesture
            TabView(selection: $currentPageIndex) {
                ForEach(Array(sortedPages.enumerated()), id: \.element.pageNumber) { index, page in
                    StorybookPageView(page: page, onPlayAudio: {
                        playAudio(for: page)
                    })
                    .tag(index)
                    .rotation3DEffect(
                        .degrees(getRotationAngle(for: index)),
                        axis: (x: 0, y: 1, z: 0),
                        perspective: 0.5
                    )
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.spring(response: 0.5, dampingFraction: 0.8), value: currentPageIndex)
            .onChange(of: currentPageIndex) { _, newValue in
                stopAudio()
                // Auto-play audio for new page with slight delay for animation
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    if newValue < sortedPages.count {
                        playAudio(for: sortedPages[newValue])
                    }
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
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                currentPageIndex -= 1
            }
        }
    }

    private func nextPage() {
        if currentPageIndex < sortedPages.count - 1 {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                currentPageIndex += 1
            }
        } else {
            // Last page - dismiss the view
            dismiss()
        }
    }

    // MARK: - Animation Helper

    private func getRotationAngle(for index: Int) -> Double {
        let offset = Double(index - currentPageIndex)
        // Subtle 3D rotation effect when swiping
        return offset * 5.0 // Rotate by 5 degrees per page offset
    }

    // MARK: - Audio Methods

    private func playAudio(for page: StoryPage) {
        guard let audioFileName = page.audioFileName else { return }

        let baseFileName = audioFileName.replacingOccurrences(of: ".mp3", with: "")

        // Try to find audio file - first try exact match
        if let audioURL = Bundle.main.url(forResource: baseFileName, withExtension: "mp3") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: audioURL)
                audioPlayer?.play()
                print("🔊 Playing audio: \(audioFileName)")
            } catch {
                print("❌ Failed to play audio: \(error)")
            }
        } else {
            // If not found, try to find any audio file in bundle that matches the pattern
            // This handles cases where filename format changed
            if let bundleURL = Bundle.main.resourceURL {
                let fileManager = FileManager.default
                do {
                    let resourceKeys = Set<URLResourceKey>([.nameKey, .isDirectoryKey])
                    let enumerator = fileManager.enumerator(at: bundleURL, includingPropertiesForKeys: Array(resourceKeys))

                    while let fileURL = enumerator?.nextObject() as? URL {
                        if fileURL.pathExtension == "mp3" && fileURL.lastPathComponent == audioFileName {
                            audioPlayer = try AVAudioPlayer(contentsOf: fileURL)
                            audioPlayer?.play()
                            print("🔊 Playing audio (found in bundle): \(audioFileName)")
                            return
                        }
                    }
                } catch {
                    print("❌ Error searching for audio: \(error)")
                }
            }
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
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                // Full-screen image
                if let imageName = page.imageName, !imageName.isEmpty {
                    Image(imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: geometry.size.width)
                        .clipped()
                } else {
                    Color.gray.opacity(0.2)
                    VStack {
                        Image(systemName: "photo")
                            .font(.system(size: 80))
                            .foregroundColor(.gray)
                        Text("No image available")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                // Text overlay at bottom with subtitle styling
                VStack(spacing: 12) {
                    // Audio button
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
                            .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                        }
                    }

                    // French text with subtitle styling
                    Text(page.contentFrench)
                        .font(.custom("EB Garamond", size: 24))
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .shadow(color: .black.opacity(0.9), radius: 2, x: 0, y: 1)
                        .shadow(color: .black.opacity(0.9), radius: 4, x: 0, y: 2)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 20)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.black.opacity(0.75))
                        )
                        .padding(.horizontal, 20)
                }
                .padding(.bottom, 20)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .ignoresSafeArea(edges: .top)
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
