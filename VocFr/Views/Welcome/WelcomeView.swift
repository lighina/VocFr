//
//  WelcomeView.swift
//  VocFr
//
//  Created by Junfeng Wang on 22/09/2025.
//

import SwiftUI

struct WelcomeView: View {
    @Binding var showMainApp: Bool
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // App Icon/Logo
            VStack(spacing: 20) {
                Image(systemName: "book.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)

                Text("welcome.title".localized)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)

                Text("welcome.subtitle".localized)
                    .font(.title2)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            
            // Features
            VStack(alignment: .leading, spacing: 20) {
                WelcomeFeatureRow(icon: "book.closed", title: "welcome.feature.courses.title".localized, description: "welcome.feature.courses.description".localized)
                WelcomeFeatureRow(icon: "waveform", title: "welcome.feature.audio.title".localized, description: "welcome.feature.audio.description".localized)
                WelcomeFeatureRow(icon: "chart.line.uptrend.xyaxis", title: "welcome.feature.progress.title".localized, description: "welcome.feature.progress.description".localized)
            }
            .padding(.horizontal)
            
            Spacer()
            
            // Start Learning Button
            Button(action: {
                withAnimation(.easeInOut(duration: 0.6)) {
                    showMainApp = true
                }
            }) {
                HStack {
                    Image(systemName: "play.circle.fill")
                        .font(.title2)
                    Text("welcome.button.start".localized)
                        .font(.title2)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        colors: [.blue, .blue.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(15)
                .shadow(color: .blue.opacity(0.3), radius: 10, y: 5)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 50)
        }
        .background(
            LinearGradient(
                colors: [Color.primary.opacity(0.05), Color.secondary.opacity(0.1)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
}

struct WelcomeFeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 30, height: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

#Preview {
    WelcomeView(showMainApp: .constant(false))
}