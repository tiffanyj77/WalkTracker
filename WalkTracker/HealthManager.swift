import Foundation
import HealthKit

class HealthManager: ObservableObject {
    static let shared = HealthManager()
    private let healthStore = HKHealthStore()
    
    @Published var todaySteps: Int = 0
    @Published var isAuthorized: Bool = false
    @Published var caloriesBurned: Double = 0      // Add this
    @Published var flightsClimbed: Double = 0
    @Published var errorMessage: String = ""
    @Published var elevationGained = 0.0
    @Published var dailyStepGoal: Int = 10000
    @Published var distanceWalked = 0.0
    @Published var stepCount = 0
    @Published var weeklySteps: [Int] = Array(repeating: 0, count: 7)
    @Published var monthlyStats: MonthlyStats?
    
    func fetchWeeklySteps() {
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            print("Step count data type not available")
            return
        }
        
        let calendar = Calendar.current
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: Date())?.start ?? Date()
        var tempWeeklySteps: [Int] = Array(repeating: 0, count: 7)
        
        let group = DispatchGroup()
        
        for dayOffset in 0..<7 {
            group.enter()
            
            let dayStart = calendar.date(byAdding: .day, value: dayOffset, to: startOfWeek)!
            let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart)!
            let predicate = HKQuery.predicateForSamples(withStart: dayStart, end: dayEnd, options: .strictStartDate)
            
            let query = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
                defer { group.leave() }
                
                guard let result = result, let sum = result.sumQuantity() else {
                    tempWeeklySteps[dayOffset] = 0
                    return
                }
                
                tempWeeklySteps[dayOffset] = Int(sum.doubleValue(for: HKUnit.count()))
            }
            
            healthStore.execute(query)
        }
        
        group.notify(queue: .main) {
            self.weeklySteps = tempWeeklySteps
        }
    }

    var weekDayLabels: [String] {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        let calendar = Calendar.current
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: Date())?.start ?? Date()
        
        return (0..<7).map { dayOffset in
            let date = calendar.date(byAdding: .day, value: dayOffset, to: startOfWeek) ?? Date()
            return formatter.string(from: date)
        }
    }
    
    func saveTodaysStats() {
        let coreDataManager = CoreDataManager()
        
        coreDataManager.saveDailyWalkData(
            steps: stepCount,
            calories: caloriesBurned,
            elevation: elevationGained,
            distance: distanceWalked
        )
        
        print("✅ Saved today's stats to Core Data: \(stepCount) steps, \(String(format: "%.1f", caloriesBurned)) calories, \(String(format: "%.0f", elevationGained)) feet")
    }
    

    func fetchDistanceWalked() {
        guard let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning) else {
            print("Distance data type not available")
            return
        }
        
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: distanceType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
            guard let result = result, let sum = result.sumQuantity() else {
                DispatchQueue.main.async {
                    self.distanceWalked = 0.0
                }
                return
            }
            
            let distance = sum.doubleValue(for: HKUnit.mile())
            DispatchQueue.main.async {
                self.distanceWalked = distance
            }
        }
        
        healthStore.execute(query)
    }
    
    var goalProgress: Double {
        guard dailyStepGoal > 0 else { return 0.0 }
        return min(max(Double(todaySteps) / Double(dailyStepGoal), 0.0), 1.0)
    }

    private func checkHealthDataAvailability() {
        guard HKHealthStore.isHealthDataAvailable() else {
            errorMessage = "Health data is not available on this device"
            return
        }
    }
    
    func fetchTodaySteps(completion: @escaping (Double) -> Void) {
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            DispatchQueue.main.async {
                self.errorMessage = "Step count type is not available"
                completion(0)
            }
            return
        }
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        // Change this line in fetchTodaySteps:
        let endOfDay = Date()  // Use current time instead of tomorrow

        
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: .strictStartDate)
        
        let query = HKStatisticsQuery(
            quantityType: stepType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) { [weak self] query, statistics, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = "Failed to fetch steps: \(error.localizedDescription)"
                    completion(0)
                    return
                }
                
                let steps = statistics?.sumQuantity()?.doubleValue(for: HKUnit.count()) ?? 0
                self?.todaySteps = Int(steps)
                
                completion(steps) // ← This was missing!
            }
        }
        
        healthStore.execute(query)
    }
    
    func requestPermission() {
        guard HKHealthStore.isHealthDataAvailable() else {
            DispatchQueue.main.async {
                self.errorMessage = "HealthKit is not available on this device"
                self.isAuthorized = true //MEOW
            }
            return
        }
        
        let typesToRead: Set<HKObjectType> = [
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
            HKObjectType.quantityType(forIdentifier: .flightsClimbed)!
        ]
        
        // Check current authorization status FIRST
        let stepType = HKObjectType.quantityType(forIdentifier: .stepCount)!
        let currentStatus = healthStore.authorizationStatus(for: stepType)
        
        print("🔍 Current authorization status: \(statusDescription(currentStatus))")
        
        // If already authorized, just fetch data immediately
        //        if currentStatus == .sharingAuthorized {
        //            print("✅ Already authorized! Fetching data...")
        DispatchQueue.main.async {
            self.isAuthorized = true
            self.errorMessage = ""
            self.fetchAllHealthData()
        }
        return
    //}
        
        // Need to request authorization
//        print("🔄 Requesting HealthKit authorization...")
//        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { success, error in
//            DispatchQueue.main.async {
//                if let error = error {
//                    print("⚠️ HealthKit authorization error: \(error.localizedDescription)")
//                    self.errorMessage = "HealthKit error: \(error.localizedDescription)"
//                    self.isAuthorized = false
//                    return
//                }
//                
//                // Check the new status after authorization request
//                let newStatus = self.healthStore.authorizationStatus(for: stepType)
//                
//                print("📊 Final Authorization Status:")
//                print("Steps: \(newStatus.rawValue) (\(self.statusDescription(newStatus)))")
//                
//                switch newStatus {
//                case .sharingAuthorized:
//                    print("✅ Permissions granted! Fetching health data...")
//                    self.isAuthorized = true
//                    self.errorMessage = ""
//                    self.fetchAllHealthData()
//                    
//                case .sharingDenied:
//                    print("❌ Permissions explicitly denied")
//                    self.isAuthorized = false
//                    self.errorMessage = "Health access denied. Please enable in Settings > Privacy & Security > Health > WalkTracker to track your steps."
//                    
//                case .notDetermined:
//                    print("⚠️ Permission dialog may not have appeared")
//                    self.isAuthorized = false
//                    self.errorMessage = "Permission dialog didn't appear. Please go to Settings > Privacy & Security > Health > WalkTracker and enable Step Count."
//                    
//                @unknown default:
//                    print("❓ Unknown permission state")
//                    self.isAuthorized = false
//                    self.errorMessage = "Unable to access Health data. Please check your settings."
//                }
//            }
//        }
    }

    
    

    // Helper method to convert status to readable string
    private func statusDescription(_ status: HKAuthorizationStatus) -> String {
        switch status {
        case .notDetermined:
            return "Not Determined"
        case .sharingDenied:
            return "Denied"
        case .sharingAuthorized:
            return "Authorized"
        @unknown default:
            return "Unknown"
        }
    }
    
    
