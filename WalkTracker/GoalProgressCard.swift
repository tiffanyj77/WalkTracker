import SwiftUI

struct GoalProgressCard: View {
    let stepCount: Int
    let stepGoal: Int
    let progress: Double
    
    var body: some View {
            VStack(spacing: 16) {
                Text("Daily Goal")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                ZStack {
                    ProgressRing(
                        progress: progress,
                        lineWidth: 12,
                        ringColor: .blue
                    )
                    .frame(width: 120, height: 120)
                    
                    VStack(spacing: 4) {
                        Text("\(stepCount)")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("steps")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                HStack {
                    Text("Goal: \(stepGoal)")
                    Spacer()
                    Text("\(Int(progress * 100))%")
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
            }
    
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

