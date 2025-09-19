//
//  MonthlyOverviewView.swift
//  WalkTracker
//
//  Created by Tiffany Jia on 9/15/25.
//
import SwiftUI

struct MonthlyOverviewView: View {
    @State private var monthlyData = MonthlyData()
    
    var body: some View {
        
            VStack(spacing: 20) {
                // Monthly Header
                VStack(spacing: 5) {
                    Text("November 2024")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Monthly Overview")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
                .padding(.top)
                
                // Monthly Average Card
                VStack(spacing: 10) {
                    Text("Monthly Average")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text("\(monthlyData.averageSteps) steps")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                
                // Best and Worst Days
                HStack(spacing: 15) {
                    // Best Day Card
                    VStack(spacing: 8) {
                        HStack {
                            Image(systemName: "trophy.fill")
                                .foregroundColor(.yellow)
                            Text("Best Day")
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        
                        Text("\(monthlyData.bestDay)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("steps")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding()
                    .background(Color.green)
                    .cornerRadius(12)
                    
                    // Worst Day Card
                    VStack(spacing: 8) {
                        HStack {
                            Image(systemName: "moon.fill")
                                .foregroundColor(.white)
                            Text("Worst Day")
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        
                        Text("\(monthlyData.worstDay)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("steps")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding()
                    .background(Color.red.opacity(0.8))
                    .cornerRadius(12)
                }
                
                // Monthly Summary
                VStack(spacing: 8) {
                    Text("Your November Progress")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("You're averaging \(monthlyData.averageSteps) steps per day this month. Your most active day reached \(monthlyData.bestDay) steps - keep up the great work!")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                }
                .padding()
                .background(Color.gray.opacity(0.05))
                .cornerRadius(12)
                
                Spacer()
            }
            .padding()
        
    }
}

struct MonthlyData {
    let averageSteps: Int = 8547
    let bestDay: Int = 12890
    let worstDay: Int = 3420
}

