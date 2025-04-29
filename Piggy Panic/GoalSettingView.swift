import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct GoalSettingView: View {
    @Environment(\.dismiss) var dismiss

    @State private var goalName = ""
    @State private var targetAmount = ""
    @State private var amountPerFrequency = ""
    @State private var startDate = Date()
    @State private var frequency = "Weekly"
    
    @State private var navigateToMyGoals = false  // Add this for navigation

    let frequencies = ["Daily", "Weekly", "Fortnightly", "Monthly"]

    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(gradient: Gradient(colors: [Color.pink.opacity(0.1), Color.yellow.opacity(0.2)]), startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()

                VStack(spacing: 20) {
                    Text("Set Your Savings Goal 🐷")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.pink)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)

                    // Goal Name
                    TextField("Goal Name", text: $goalName)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: .pink.opacity(0.3), radius: 5)
                        .padding(.horizontal)

                    // Target Amount
                    TextField("Target Amount ($)", text: $targetAmount)
                        .keyboardType(.numberPad)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: .orange.opacity(0.3), radius: 5)
                        .padding(.horizontal)

                    // Amount Per Frequency
                    TextField("Saving Per \(frequency)", text: $amountPerFrequency)
                        .keyboardType(.numberPad)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: .orange.opacity(0.3), radius: 5)
                        .padding(.horizontal)

                    // Start Date
                    DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                        .padding(.horizontal)

                    // Frequency Picker
                    Picker("Frequency", selection: $frequency) {
                        ForEach(frequencies, id: \.self) { freq in
                            Text(freq)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)

                    // Calculation Summary
                    if let periods = calculateTotalPeriods(), let endDate = calculateEndDate(periods: periods) {
                        VStack {
                            Text("It will take \(periods) \(frequency.lowercased())s to reach your goal.")
                            Text("Estimated end date: \(formattedDate(endDate))")
                        }
                        .font(.headline)
                        .foregroundColor(.orange)
                    }

                    // Save Button
                    Button(action: saveGoal) {
                        Text("Save Goal")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(LinearGradient(gradient: Gradient(colors: [Color.pink, Color.orange]), startPoint: .leading, endPoint: .trailing))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .shadow(color: .orange.opacity(0.4), radius: 5)
                    }
                    .padding(.horizontal)

                    Spacer()
                    
                    // Navigation to MyGoalsView
                        .navigationDestination(isPresented: $navigateToMyGoals) {
                            MyGoalsView()
                        }
                }
                .padding()
            }
        }
    }

    // MARK: - Calculation Logic

    func calculateTotalPeriods() -> Int? {
        guard let target = Double(targetAmount), let perPeriod = Double(amountPerFrequency), perPeriod > 0 else { return nil }
        let periods = Int(ceil(target / perPeriod))
        return periods
    }

    func calculateEndDate(periods: Int) -> Date? {
        var dateComponent = DateComponents()
        switch frequency {
            case "Daily": dateComponent.day = periods
            case "Weekly": dateComponent.day = periods * 7
            case "Fortnightly": dateComponent.day = periods * 14
            case "Monthly": dateComponent.month = periods
            default: return nil
        }
        return Calendar.current.date(byAdding: dateComponent, to: startDate)
    }

    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    // MARK: - Save to Firestore

    func saveGoal() {
        guard let target = Double(targetAmount), let perPeriod = Double(amountPerFrequency) else { return }
        let periods = calculateTotalPeriods() ?? 0
        let endDate = calculateEndDate(periods: periods) ?? Date()

        let db = Firestore.firestore()
        let userID = Auth.auth().currentUser?.uid ?? "unknown"

        let goalData: [String: Any] = [
            "goalName": goalName,
            "targetAmount": target,
            "savingPerFrequency": perPeriod,
            "startDate": Timestamp(date: startDate),
            "endDate": Timestamp(date: endDate),
            "frequency": frequency,
            "periods": periods,
            "createdAt": Timestamp()
        ]

        db.collection("users").document(userID).collection("goals").addDocument(data: goalData) { error in
            if let error = error {
                print("Error saving goal: \(error.localizedDescription)")
            } else {
                navigateToMyGoals = true  // Navigate after saving
            }
        }
    }
}

struct GoalSettingView_Previews: PreviewProvider {
    static var previews: some View {
        GoalSettingView()
    }
}
