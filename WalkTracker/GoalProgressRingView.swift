import SwiftUI

struct GoalProgressRingView: View {
    
    
    var body: some View {
        VStack(spacing: 24) {
            
            GoalProgressCard(
                stepCount:HealthManager.shared.todaySteps,
                stepGoal: HealthManager.shared.dailyStepGoal,
                progress: HealthManager.shared.goalProgress
            )
            
            HStack(spacing: 40) {
                VStack {
                    Text("\(String(format: "%.1f", HealthManager.shared.caloriesBurned))")
                        .font(.title2)
                        .fontWeight(.semibold)
                    Text("calories")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack {
                    Text("\(String(format: "%.0f", HealthManager.shared.elevationGained))")
                        .font(.title2)
                        .fontWeight(.semibold)
                    Text("feet")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Button("Refresh Data") {
                HealthManager.shared.fetchAllHealthData()
            }
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .background(Color.blue)
            .cornerRadius(10)
        }
    }
}

