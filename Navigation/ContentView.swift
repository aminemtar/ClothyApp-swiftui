//
//  ContentView.swift
//  ClothyApp
//
//  Local-first Clothy experience. Authentication screens are preserved.
//

import SwiftUI
import UIKit

struct ContentView: View {
    @State var showsignin = false
    @State var forgetpw = false
    @State var showSignUp = false
    @State private var isLoggedIn = UserDefaults.standard.string(forKey: "session") != nil
    @State private var selectedTab = "Discover"
    @StateObject private var store = ClothyStore()

    private let blue = Color(hex: "5f9fff")

    var body: some View {
        Group {
            if isLoggedIn {
                dashboard
                    .transition(.opacity)
            } else {
                landingExperience
            }
        }
        .animation(.spring(response: 0.45, dampingFraction: 0.88), value: isLoggedIn)
    }

    private var landingExperience: some View {
        ZStack {
            background
            landingContent
                .offset(y: showsignin ? -50 : 0)
            Color("Shadow")
                .opacity(showsignin || showSignUp || forgetpw ? 0.4 : 0)
                .ignoresSafeArea()

            if showsignin {
                SignInView(forgetpw: $forgetpw, showSignUp: $showSignUp, showsignin: $showsignin, isLoggedIn: $isLoggedIn)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .overlay(alignment: .bottom) {
                        closeButton {
                            withAnimation(.spring()) { showsignin = false }
                        }
                    }
                    .zIndex(1)
            }

            if forgetpw {
                ForgetPasswordView(showSignIn: $showsignin, forgetpw: $forgetpw)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .overlay(alignment: .bottom) {
                        closeButton {
                            withAnimation(.spring()) {
                                forgetpw = false
                                showsignin = true
                            }
                        }
                    }
                    .zIndex(1)
            }

            if showSignUp {
                SignUpView(showSignUp: $showSignUp, showSignIn: $showsignin)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .overlay(alignment: .bottom) {
                        closeButton {
                            withAnimation(.spring()) {
                                showSignUp = false
                                showsignin = true
                            }
                        }
                    }
                    .zIndex(1)
            }
        }
    }

