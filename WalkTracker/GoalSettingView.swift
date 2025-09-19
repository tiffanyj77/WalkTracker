import SwiftUI
struct GoalSettingView: View {
    @State private var dailyStepGoal = 10000.0
    @StateObject private var healthManager = HealthManager.shared
    @Environment(\.dismiss) private var dismiss  // Add this for navigation
    
    var body: some View {
            VStack(spacing: 30) {
                Text("Set Your Daily Step Goal")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)
                
                Text("\(Int(dailyStepGoal)) steps")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.blue)

                VStack {
                    Slider(value: $dailyStepGoal, in: 1000...50000, step: 500)
                        .accentColor(.blue)
                        .padding(.horizontal)
                    HStack {
                        Text("1,000")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Spacer()
                        Text("50,000")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal)
                }
                
                VStack {
                    Text("Quick Goals")
                        .font(.headline)
                        .padding(.top)
                    
                    HStack(spacing: 15) {
                        Button("5K Steps") {
                            dailyStepGoal = 5000
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(10)
                        
                        Button("10K Steps") {
                            dailyStepGoal = 10000
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                        
                        Button("15K Steps") {
                            dailyStepGoal = 15000
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.orange)
                        .cornerRadius(10)
                    }
                }
                
                Button("Save Goal") {
                    healthManager.saveStepGoal(Int(dailyStepGoal))
                    dismiss()  // Go back to previous screen
                }
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.vertical, 15)
                .padding(.horizontal, 40)
                .background(Color.blue)
                .cornerRadius(15)
                .padding(.top, 20)
                
                Spacer()
            }
            .padding()
            .onAppear {
                // Load current goal when screen appears
                dailyStepGoal = Double(healthManager.dailyStepGoal)
            
        }
    }
}
