import SwiftUI
import SwiftData

struct ProgressView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var userProgresses: [UserProgress]
    @Query private var practiceRecords: [PracticeRecord]
    
    private var currentProgress: UserProgress? {
        userProgresses.first
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if let progress = currentProgress {
                    progressOverview(progress)
                    recentActivity
                    Spacer()
                } else {
                    Text("progress.no.data".localized)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .navigationTitle("progress.title".localized)
        }
    }
    
    private func progressOverview(_ progress: UserProgress) -> some View {
        VStack(spacing: 15) {
            // Stars, gems, and streak
            HStack(spacing: 30) {
                VStack {
                    Image(systemName: "star.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.yellow)
                    Text("\(progress.totalStars)")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("progress.total.stars".localized)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                VStack {
                    Image(systemName: "gem.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.cyan)
                    Text("\(progress.totalGems)")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("progress.total.gems".localized)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                VStack {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.orange)
                    Text("\(progress.currentStreak)")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("progress.current.streak".localized)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(.regularMaterial)
            .cornerRadius(15)
            
            // Last study date
            if let lastStudy = progress.lastStudyDate {
                let dateString = lastStudy.formatted(.dateTime.day().month().year())
                Text("progress.last.study".localized(dateString))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var recentActivity: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("progress.recent.activity".localized)
                .font(.headline)
                .padding(.horizontal)

            if practiceRecords.isEmpty {
                Text("progress.no.records".localized)
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(practiceRecords.sorted(by: { $0.sessionDate > $1.sessionDate }).prefix(5)) { record in
                        practiceRecordRow(record)
                    }
                }
            }
        }
        .background(.regularMaterial)
        .cornerRadius(15)
    }
    
    private func practiceRecordRow(_ record: PracticeRecord) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(record.sessionType)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(record.sessionDate, format: .dateTime.day().month().hour().minute())
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("progress.words.count".localized(record.wordsStudied))
                    .font(.caption)

                Text("progress.accuracy.label".localized(Int(record.accuracy * 100)))
                    .font(.caption)
                    .foregroundColor(record.accuracy >= 0.8 ? .green : (record.accuracy >= 0.6 ? .orange : .red))
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

#Preview {
    ProgressView()
        .modelContainer(for: [UserProgress.self, PracticeRecord.self], inMemory: true)
}