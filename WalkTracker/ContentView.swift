//
//  ContentView.swift
//  WalkTracker
//
//  Created by Tiffany Jia on 8/20/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            //tabview creates tab bar interface
            
            TodayView() //creating an instance of that view (view object)
                .tabItem {
                    Image(systemName: "figure.walk")
                    Text("Today")
                }
            
            TrendsView()
                .tabItem {
                    Image(systemName: "chart.line.uptrend.xyaxis") //systemName are a part of apple's library of symbols
                    Text("Trends")
                }
            
            GoalsView()
                .tabItem {
                    Image(systemName: "target")
                    Text("Goals")
                }
            
            FriendsView()
                .tabItem {
                    Image(systemName: "person.2.fill")
                    Text("Friends")
                }
        }
    }
}
