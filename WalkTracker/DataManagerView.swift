import SwiftUI

struct DataManagerView: View {
    @StateObject private var healthManager = HealthManager.shared
    @StateObject private var coreDataManager = CoreDataManager()
    @State private var savedDaysCount = 0

    var body: some View {
        VStack(spacing: 20) {
            Text("WalkTracker")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("\(healthManager.stepCount) steps")
                .font(.title2)
            
            Text("\(String(format: "%.1f", healthManager.caloriesBurned)) cal")
                .font(.title2)
            
            Text("\(String(format: "%.0f", healthManager.elevationGained)) ft")
                .font(.title2)
            
            Text("\(String(format: "%.2f", healthManager.distanceWalked)) miles")
                .font(.title2)
            
            Text("\(savedDaysCount) days saved")
                .font(.caption)
                .foregroundColor(.gray)
            
            HStack(spacing: 15) {
                Button("Refresh Data") {
                    healthManager.fetchAllHealthData()
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .background(Color.blue)
                .cornerRadius(10)
                
                Button("Save Today's Data") {
                    saveTodaysData()
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .background(Color.green)
                .cornerRadius(10)
            }
        }
        .onAppear {
            updateSavedDaysCount()
        }
    }
    
    private func saveTodaysData() {
        // Use your existing CoreDataManager method
        coreDataManager.saveDailyWalkData(
            steps: healthManager.stepCount,
            calories: healthManager.caloriesBurned,
            elevation: healthManager.elevationGained,
            distance: healthManager.distanceWalked
        )
        
        // Update the count
        updateSavedDaysCount()
        
        print("✅ Saved today's walk data to Core Data")
    }
    
    private func updateSavedDaysCount() {
        let walkHistory = coreDataManager.fetchRecentWalkHistory(days: 365) // Get all saved days
        savedDaysCount = walkHistory.count
    }
}
