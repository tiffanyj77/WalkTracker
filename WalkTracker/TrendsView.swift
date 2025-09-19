import SwiftUI

struct TrendsView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    
                    // Embed your complete WeeklyChart here
                    WeeklyChart()
                    
                    Divider()
                        .padding(.vertical,10)
                    
                    MonthlyOverviewView()
                }
                .padding()
            }
            .navigationTitle("Trends")
        }
    }
}
