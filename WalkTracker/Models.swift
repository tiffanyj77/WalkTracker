//
//  Models.swift
//  WalkTracker
//
//  Created by Tiffany Jia on 9/12/25.
//

import Foundation

struct DailyStats: Codable {
    let date: Date
    let steps: Int
    let calories: Double
    let distance: Double
    let flights: Int
}
