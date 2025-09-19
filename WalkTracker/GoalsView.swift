import SwiftUI

struct GoalsView: View {
    @StateObject private var healthManager = HealthManager.shared
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    
                    GoalProgressRingView()
                    
                    Divider()
                        .padding(.vertical,10)
                    
                    GoalSettingView()
                }
            }
            .navigationTitle("Goals") //always have navigationTitle here
        }
        .onAppear {
            DispatchQueue.main.async {
                healthManager.requestPermission()
                healthManager.fetchAllHealthData()
            }
        }
    }
}
