//
//  SignInView.swift
//  ClothyApp
//
//  Created by haithem ghattas on 17/12/2022.
//

import SwiftUI
import RiveRuntime
struct SignInView: View {
    @State var isLoading = false
    @State var email : String = ""
    @State var password : String = ""
    @Binding var forgetpw : Bool
    @Binding var showSignUp : Bool
    @Binding var showsignin : Bool
    @Binding var isLoggedIn: Bool
    @State private var authError = false
    @StateObject private var Vm = UsersViewModel()
    let confetti = RiveViewModel(fileName: "confetti", stateMachineName: "State Machine 1")
    let check = RiveViewModel(fileName: "check", stateMachineName: "State Machine 1")

    
    var body: some View {
        
        VStack(spacing: 24) {
            Text("Sign In")
                .font(.largeTitle).bold()
            VStack(alignment: .leading) {
                Text("Email")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                TextField("", text: $email)
                    .customTextField()
            }
            VStack(alignment: .leading) {
                Text("Password")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                SecureField("", text: $password)
                    .customTextField(image: Image(systemName: "lock"))
            }
            if authError {
                Text("Email or password is incorrect. Try the demo account below.")
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            Button {
                let newmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
                Vm.connexion(email: newmail, password: password, completed: { response in
                    if response {
                        authError = false
                        withAnimation(.spring()) {
                            isLoggedIn = true
                            showsignin = false
                        }
                    } else {
                        authError = true
                    }
                })
            
        }
        
    label: {
            Label("Sign In", systemImage: "arrow.right")
                .font(.headline)
                .padding(20)
                .frame(maxWidth: .infinity)
                .background(Color(hex: "5f9fff"))
                .foregroundColor(.white)
                .cornerRadius(20, corners: [.topRight, .bottomLeft, .bottomRight])
                .cornerRadius(8, corners: [.topLeft])
            .shadow(color: Color(hex: "5f9fff").opacity(0.5), radius: 20, x: 0, y: 10)
    }
            VStack(spacing: 5) {
                Text("Demo account")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                Text("demo@clothy.app  ·  Clothy123")
                    .font(.caption.monospaced())
                    .textSelection(.enabled)
            }
            HStack{
                Text("Forgot password?  Reset")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .onTapGesture {
                        forgetpw.toggle()
                        showsignin.toggle()
                }
            }
            VStack{
                HStack {
                    Rectangle().frame(height: 1).opacity(0.1)
                    Text("OR").font(.subheadline).foregroundColor(.black.opacity(0.3))
                    Rectangle().frame(height: 1).opacity(0.1)
                    
                }
                Button(action: {
//                    self.loginVM.facebookLogin { completionData,data  in
//                            // Do operation with String
//                           // print(completionData);
//                        if(completionData){
//                            print(completionData)
//                            logIn()
//                        }
//
//                        }
                }) {
                    Text("login with facebook")
                }
                Button {
                    withAnimation {
                        showsignin.toggle()
                        showSignUp.toggle()
                      //  showModal = false
                    }
               
                    
                    
                } label: {
                    Label("Sign Up", systemImage: "arrow.right")
                        .font(.headline)
                        .padding(20)
                        .frame(maxWidth: .infinity)
                        .background(Color(hex: "5f9fff"))
                        .foregroundColor(.white)
                        .cornerRadius(20, corners: [.topRight, .bottomLeft, .bottomRight])
                        .cornerRadius(8, corners: [.topLeft])
                    .shadow(color: Color(hex: "5f9fff").opacity(0.5), radius: 20, x: 0, y: 10)
                }
                HStack {
                    Rectangle().frame(height: 1).opacity(0.1)
                    .font(.subheadline).foregroundColor(.black.opacity(0.3))
                    Rectangle().frame(height: 1).opacity(0.1)
                    
                }
                Text("Sign up with Email, Apple or Google")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack {
                    
                    Image("Logo Email").onTapGesture {
                    //    login.toggle()
                    }
                    Spacer()
                 
                    Image("Logo Apple")
                    Spacer()
                    Image("Logo Google")
                }

                    
            }
            
            
        }
        .padding(30)
        .background(.regularMaterial)
        .mask(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: Color("Shadow").opacity(0.3), radius: 5, x: 0, y: 3)
        .shadow(color: Color("Shadow").opacity(0.3), radius: 30, x: 0, y: 30)
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(.linearGradient(colors: [.white.opacity(0.8), .white.opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing))
        )
        .padding()
    }

}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView(forgetpw: .constant(false), showSignUp: .constant(false), showsignin: .constant(false), isLoggedIn: .constant(false))
    }
}
