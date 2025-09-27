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
                    Text("暂无学习进度")
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .navigationTitle("学习进度")
        }
    }
    
    private func progressOverview(_ progress: UserProgress) -> some View {
        VStack(spacing: 15) {
            // Stars and streak
            HStack(spacing: 30) {
                VStack {
                    Image(systemName: "star.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.yellow)
                    Text("\(progress.totalStars)")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("总星数")
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
                    Text("连续天数")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(.regularMaterial)
            .cornerRadius(15)
            
            // Last study date
            if let lastStudy = progress.lastStudyDate {
                Text("上次学习: \(lastStudy, format: .dateTime.day().month().year())")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var recentActivity: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("最近活动")
                .font(.headline)
                .padding(.horizontal)
            
            if practiceRecords.isEmpty {
                Text("暂无练习记录")
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
                Text("\(record.wordsStudied) 个单词")
                    .font(.caption)
                
                Text("\(Int(record.accuracy * 100))% 正确率")
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