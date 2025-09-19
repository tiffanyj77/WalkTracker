import SwiftUI

struct WeeklyChart: View {
    @StateObject private var healthManager = HealthManager.shared
    @StateObject private var coreDataManager = CoreDataManager()
    
    var body: some View {
        VStack(spacing: 20) {
            
            Text("\(healthManager.stepCount) steps")
                .font(.title2)
            
            Text("\(String(format: "%.1f", healthManager.caloriesBurned)) cal")
                .font(.title2)
            
            Text("\(String(format: "%.0f", healthManager.elevationGained)) ft")
                .font(.title2)
        }
        VStack {
            Text("Weekly Steps")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.bottom)
            
            HStack(alignment: .bottom, spacing: 15) {
                ForEach(0..<7, id: \.self) { index in
                    ChartBar(
                        dayLabel: healthManager.weekDayLabels[index],
                        stepCount: healthManager.weeklySteps[index],
                        maxSteps: healthManager.weeklySteps.max() ?? 1
                    )
                }
            }
            .padding()
            .frame(height: 150)
            
            Button("Refresh Chart") {
                healthManager.fetchWeeklySteps()
            }
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .background(Color.green)
            .cornerRadius(10)
        }
        .padding()
        .onAppear {
            healthManager.requestPermission()
            healthManager.fetchWeeklySteps()
        }
        
        Button("Refresh Data") {
            healthManager.fetchAllHealthData()
        }
        .font(.headline)
        .foregroundColor(.white)
        .padding()
        .background(Color.blue)
        .cornerRadius(10)
    }
    
struct ChartBar: View {
        let dayLabel: String
        let stepCount: Int
        let maxSteps: Int
        
        private var barHeight: CGFloat {
            guard maxSteps > 0 else { return 2 }
            let ratio = Double(stepCount) / Double(maxSteps)
            return CGFloat(ratio * 100) // Max height of 100 points
        }
        
        var body: some View {
            VStack {
                Text("\(stepCount)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Rectangle()
                    .fill(Color.blue)
                    .frame(width: 30, height: max(barHeight, 2))
                    .cornerRadius(4)
                
                Text(dayLabel)
                    .font(.caption)
                    .foregroundColor(.primary)
            }
        }
    }
}
