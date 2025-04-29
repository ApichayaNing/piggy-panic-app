import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""
    @State private var isLoggedIn = false
    @State private var showPasswordResetAlert = false
    @State private var passwordResetEmail = ""

    var body: some View {
        VStack(spacing: 20) {
            Text("Log In")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.pink)

            // Email Field
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            // Password Field
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            // Forgot Password Button
            Button("Forgot Password?") {
                showPasswordResetAlert = true
            }
            .foregroundColor(.blue)
            .padding(.top, 5)

            // Error Message
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.horizontal)
            }

            // Log In Button
            Button(action: logInUser) {
                Text("Log In")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(LinearGradient(gradient: Gradient(colors: [Color.pink, Color.orange]), startPoint: .leading, endPoint: .trailing))
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .shadow(color: .orange.opacity(0.4), radius: 5)
                    .padding(.horizontal)
            }

            Spacer()
        }
        .padding(.top, 50)
        .alert("Reset Password", isPresented: $showPasswordResetAlert, actions: {
            TextField("Enter your email", text: $passwordResetEmail)
            Button("Send Reset Link", action: resetPassword)
            Button("Cancel", role: .cancel) { }
        }, message: {
            Text("We will send a password reset link to your email.")
        })
        .fullScreenCover(isPresented: $isLoggedIn) {
            ContentView() // Navigate to ContentView when logged in
        }
    }

    // Login Function
    func logInUser() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                errorMessage = error.localizedDescription
            } else {
                errorMessage = ""
                isLoggedIn = true
            }
        }
    }

    // Reset Password Function
    func resetPassword() {
        Auth.auth().sendPasswordReset(withEmail: passwordResetEmail) { error in
            if let error = error {
                errorMessage = error.localizedDescription
            } else {
                errorMessage = "Password reset link sent!"
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
