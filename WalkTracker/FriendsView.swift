//
//  FriendsView.swift
//  WalkTracker
//
//  Created by Tiffany Jia on 8/24/25.
//

import SwiftUI

struct FriendsView: View {
    let friends = [
        Friend(name: "Sarah", steps: 12500, emoji: "🏃‍♀️"),
        Friend(name: "Mike", steps: 8200, emoji: "🚶‍♂️"),
        Friend(name: "Emma", steps: 15400, emoji: "💪"),
        Friend(name: "David", steps: 6800, emoji: "🎯"),
        Friend(name: "Lisa", steps: 11200, emoji: "⭐")
    ]
    
    @State private var isRefreshing = false
    
    var body: some View {
        NavigationView {
            
            List(friends.sorted { $0.steps > $1.steps }.enumerated().map { (index, friend) in
                (rank: index + 1, friend: friend)
            }, id: \.friend.id) { item in
                HStack(spacing: 15) {
                    // Rank indicator
                    Text("#\(item.rank)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.secondary)
                        .frame(width: 30)
                    
                    Text(item.friend.emoji)
                        .font(.title)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(item.friend.name)
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            if item.rank == 1 {
                                Text("👑")
                                    .font(.caption)
                            }
                        }
                        
                        Text("\(item.friend.steps.formatted()) steps")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                    }
                    
                    Spacer()
                }
                .padding(.vertical, 4)
            }
            .refreshable {
                await refreshFriendsList()
            }
            .navigationTitle("Friends")
        }
    }
    
    @MainActor
    func refreshFriendsList() async {
        isRefreshing = true
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds
        isRefreshing = false
    }
}
