import SwiftUI

struct TodayView: View {
    @ObservedObject private var healthManager = HealthManager.shared

    private let dailyGoal = 10000
    
    private var progressPercentage: Double {
        Double(healthManager.todaySteps) / Double(dailyGoal)
    }
    
    private var stepsRemaining: Int {
        max(0, dailyGoal - healthManager.todaySteps)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                    VStack(spacing: 5) {
                        Text("\(healthManager.todaySteps)")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Text("steps today")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 40)
                    
                    // Progress ring
                    ZStack {
                        Circle()
                            .stroke(Color.gray.opacity(0.2), lineWidth: 12)
                            .frame(width: 120, height: 120)
                        
                        Circle()
                            .trim(from: 0, to: min(progressPercentage, 1.0))
                            .stroke(Color.blue, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                            .frame(width: 120, height: 120)
                            .rotationEffect(.degrees(-90))
                        
                        Text("\(Int(min(progressPercentage, 1.0) * 100))%")
                            .font(.title3)
                            .fontWeight(.semibold)
                    }
                    
                    // Goal information
                    VStack(spacing: 5) {
                        Text("Goal: \(dailyGoal) steps")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        if stepsRemaining > 0 {
                            Text("\(stepsRemaining) steps to go")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                        } else {
                            Text("Goal completed! 🎉")
                                .font(.subheadline)
                                .foregroundColor(.green)
                        }
                    }
                    
                    // Distance and calories row
                    HStack(spacing: 40) {
                        VStack(spacing: 5) {
                            Text("2.1")
                                .font(.title2)
                                .fontWeight(.semibold)
                            Text("miles")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        VStack(spacing: 5) {
                            Text("184")
                                .font(.title2)
                                .fontWeight(.semibold)
                            Text("calories")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    VStack(spacing: 20) {
                        Text("Calories: \(healthManager.caloriesBurned, specifier: "%.1f")")
                            .font(.title2)
                        
                        Text("Flights: \(Int(healthManager.flightsClimbed))")
                            .font(.title2)
                        
                        Button("Refresh Data") {
                            healthManager.fetchTodaySteps { _ in }
                            healthManager.fetchCalories { _ in }
                            healthManager.fetchFlightsClimbed { _ in }
                        }
                        .font(.title2)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                }
                Spacer()
            }
            .onAppear {
                if !healthManager.isAuthorized && healthManager.errorMessage.isEmpty {
                    healthManager.requestPermission()
                }
            }
            .navigationTitle("Today")
        }
    }



//                if !healthManager.errorMessage.isEmpty {
//                    // Error state
//                    VStack(spacing: 20) {
//                        Image(systemName: "exclamationmark.triangle")
//                            .font(.system(size: 48))
//                            .foregroundColor(.orange)
//
//                        Text("Health Access Needed")
//                            .font(.title2)
//                            .fontWeight(.bold)
//
//                        Text(healthManager.errorMessage)
//                            .font(.body)
//                            .foregroundColor(.secondary)
//                            .multilineTextAlignment(.center)
//                            .padding(.horizontal)
//
//                        Button("Try Again") {
//                            healthManager.requestPermission()
//                        }
//                        .font(.headline)
//                        .foregroundColor(.white)
//                        .padding()
//                        .background(Color.blue)
//                        .cornerRadius(10)
//                    }
//                } else if !healthManager.isAuthorized {
//                    // Loading state
//                    VStack(spacing: 20) {
//                        ProgressView()
//                            .scaleEffect(1.5)
//
//                        Text("Loading your step data...")
//                            .font(.headline)
//                            .foregroundColor(.secondary)
//                    }
//                } else {
//                    // Normal dashboard state
//                    // Main step counter
