import SwiftUI

struct CoreDataManagerView: View {
    @StateObject private var healthManager = HealthManager()
    @StateObject private var coreDataManager = CoreDataManager()
    @State private var showingSaveConfirmation = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("WalkTracker")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("\(healthManager.todaySteps) steps")
                .font(.title2)
            
            Text("\(String(format: "%.1f", healthManager.caloriesBurned)) cal")
                .font(.title2)
            
            Text("\(String(format: "%.0f", healthManager.elevationGained)) ft")
                .font(.title2)
            
            Text("\(String(format: "%.2f", healthManager.distanceWalked)) miles")
                .font(.title2)
            
            // Button actions in a horizontal stack
            HStack(spacing: 15) {
                Button("Refresh Data") {
                    healthManager.fetchAllHealthData()
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .background(Color.blue)
                .cornerRadius(10)
                
                Button("Save & Refresh") {
                    // First refresh the data
                    healthManager.fetchAllHealthData()
                    
                    // Then save to Core Data
                    coreDataManager.saveDailyWalkData(
                        steps: healthManager.todaySteps,
                        calories: healthManager.caloriesBurned,
                        elevation: healthManager.elevationGained,
                        distance: healthManager.distanceWalked
                    )
                    
                    // Show confirmation
                    showingSaveConfirmation = true
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .background(Color.green)
                .cornerRadius(10)
            }
            
            // Confirmation message
            if showingSaveConfirmation {
                Text("✅ Data saved to Core Data!")
                    .foregroundColor(.green)
                    .font(.caption)
            }
        }
        .alert("Data Saved", isPresented: $showingSaveConfirmation) {
            Button("OK") { }
        } message: {
            Text("Your walk data has been saved successfully!")
        }
    }
}
