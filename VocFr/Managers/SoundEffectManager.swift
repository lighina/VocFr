//
//  SoundEffectManager.swift
//  VocFr
//
//  Created by Claude on 16/11/2025.
//  Sound effects for practice feedback
//

import Foundation
import AVFoundation
import AudioToolbox
import UIKit

/// Manager for playing sound effects during practice sessions
class SoundEffectManager {

    // MARK: - Singleton

    static let shared = SoundEffectManager()

    // MARK: - Properties

    private var audioPlayers: [String: AVAudioPlayer] = [:]
    private let soundVolume: Float = 0.3 // Low volume for sound effects

    // MARK: - Initialization

    private init() {
        setupAudioSession()
    }

    // MARK: - Audio Session Setup

    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("⚠️ Failed to setup audio session for sound effects: \(error)")
        }
    }

    // MARK: - Sound Effects

    /// Play correct answer sound effect
    func playCorrectSound() {
        // Use system sound for correct answer (similar to keyboard click)
        // Sound ID 1054 is a gentle "pop" sound
        AudioServicesPlaySystemSound(1054)

        // Provide haptic feedback
        let feedbackGenerator = UINotificationFeedbackGenerator()
        feedbackGenerator.notificationOccurred(.success)
    }

    /// Play incorrect answer sound effect
    func playIncorrectSound() {
        // Use system sound for incorrect answer
        // Sound ID 1053 is a gentle "knock" sound
        AudioServicesPlaySystemSound(1053)

        // Provide haptic feedback
        let feedbackGenerator = UINotificationFeedbackGenerator()
        feedbackGenerator.notificationOccurred(.error)
    }

    /// Play neutral feedback sound (for "almost correct" scenarios)
    func playNeutralSound() {
        // Sound ID 1104 is a gentle "tink" sound
        AudioServicesPlaySystemSound(1104)

        // Provide light haptic feedback
        let feedbackGenerator = UINotificationFeedbackGenerator()
        feedbackGenerator.notificationOccurred(.warning)
    }

    // MARK: - Custom Sound Loading (for future use)

    /// Load and play a custom sound file
    private func playSound(named soundName: String, withExtension ext: String = "mp3") {
        // Check if player already exists
        if let player = audioPlayers[soundName] {
            player.currentTime = 0
            player.volume = soundVolume
            player.play()
            return
        }

        // Load sound file
        guard let url = Bundle.main.url(forResource: soundName, withExtension: ext) else {
            print("⚠️ Sound file not found: \(soundName).\(ext)")
            return
        }

        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.volume = soundVolume
            player.prepareToPlay()
            player.play()

            // Cache the player for reuse
            audioPlayers[soundName] = player
        } catch {
            print("⚠️ Error loading sound \(soundName): \(error)")
        }
    }

    // MARK: - Volume Control

    /// Update volume for all sound effects
    func setVolume(_ volume: Float) {
        let clampedVolume = max(0.0, min(1.0, volume))
        for (_, player) in audioPlayers {
            player.volume = clampedVolume
        }
    }
}