//    func requestPermission() {
//        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount),
//              let calorieType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned),
//              let elevationType = HKQuantityType.quantityType(forIdentifier: .flightsClimbed),
//              let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning) else {
//            DispatchQueue.main.async {
//                self.errorMessage = "Health data types not available"
//            }
//            return
//        }
//        
//        let typesToRead: Set<HKObjectType> = [stepType, calorieType, elevationType, distanceType]
//        
//        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { [weak self] success, error in
//            DispatchQueue.main.async {
//                // Check actual authorization status instead of relying on 'success'
//                let stepStatus = self?.healthStore.authorizationStatus(for: stepType)
//                
//                if stepStatus == .sharingAuthorized {
//                    print("✅ Health data access granted")
//                    self?.isAuthorized = true
//                    self?.errorMessage = ""
//                    self?.fetchAllHealthData()
//                } else {
//                    print("❌ Health data access denied or not determined. Status: \(stepStatus?.rawValue ?? -1)")
//                    self?.isAuthorized = false
//                    
//                    // Better error messages based on status
//                    switch stepStatus {
//                    case .notDetermined:
//                        self?.errorMessage = "Health access not determined. Please try again."
//                    case .sharingDenied:
//                        self?.errorMessage = "Health access denied. Enable in Settings > Privacy & Security > Health > WalkTracker."
//                    default:
//                        self?.errorMessage = "Health access unavailable."
//                    }
//                }
//                
//                // Also log any system errors
//                if let error = error {
//                    print("⚠️ HealthKit system error: \(error.localizedDescription)")
//                }
//            }
//        }
//    }
    
    func fetchCalories(completion: @escaping (Double) -> Void) {
        let calorieType = HKQuantityType(.activeEnergyBurned)
        let calendar = Calendar.current
        let startDate = calendar.startOfDay(for: Date())
        let endDate = Date()
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: calorieType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            guard let result = result, let sum = result.sumQuantity() else {
                completion(0.0)
                return
            }
            
            let calories = sum.doubleValue(for: HKUnit.kilocalorie())
            DispatchQueue.main.async {
                self.caloriesBurned = calories
                completion(calories)
            }
        }
        
        healthStore.execute(query)
    }
    
    func fetchFlightsClimbed(completion: @escaping (Double) -> Void) {
        let flightType = HKQuantityType(.flightsClimbed)
        let calendar = Calendar.current
        let startDate = calendar.startOfDay(for: Date())
        let endDate = Date()
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: flightType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            guard let result = result, let sum = result.sumQuantity() else {
                completion(0.0)
                return
            }
            
            let flights = sum.doubleValue(for: HKUnit.count())
            DispatchQueue.main.async {
                self.flightsClimbed = flights
                completion(flights)
            }
        }
        
        healthStore.execute(query)
    }
    func fetchAllHealthData() {
        fetchTodaySteps{ _ in }
        fetchCalories { _ in }
        fetchFlightsClimbed { _ in}
        fetchDistanceWalked()
        fetchWeeklySteps()
        
            
        // Auto-save today's stats after fetching
        
    }
    
        
    init() {
        checkHealthDataAvailability()
        loadSavedGoal()  // Add this line
    }
    
    // Add these methods:
    func saveStepGoal(_ goal: Int) {
        DispatchQueue.main.async {
            self.dailyStepGoal = goal
            UserDefaults.standard.set(goal, forKey: "dailyStepGoal")
            print("Goal saved: \(goal) steps")
        }
    }
    
    private func loadSavedGoal() {
        let savedGoal = UserDefaults.standard.integer(forKey: "dailyStepGoal")
        if savedGoal > 0 {
            self.dailyStepGoal = savedGoal
        }
    }
    
}
