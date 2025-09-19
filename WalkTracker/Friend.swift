import Foundation

struct Friend: Identifiable {
    let id = UUID()
    let name: String
    let steps: Int
    let emoji: String
}

