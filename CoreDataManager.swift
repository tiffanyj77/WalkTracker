import Foundation
import CoreData

class CoreDataManager: ObservableObject {
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "WalkTracker")
        container.loadPersistentStores { _, error in
            if let error = error {
                print("Core Data error: \(error)")
            }
        }
        return container
    }()
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func save() {
        do {
            try context.save()
        } catch {
            print("Failed to save context: \(error)")
        }
    }
    
    func saveDailyWalkData(steps: Int, calories: Double, elevation: Double, distance: Double) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Check if we already have data for today
        let request: NSFetchRequest<DailyWalk> = DailyWalk.fetchRequest()
        request.predicate = NSPredicate(format: "date == %@", today as NSDate)
        
        do {
            let existingRecords = try context.fetch(request)
            
            let dailyWalk: DailyWalk
            if let existing = existingRecords.first {
                // Update existing record
                dailyWalk = existing
            } else {
                // Create new record
                dailyWalk = DailyWalk(context: context)
                dailyWalk.date = today
            }
            
            // Set the data
            dailyWalk.stepCount = Int32(steps)
            dailyWalk.caloriesBurned = calories
            dailyWalk.elevationGained = elevation
            dailyWalk.distanceWalked = distance
            
            save()
        } catch {
            print("Failed to save daily walk data: \(error)")
        }
    }
    
    func fetchRecentWalkHistory(days: Int = 7) -> [DailyWalk] {
        let request: NSFetchRequest<DailyWalk> = DailyWalk.fetchRequest()
        
        // Get data from the last specified number of days
        let calendar = Calendar.current
        let endDate = Date()
        let startDate = calendar.date(byAdding: .day, value: -days, to: endDate)!
        
        request.predicate = NSPredicate(format: "date >= %@ AND date <= %@", startDate as NSDate, endDate as NSDate)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \DailyWalk.date, ascending: false)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Failed to fetch walk history: \(error)")
            return []
        }
    }
}
