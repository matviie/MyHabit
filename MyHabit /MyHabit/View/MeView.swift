import SwiftUI
import FirebaseAuth
import CoreData


struct MeView: View {
    
    @AppStorage("uid") var userID: String = ""
    @Environment(\.managedObjectContext) private var context

    @FetchRequest(
        entity: Habit.entity(),
        sortDescriptors: [],
        predicate: NSPredicate(format: "userID == %@", Auth.auth().currentUser?.uid ?? "")
    ) var habits: FetchedResults<Habit>
    
    var userName: String {
        if let email = Auth.auth().currentUser?.email {
            return email.components(separatedBy: "@").first?.capitalized ?? "User"
        }
        return "User"
    }
    
    var body: some View {
        
        VStack {
            
            Text("Me")
                .font(.title2.bold())
                .frame(maxWidth: .infinity)
                .padding(.bottom, 10)
                .padding(.top, 20)
            
            Spacer()
            
            VStack(spacing: 6) {
                Text("Hello, \(userName)!")
                    .font(.title.bold())
                    .foregroundColor(.white)
                
                Text("You have \(habits.count) habit(s)")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.9))
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.blue)
            .cornerRadius(12)
            .padding(.horizontal)
            
            
            VStack(spacing: 8) {
                Text(MotivationalQuotes.randomQuote())
                    .font(.body.italic())
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .padding(.vertical, 12)
            }
            .frame(maxWidth: .infinity)
            .background(Color(.darkGray))
            .cornerRadius(12)
            .padding(.horizontal)
            .padding(.top, 12)
            
            Spacer()
            
            Button(action: {
                let firebaseAuth = Auth.auth()
                do {
                    try firebaseAuth.signOut()
                    withAnimation {
                        userID = ""
                    }
                } catch let signOutError as NSError {
                    print("Error signing out: %@", signOutError)
                }
            }) {
                Text("Sign Out")
                    .foregroundColor(.red)
                    .font(.headline)
                    .padding()
            }
        }
        .frame(maxHeight: .infinity)
        .padding(.bottom)
    }
}

#Preview {
    MeView()
}
