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
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @State private var currentPageIndex = 0
    @State private var audioPlayer: AVAudioPlayer?
    @State private var secondAudioPlayer: AVAudioPlayer?
    @State private var screenSize: CGSize = .zero

    private var sortedPages: [StoryPage] {
        storybook.pages.sorted { $0.pageNumber < $1.pageNumber }
    }

    private var currentPage: StoryPage? {
        guard currentPageIndex < sortedPages.count else { return nil }
        return sortedPages[currentPageIndex]
    }

    // Check if we should show two pages side by side (iPad landscape only)
    private var isDoublePageMode: Bool {
        // Use screen dimensions to reliably detect landscape
        // iPad in landscape: width > height
        UIDevice.current.userInterfaceIdiom == .pad && screenSize.width > screenSize.height
    }

    // Get the step size for page navigation (1 for single page, 2 for double page)
    private var pageStep: Int {
        isDoublePageMode ? 2 : 1
    }

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
            // Progress bar - Japanese minimalist style
            HStack(spacing: 4) {
                if isDoublePageMode {
                    // Show progress for page pairs in double page mode
                    ForEach(stride(from: 0, to: sortedPages.count, by: 2).map { $0 }, id: \.self) { index in
                        Capsule()
                            .fill(index <= currentPageIndex ? Color(red: 0.83, green: 0.77, blue: 0.73) : Color.gray.opacity(0.2))
                            .frame(height: 3)
                    }
                } else {
                    // Show progress for individual pages
                    ForEach(0..<sortedPages.count, id: \.self) { index in
                        Capsule()
                            .fill(index <= currentPageIndex ? Color(red: 0.83, green: 0.77, blue: 0.73) : Color.gray.opacity(0.2))
                            .frame(height: 3)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)

            // Page content with native swipe gesture and page-turn animation
            TabView(selection: $currentPageIndex) {
                if isDoublePageMode {
                    // Double page mode for iPad landscape
                    ForEach(stride(from: 0, to: sortedPages.count, by: 2).map { $0 }, id: \.self) { index in
                        HStack(spacing: 0) {
                            // Left page
                            if index < sortedPages.count {
                                StorybookPageView(
                                    page: sortedPages[index],
                                    isInDoublePageMode: true,
                                    onPlayAudio: { playAudio(for: sortedPages[index]) }
                                )
                                .frame(maxWidth: .infinity)
                            }

                            // Book spine separator
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.black.opacity(0.3),
                                            Color.black.opacity(0.1),
                                            Color.black.opacity(0.3)
                                        ]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: 4)

                            // Right page
                            if index + 1 < sortedPages.count {
                                StorybookPageView(
                                    page: sortedPages[index + 1],
                                    isInDoublePageMode: true,
                                    onPlayAudio: { playAudio(for: sortedPages[index + 1]) }
                                )
                                .frame(maxWidth: .infinity)
                            } else {
                                // Empty page if odd number of pages
                                Color.clear
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .tag(index)
                        .scaleEffect(currentPageIndex == index ? 1.0 : 0.95)
                        .opacity(currentPageIndex == index ? 1.0 : 0.5)
                        .rotation3DEffect(
                            .degrees(Double(index - currentPageIndex) * 10),
                            axis: (x: 0, y: 1, z: 0),
                            anchor: index > currentPageIndex ? .leading : .trailing,
                            perspective: 0.4
                        )
                    }
                } else {
                    // Single page mode for iPhone or iPad portrait
                    ForEach(Array(sortedPages.enumerated()), id: \.element.pageNumber) { index, page in
                        StorybookPageView(
                            page: page,
                            isInDoublePageMode: false,
                            onPlayAudio: {
                                playAudio(for: page)
                            }
                        )
                        .tag(index)
                        .scaleEffect(currentPageIndex == index ? 1.0 : 0.95)
                        .opacity(currentPageIndex == index ? 1.0 : 0.5)
                        .rotation3DEffect(
                            .degrees(Double(index - currentPageIndex) * 15),
                            axis: (x: 0, y: 1, z: 0),
                            anchor: index > currentPageIndex ? .leading : .trailing,
                            perspective: 0.3
                        )
                    }
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.interpolatingSpring(stiffness: 200, damping: 20), value: currentPageIndex)
            .onChange(of: currentPageIndex) { _, newValue in
                stopAudio()
                // Auto-play audio for new page with slight delay for animation
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    if newValue < sortedPages.count {
                        // In double page mode, play both pages' audio sequentially
                        if isDoublePageMode && newValue + 1 < sortedPages.count {
                            playDoublePageAudio(
                                firstPage: sortedPages[newValue],
                                secondPage: sortedPages[newValue + 1]
                            )
                        } else {
                            playAudio(for: sortedPages[newValue])
                        }
                    }
                }
            }
            .onAppear {
                // Auto-play audio for first page(s)
                if isDoublePageMode && sortedPages.count >= 2 {
                    playDoublePageAudio(firstPage: sortedPages[0], secondPage: sortedPages[1])
                } else if let firstPage = sortedPages.first {
                    playAudio(for: firstPage)
                }
            }

            // Navigation controls - Japanese minimalist style
            HStack {
                // Previous button
                Button(action: previousPage) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("storybook.previous".localized)
                    }
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(currentPageIndex > 0 ? Color(red: 0.44, green: 0.44, blue: 0.44) : Color.gray.opacity(0.3))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(red: 0.96, green: 0.96, blue: 0.94).opacity(0.6))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
                }
                .disabled(currentPageIndex == 0)

                Spacer()

                // Page indicator
                if isDoublePageMode {
                    let endPage = min(currentPageIndex + 2, sortedPages.count)
                    Text("\(currentPageIndex + 1)-\(endPage) / \(sortedPages.count)")
                        .font(.caption)
                        .foregroundColor(Color(red: 0.44, green: 0.44, blue: 0.44))
                } else {
                    Text("\(currentPageIndex + 1) / \(sortedPages.count)")
                        .font(.caption)
                        .foregroundColor(Color(red: 0.44, green: 0.44, blue: 0.44))
                }

                Spacer()

                // Next button
                Button(action: nextPage) {
                    let isLastPage = currentPageIndex + pageStep >= sortedPages.count
                    HStack {
                        Text(isLastPage ? "storybook.finish".localized : "storybook.next".localized)
                        Image(systemName: isLastPage ? "checkmark" : "chevron.right")
                    }
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(Color(red: 0.44, green: 0.44, blue: 0.44))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(red: 0.96, green: 0.96, blue: 0.94).opacity(0.6))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
                }
            }
            .padding()
            }
            .onAppear {
                // Update screen size to detect orientation
                screenSize = geometry.size
            }
            .onChange(of: geometry.size) { _, newSize in
                // Update screen size when device rotates
                screenSize = newSize
            }
            .navigationTitle(storybook.title)
            .navigationBarTitleDisplayMode(.inline)
            .onDisappear {
                stopAudio()
            }
        }
    }

    // MARK: - Navigation Methods

    private func previousPage() {
        if currentPageIndex > 0 {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                currentPageIndex = max(0, currentPageIndex - pageStep)
            }
        }
    }

    private func nextPage() {
        let nextIndex = currentPageIndex + pageStep
        if nextIndex < sortedPages.count {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                currentPageIndex = nextIndex
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
        secondAudioPlayer?.stop()
        secondAudioPlayer = nil
    }

    /// Play audio for two pages sequentially with a pause in between
    private func playDoublePageAudio(firstPage: StoryPage, secondPage: StoryPage) {
        guard let firstAudioFileName = firstPage.audioFileName else {
            // If first page has no audio, just play second page
            playAudio(for: secondPage)
            return
        }

        // Play first page audio
        let firstBaseFileName = firstAudioFileName.replacingOccurrences(of: ".mp3", with: "")
        if let firstAudioURL = Bundle.main.url(forResource: firstBaseFileName, withExtension: "mp3") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: firstAudioURL)
                audioPlayer?.play()
                print("🔊 Playing first page audio: \(firstAudioFileName)")

                // Get duration of first audio and schedule second audio
                if let duration = audioPlayer?.duration {
                    let pauseInterval: TimeInterval = 0.8 // 0.8 second pause between pages
                    let delayTime = duration + pauseInterval

                    DispatchQueue.main.asyncAfter(deadline: .now() + delayTime) {
                        // Play second page audio
                        self.playSecondPageAudio(for: secondPage)
                    }
                } else {
                    // If can't get duration, use default delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                        self.playSecondPageAudio(for: secondPage)
                    }
                }
            } catch {
                print("❌ Failed to play first page audio: \(error)")
                // Try to play second page anyway
                playSecondPageAudio(for: secondPage)
            }
        } else {
            print("⚠️ First page audio file not found: \(firstAudioFileName)")
            // Try to play second page anyway
            playSecondPageAudio(for: secondPage)
        }
    }

    /// Play audio for the second page (used in double page mode)
    private func playSecondPageAudio(for page: StoryPage) {
        guard let audioFileName = page.audioFileName else { return }

        let baseFileName = audioFileName.replacingOccurrences(of: ".mp3", with: "")

        if let audioURL = Bundle.main.url(forResource: baseFileName, withExtension: "mp3") {
            do {
                secondAudioPlayer = try AVAudioPlayer(contentsOf: audioURL)
                secondAudioPlayer?.play()
                print("🔊 Playing second page audio: \(audioFileName)")
            } catch {
                print("❌ Failed to play second page audio: \(error)")
            }
        } else {
            print("⚠️ Second page audio file not found: \(audioFileName)")
        }
    }
}

// MARK: - Storybook Page View

struct StorybookPageView: View {
    let page: StoryPage
    let isInDoublePageMode: Bool
    let onPlayAudio: () -> Void

    var body: some View {
        GeometryReader { geometry in
            // Use double page mode flag to determine font size
            // Double page mode (iPad landscape): 20pt
            // Single page mode (iPhone or iPad portrait): 36pt
            let fontSize: CGFloat = isInDoublePageMode ? 20 : 36

            ZStack(alignment: .bottom) {
                // Full-screen image
                if let imageName = page.imageName, !imageName.isEmpty {
                    Image(imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geometry.size.width, height: geometry.size.height)
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

                // Text overlay at bottom - text box centered with margin, text aligned left
                HStack {
                    Text(page.contentFrench)
                        .font(.custom("Georgia", size: fontSize))
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .shadow(color: .black.opacity(0.9), radius: 2, x: 0, y: 1)
                        .shadow(color: .black.opacity(0.9), radius: 4, x: 0, y: 2)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.black.opacity(0.25))
                        )
                }
                .padding(.horizontal, 36)
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
