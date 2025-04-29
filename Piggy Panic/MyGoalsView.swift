import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct Goal: Identifiable {
    var id: String
    var goalName: String
    var targetAmount: Double
    var savingPerFrequency: Double
    var savedAmount: Double
    var startDate: Date
    var endDate: Date
    var frequency: String
    var periods: Int
    var lastCheckInDate: Date?
}

struct MyGoalsView: View {
    @State private var goals: [Goal] = []

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color.yellow.opacity(0.1), Color.pink.opacity(0.2)]), startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()

                VStack {
                    Text("My Goals 🐷")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.pink)
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                        .padding()

                    if goals.isEmpty {
                        Spacer()
                        VStack {
                            Text("No goals yet.")
                                .font(.title2)
                                .foregroundColor(.pink)
                            Text("Set one to keep your piggy calm! 🐷")
                                .font(.body)
                                .foregroundColor(.gray)
                        }
                        .multilineTextAlignment(.center)
                        .padding()
                        Spacer()
                    } else {
                        ScrollView {
                            VStack(spacing: 20) {
                                ForEach(goals) { goal in
                                    GoalCard(goal: goal, onSave: fetchGoals)
                                }
                            }
                        }
                    }
                }
            }
            .onAppear(perform: fetchGoals)
        }
    }

    func fetchGoals() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        db.collection("users").document(userID).collection("goals").getDocuments { snapshot, error in
            if let documents = snapshot?.documents {
                goals = documents.compactMap { doc in
                    let data = doc.data()
                    return Goal(
                        id: doc.documentID,
                        goalName: data["goalName"] as? String ?? "",
                        targetAmount: data["targetAmount"] as? Double ?? 0,
                        savingPerFrequency: data["savingPerFrequency"] as? Double ?? 0,
                        savedAmount: data["savedAmount"] as? Double ?? 0,
                        startDate: (data["startDate"] as? Timestamp)?.dateValue() ?? Date(),
                        endDate: (data["endDate"] as? Timestamp)?.dateValue() ?? Date(),
                        frequency: data["frequency"] as? String ?? "",
                        periods: data["periods"] as? Int ?? 0,
                        lastCheckInDate: (data["lastCheckInDate"] as? Timestamp)?.dateValue()
                    )
                }
            }
        }
    }
}

struct GoalCard: View {
    var goal: Goal
    var onSave: () -> Void

    @State private var amountText = ""
    @State private var messageText = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(goal.goalName)
                    .font(.headline)
                Spacer()
                Text(piggyMood(for: goal))
            }

            ProgressView(value: goal.savedAmount, total: goal.targetAmount)
                .tint(.pink)

            Text("Next saving: \(formattedDate(nextSavingDate(for: goal)))")
                .font(.caption)
                .foregroundColor(.orange)

            HStack {
                Text("Saved: $\(goal.savedAmount, specifier: "%.2f") / $\(goal.targetAmount, specifier: "%.2f")")
                    .font(.subheadline)
                Spacer()
            }

            TextField("Amount ($)", text: $amountText)
                .keyboardType(.decimalPad)
                .padding(8)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)

            HStack(spacing: 10) {
                Button("Add") {
                    processCheckIn(isWithdraw: false)
                }
                .buttonStyle(.borderedProminent)
                .tint(.orange)

                Button("Withdraw") {
                    processCheckIn(isWithdraw: true)
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)
            }

            if !messageText.isEmpty {
                Text(messageText)
                    .foregroundColor(.pink)
                    .font(.subheadline)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: .pink.opacity(0.2), radius: 5)
        .padding(.horizontal)
    }

    func processCheckIn(isWithdraw: Bool) {
        guard let amount = Double(amountText), amount > 0 else {
            messageText = "Please enter a valid amount."
            return
        }
        if isWithdraw && amount > goal.savedAmount {
            messageText = "You can't withdraw more than what's saved!"
            return
        }

        let db = Firestore.firestore()
        guard let userID = Auth.auth().currentUser?.uid else { return }
        let docRef = db.collection("users").document(userID).collection("goals").document(goal.id)

        docRef.updateData([
            "savedAmount": FieldValue.increment(isWithdraw ? -amount : amount),
            "lastCheckInDate": Timestamp(date: Date())
        ]) { error in
            if let error = error {
                messageText = "Error: \(error.localizedDescription)"
            } else {
                messageText = isWithdraw ? "Oh no! Piggy's panicked 😱." : "Yay! Piggy is thrilled 🐷💰."
                amountText = ""
                onSave()
            }
        }
    }

    func piggyMood(for goal: Goal) -> String {
        let calendar = Calendar.current
        let today = Date()
        let periodsPassed: Int
        switch goal.frequency {
            case "Daily": periodsPassed = calendar.dateComponents([.day], from: goal.startDate, to: today).day ?? 0
            case "Weekly": periodsPassed = (calendar.dateComponents([.day], from: goal.startDate, to: today).day ?? 0) / 7
            case "Fortnightly": periodsPassed = (calendar.dateComponents([.day], from: goal.startDate, to: today).day ?? 0) / 14
            case "Monthly": periodsPassed = calendar.dateComponents([.month], from: goal.startDate, to: today).month ?? 0
            default: periodsPassed = 0
        }
        let expectedSavings = Double(periodsPassed) * goal.savingPerFrequency
        return goal.savedAmount >= expectedSavings ? "😊" : "😱"
    }

    func nextSavingDate(for goal: Goal) -> Date {
        let lastDate = goal.lastCheckInDate ?? goal.startDate
        var dateComponent = DateComponents()

        switch goal.frequency {
            case "Daily": dateComponent.day = 1
            case "Weekly": dateComponent.day = 7
            case "Fortnightly": dateComponent.day = 14
            case "Monthly": dateComponent.month = 1
            default: break
        }
        return Calendar.current.date(byAdding: dateComponent, to: lastDate) ?? lastDate
    }

    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

#Preview {
    MyGoalsView()
}
