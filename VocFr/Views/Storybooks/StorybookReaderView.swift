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
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var currentPageIndex = 0
    @State private var audioPlayer: AVAudioPlayer?
    @State private var orientation = UIDevice.current.orientation

    private var sortedPages: [StoryPage] {
        storybook.pages.sorted { $0.pageNumber < $1.pageNumber }
    }

    private var currentPage: StoryPage? {
        guard currentPageIndex < sortedPages.count else { return nil }
        return sortedPages[currentPageIndex]
    }

    // Check if we should show two pages side by side (iPad landscape)
    private var isDoublePageMode: Bool {
        UIDevice.current.userInterfaceIdiom == .pad &&
        (orientation.isLandscape || horizontalSizeClass == .regular)
    }

    // Get the step size for page navigation (1 for single page, 2 for double page)
    private var pageStep: Int {
        isDoublePageMode ? 2 : 1
    }

    var body: some View {
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

            // Page content with native swipe gesture
            TabView(selection: $currentPageIndex) {
                if isDoublePageMode {
                    // Double page mode for iPad landscape
                    ForEach(stride(from: 0, to: sortedPages.count, by: 2).map { $0 }, id: \.self) { index in
                        HStack(spacing: 0) {
                            // Left page
                            if index < sortedPages.count {
                                StorybookPageView(
                                    page: sortedPages[index],
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
                        .rotation3DEffect(
                            .degrees(getRotationAngle(for: index)),
                            axis: (x: 0, y: 1, z: 0),
                            perspective: 0.5
                        )
                    }
                } else {
                    // Single page mode for iPhone or iPad portrait
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
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.spring(response: 0.5, dampingFraction: 0.8), value: currentPageIndex)
            .onChange(of: currentPageIndex) { _, newValue in
                stopAudio()
                // Auto-play audio for new page with slight delay for animation
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    if newValue < sortedPages.count {
                        playAudio(for: sortedPages[newValue])
                        // In double page mode, also play audio for the right page
                        if isDoublePageMode && newValue + 1 < sortedPages.count {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                playAudio(for: sortedPages[newValue + 1])
                            }
                        }
                    }
                }
            }
            .onAppear {
                // Auto-play audio for first page
                if let firstPage = sortedPages.first {
                    playAudio(for: firstPage)
                }
                // Monitor orientation changes
                NotificationCenter.default.addObserver(
                    forName: UIDevice.orientationDidChangeNotification,
                    object: nil,
                    queue: .main
                ) { _ in
                    orientation = UIDevice.current.orientation
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

                // Text overlay at bottom with subtitle styling - Japanese minimalist
                VStack(spacing: 12) {
                    // French text with subtitle styling
                    Text(page.contentFrench)
                        .font(.custom("EB Garamond", size: 20))
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .shadow(color: .black.opacity(0.9), radius: 2, x: 0, y: 1)
                        .shadow(color: .black.opacity(0.9), radius: 4, x: 0, y: 2)
                        .padding(.horizontal, 28)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.black.opacity(0.85))
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
