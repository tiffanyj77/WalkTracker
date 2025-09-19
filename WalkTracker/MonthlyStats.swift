import Foundation

struct MonthlyStats {
    let month: String
    let year: Int
    let averageSteps: Int
    let averageCalories: Double
    let averageElevation: Double
    let bestDay: DayStats?
    let worstDay: DayStats?
}

struct DayStats {
    let date: Date
    let steps: Int
    let calories: Double
    let elevation: Double
    
    var totalScore: Double {
        // Simple scoring system: steps/100 + calories/10 + elevation/10
        return Double(steps)/100 + calories/10 + elevation/10
    }
}

