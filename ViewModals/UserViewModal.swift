//
//  UserViewModal.swift
//  ClothyApp
//
//  Offline demo implementation: no API calls or network dependency.
//

import Foundation
import Combine

final class UsersViewModel: ObservableObject {
    private struct LocalAccount: Codable {
        var email: String
        var password: String
        var pseudo: String
        var firstname: String
        var lastname: String
    }

    private let accountsKey = "clothy.demo.accounts.v1"
    private let resetEmailKey = "clothy.demo.pendingResetEmail"
    private let demoEmail = "demo@clothy.app"
    private let demoPassword = "Clothy123"

    private var accounts: [LocalAccount] {
        get {
            guard let data = UserDefaults.standard.data(forKey: accountsKey),
                  let saved = try? JSONDecoder().decode([LocalAccount].self, from: data) else {
                return [
                    LocalAccount(
                        email: demoEmail,
                        password: demoPassword,
                        pseudo: "clothy_demo",
                        firstname: "Clothy",
                        lastname: "Demo"
                    )
                ]
            }
            return saved
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue) else { return }
            UserDefaults.standard.set(data, forKey: accountsKey)
        }
    }

    init() {
        // Seed the demo account once so the app can be explored immediately.
        if UserDefaults.standard.data(forKey: accountsKey) == nil {
            accounts = [
                LocalAccount(
                    email: demoEmail,
                    password: demoPassword,
                    pseudo: "clothy_demo",
                    firstname: "Clothy",
                    lastname: "Demo"
                )
            ]
        }
    }

    func isValidPassword(password: String) -> Bool {
        let passwordRegex = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)[a-zA-Z\\d]{8,}$"
        return NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: password)
    }

    func textFieldValidatorEmail(
        pseudo: String,
        lastname: String,
        firstname: String,
        email: String,
        completed: (Bool, Int) -> Void
    ) {
        let normalizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let emailPattern = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        let emailIsValid = normalizedEmail.range(
            of: emailPattern,
            options: .regularExpression
        ) != nil

        if normalizedEmail.count > 100 || !emailIsValid {
            completed(false, 0)
        } else if firstname.trimmingCharacters(in: .whitespacesAndNewlines).count < 3 ||
                    firstname.count > 15 {
            completed(false, 1)
        } else if lastname.trimmingCharacters(in: .whitespacesAndNewlines).count < 3 ||
                    lastname.count > 15 {
            completed(false, 2)
        } else if pseudo.trimmingCharacters(in: .whitespacesAndNewlines).count < 3 ||
                    pseudo.count > 15 {
            completed(false, 3)
        } else {
            completed(true, 9)
        }
    }

    func connexion(email: String, password: String, completed: @escaping (Bool) -> Void) {
        let normalizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let account = accounts.first {
            $0.email.lowercased() == normalizedEmail && $0.password == password
        }

        if let account = account {
            UserDefaults.standard.set(UUID().uuidString, forKey: "session")
            UserDefaults.standard.set(account.pseudo, forKey: "clothy.demo.currentUser")
            completed(true)
        } else {
            completed(false)
        }
    }

    func inscription(user: User, completed: @escaping (Bool) -> Void) {
        let normalizedEmail = user.email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !normalizedEmail.isEmpty,
              !accounts.contains(where: { $0.email.lowercased() == normalizedEmail }) else {
            completed(false)
            return
        }

        var updatedAccounts = accounts
        updatedAccounts.append(
            LocalAccount(
                email: normalizedEmail,
                password: user.password,
                pseudo: user.pseudo,
                firstname: user.firstname,
                lastname: user.lastname
            )
        )
        accounts = updatedAccounts
        completed(true)
    }

    func forgotpassword(email: String, completed: @escaping (Bool) -> Void) {
        let normalizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard accounts.contains(where: { $0.email.lowercased() == normalizedEmail }) else {
            completed(false)
            return
        }

        UserDefaults.standard.set(normalizedEmail, forKey: resetEmailKey)
        completed(true)
    }

    func forgotpasswordcode(email: String, code: Int, completed: @escaping (Bool) -> Void) {
        let normalizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let pendingEmail = UserDefaults.standard.string(forKey: resetEmailKey)
        completed(normalizedEmail == pendingEmail && code == 123456)
    }

    func setnewpw(email: String, newpw: String, completed: @escaping (Bool) -> Void) {
        let normalizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard isValidPassword(password: newpw),
              var account = accounts.first(where: { $0.email.lowercased() == normalizedEmail }) else {
            completed(false)
            return
        }

        var updatedAccounts = accounts
        guard let index = updatedAccounts.firstIndex(where: {
            $0.email.lowercased() == normalizedEmail
        }) else {
            completed(false)
            return
        }
        account.password = newpw
        updatedAccounts[index] = account
        accounts = updatedAccounts
        UserDefaults.standard.removeObject(forKey: resetEmailKey)
        completed(true)
    }
}
