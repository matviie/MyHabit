import SwiftUI
import FirebaseAuth


struct ContentView: View {
    
    @AppStorage("uid") var userID: String = ""
    
    @StateObject var habitModel = HabitsViewModel()
    
    var body: some View {
        
        if userID == "" {
            AuthView()
        } else {
            
            TabView {
                Today()
                    .tabItem {
                        Label("Today", systemImage: "checkmark.square")
                    }
                
                Stats()
                    .tabItem {
                        Label("Stats", systemImage: "chart.bar.fill")
                    }
                
                AllHabits()
                    .tabItem {
                        Label("AllHabits", systemImage: "folder.fill")
                    }
                
                MeView()
                    .tabItem {
                        Label("Me", systemImage: "person.crop.circle")
                    }
            }
            
            .environmentObject(habitModel) 
            .preferredColorScheme(.dark)
        }
        
        
    }
}

#Preview {
    ContentView()
}