    private var landingContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            Spacer()
            Text("CLOTHY")
                .font(.caption.weight(.heavy))
                .tracking(5)
                .foregroundStyle(blue)
            Text("Choose your outfit wisely.")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .fixedSize(horizontal: false, vertical: true)
            Text("Organize your wardrobe, discover outfit combinations and explore clothing exchange — even without an internet connection.")
                .font(.body)
                .foregroundStyle(.secondary)
            Spacer()
            HStack(spacing: 12) {
                landingFeature(icon: "tshirt", title: "Wardrobe")
                landingFeature(icon: "sparkles", title: "Outfits")
                landingFeature(icon: "arrow.left.arrow.right", title: "Exchange")
            }
            Button {
                withAnimation(.spring(response: 0.45, dampingFraction: 0.82)) { showsignin = true }
            } label: {
                Label("Start with Clothy", systemImage: "arrow.forward")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(LinearGradient(colors: [blue, Color(hex: "7d6cff")], startPoint: .leading, endPoint: .trailing))
                    .clipShape(Capsule())
                    .shadow(color: blue.opacity(0.3), radius: 16, x: 0, y: 8)
            }
            .buttonStyle(.plain)
            Text("Offline-first demo · Data stays on this device")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity)
            Spacer()
        }
        .padding(28)
    }

    private func landingFeature(icon: String, title: String) -> some View {
        VStack(spacing: 10) {
            Image(systemName: icon).font(.title2).foregroundStyle(blue)
            Text(title).font(.caption.weight(.semibold))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .background(.white.opacity(0.7))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private func closeButton(action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: "xmark")
                .frame(width: 36, height: 36)
                .foregroundStyle(.black)
                .background(.white)
                .clipShape(Circle())
                .shadow(color: Color("Shadow").opacity(0.3), radius: 5, x: 0, y: 3)
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 8)
    }

    private var dashboard: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text("CLOTHY").font(.caption.weight(.heavy)).tracking(3).foregroundStyle(blue)
                    Text(greeting).font(.title2.bold())
                }
                Spacer()
                Image(systemName: "person.crop.circle.fill").font(.system(size: 38)).foregroundStyle(blue)
            }
            .padding(.horizontal, 22)
            .padding(.top, 12)
            .padding(.bottom, 10)

            ScrollView(showsIndicators: false) {
                Group {
                    switch selectedTab {
                    case "Wardrobe":
                        WardrobeView(store: store)
                    case "Outfits":
                        VStack(alignment: .leading, spacing: 24) {
                            OutfitGeneratorView(store: store)
                            Divider()
                            SavedOutfitsView(store: store)
                        }
                    case "Trade":
                        TradeView(store: store)
                    case "Profile":
                        ClothyProfileView(store: store)
                    default:
                        discoverContent
                    }
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            HStack(spacing: 0) {
                tabItem("Discover", icon: "sparkles")
                tabItem("Wardrobe", icon: "tshirt")
                tabItem("Outfits", icon: "heart")
                tabItem("Trade", icon: "arrow.left.arrow.right")
                tabItem("Profile", icon: "person.crop.circle")
            }
            .padding(.top, 9)
            .padding(.bottom, 5)
            .background(.regularMaterial)
        }
        .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea())
    }

    private var greeting: String {
        "Hello, \(UserDefaults.standard.string(forKey: "clothy.demo.currentUser") ?? "style lover") 👋"
    }

    private var discoverContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 7) {
                Text("Your style, your rules.")
                    .font(.system(size: 29, weight: .bold, design: .rounded))
                Text("Make more of the clothes you already own.")
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 14) {
                Image(systemName: "tshirt.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(blue)
                    .frame(width: 62, height: 62)
                    .background(blue.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                VStack(alignment: .leading, spacing: 4) {
                    Text("Your wardrobe").font(.headline)
                    Text("\(store.items.count) clothing items saved locally").font(.subheadline).foregroundStyle(.secondary)
                    Button("Manage wardrobe") { selectedTab = "Wardrobe" }
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(blue)
                }
                Spacer(minLength: 0)
            }
            .padding(15)
            .background(.background)
            .clipShape(RoundedRectangle(cornerRadius: 20))

            VStack(alignment: .leading, spacing: 10) {
                Text("Outfit of the day").font(.headline)
                Text("Generate a combination from your own pieces for everyday, work, formal occasions, sport or travel.")
                    .font(.subheadline).foregroundStyle(.secondary)
                Button {
                    selectedTab = "Outfits"
                } label: {
                    Label("Create an outfit", systemImage: "sparkles")
                        .font(.headline).frame(maxWidth: .infinity).padding()
                        .background(blue).foregroundStyle(.white).clipShape(RoundedRectangle(cornerRadius: 15))
                }
            }
            .padding(16)
            .background(.background)
            .clipShape(RoundedRectangle(cornerRadius: 20))

            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("Community exchange").font(.headline)
                    Spacer()
                    Button("Open") { selectedTab = "Trade" }.font(.subheadline.weight(.semibold)).foregroundStyle(blue)
                }
                Text("Create a local demo listing and try out the exchange interface.")
                    .font(.subheadline).foregroundStyle(.secondary)
                Label("\(store.listings.count) local listings", systemImage: "arrow.left.arrow.right")
                    .font(.caption.weight(.semibold)).foregroundStyle(blue)
            }
            .padding(16)
            .background(.background)
            .clipShape(RoundedRectangle(cornerRadius: 20))

            Label("Offline mode is active. Weather, cloud AI and real user-to-user trading are not connected.", systemImage: "wifi.slash")
                .font(.footnote).foregroundStyle(.secondary)
        }
    }

    private func tabItem(_ title: String, icon: String) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.18)) { selectedTab = title }
        } label: {
            VStack(spacing: 5) {
                Image(systemName: icon).font(.system(size: 17, weight: .semibold))
                Text(title).font(.system(size: 10, weight: .medium))
            }
            .foregroundStyle(selectedTab == title ? blue : Color.secondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 4)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private var background: some View {
        ZStack {
            LinearGradient(colors: [Color(hex: "F5F7FF"), Color(hex: "E8EEFF"), Color(hex: "F8EFFF")], startPoint: .topLeading, endPoint: .bottomTrailing)
            Circle().fill(Color(hex: "8BB8FF").opacity(0.38)).frame(width: 280, height: 280).blur(radius: 55).offset(x: 130, y: -220)
            Circle().fill(Color(hex: "BCA4FF").opacity(0.34)).frame(width: 260, height: 260).blur(radius: 60).offset(x: -140, y: 220)
        }
        .ignoresSafeArea()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
        ContentView().preferredColorScheme(.dark).previewDevice("iPhone 13 mini")
    }
}
