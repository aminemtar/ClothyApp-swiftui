//
//  ContentView.swift
//  ClothyApp
//
//  Offline demo mode: the app can be explored without a backend.
//

import SwiftUI
import UIKit
import RiveRuntime

struct ContentView: View {
    let button = RiveViewModel(fileName: "button")
    @State var showsignin = false
    @State var forgetpw = false
    @State var showSignUp = false
    @State private var isLoggedIn = false
    @State private var selectedTab = "Discover"

    var body: some View {
        Group {
            if isLoggedIn {
                demoHome
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
            content
                .offset(y: showsignin ? -50 : 0)
            Color("Shadow")
                .opacity(showsignin || showSignUp || forgetpw ? 0.4 : 0)
                .ignoresSafeArea()

            if showsignin {
                SignInView(
                    forgetpw: $forgetpw,
                    showSignUp: $showSignUp,
                    showsignin: $showsignin,
                    isLoggedIn: $isLoggedIn
                )
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

    private func closeButton(action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: "xmark")
                .frame(width: 36, height: 36)
                .foregroundColor(.black)
                .background(.white)
                .clipShape(Circle())
                .shadow(color: Color("Shadow").opacity(0.3), radius: 5, x: 0, y: 3)
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 8)
    }

    // MARK: - Offline demo dashboard

    private var demoHome: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("CLOTHY")
                        .font(.caption.weight(.heavy))
                        .tracking(3)
                        .foregroundStyle(Color(hex: "5f9fff"))
                    Text(greeting)
                        .font(.title2.bold())
                }
                Spacer()
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 38))
                    .foregroundStyle(Color(hex: "5f9fff"))
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
            .padding(.bottom, 12)

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 22) {
                    switch selectedTab {
                    case "Wardrobe":
                        wardrobeContent
                    case "Trade":
                        tradeContent
                    case "Profile":
                        profileContent
                    default:
                        discoverContent
                    }
                }
                .padding(20)
                .padding(.bottom, 12)
            }

            HStack(spacing: 0) {
                tabItem("Discover", icon: "sparkles")
                tabItem("Wardrobe", icon: "tshirt")
                tabItem("Trade", icon: "arrow.left.arrow.right")
                tabItem("Profile", icon: "person.crop.circle")
            }
            .padding(.top, 10)
            .padding(.bottom, 6)
            .background(.regularMaterial)
        }
        .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea())
    }

    private var greeting: String {
        let pseudo = UserDefaults.standard.string(forKey: "clothy.demo.currentUser") ?? "style lover"
        return "Hello, \(pseudo) 👋"
    }

    private var discoverContent: some View {
        VStack(alignment: .leading, spacing: 22) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Your style, your rules.")
                    .font(.system(size: 29, weight: .bold, design: .rounded))
                Text("Explore outfit ideas made for your wardrobe.")
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 14) {
                Image(systemName: "sun.max.fill")
                    .font(.system(size: 30))
                    .foregroundStyle(Color.orange)
                    .frame(width: 64, height: 64)
                    .background(Color.orange.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                VStack(alignment: .leading, spacing: 5) {
                    Text("Today's inspiration")
                        .font(.headline)
                    Text("Casual layers · Neutral tones")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text("3 pieces · Easy everyday look")
                        .font(.caption)
                        .foregroundStyle(Color(hex: "5f9fff"))
                }
                Spacer(minLength: 0)
            }
            .padding(16)
            .background(.background)
            .clipShape(RoundedRectangle(cornerRadius: 22))

            sectionHeader("Featured pieces", action: "See all") {
                selectedTab = "Wardrobe"
            }
            HStack(spacing: 12) {
                clothingCard(name: "Classic jacket", detail: "Outerwear", icon: "jacket", color: Color(hex: "8D9B85"), price: "$48")
                clothingCard(name: "Everyday tee", detail: "Basics", icon: "tshirt", color: Color(hex: "D9BDA5"), price: "$18")
            }

            sectionHeader("Community picks", action: "Explore") {
                selectedTab = "Trade"
            }
            tradeRow(icon: "bag", title: "Canvas tote", subtitle: "Like new · Listed by Lina", price: "$12")
        }
    }

    private var wardrobeContent: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("My wardrobe")
                .font(.system(size: 29, weight: .bold, design: .rounded))
            Text("A sample collection to explore the wardrobe experience.")
                .foregroundStyle(.secondary)
            HStack(spacing: 8) {
                categoryPill("All", selected: true)
                categoryPill("Tops")
                categoryPill("Outerwear")
                categoryPill("Shoes")
            }
            HStack(spacing: 12) {
                clothingCard(name: "Classic jacket", detail: "Outerwear · Olive", icon: "jacket", color: Color(hex: "8D9B85"), price: "Owned")
                clothingCard(name: "Everyday tee", detail: "Top · Sand", icon: "tshirt", color: Color(hex: "D9BDA5"), price: "Owned")
            }
            HStack(spacing: 12) {
                clothingCard(name: "City sneakers", detail: "Shoes · White", icon: "shoe", color: Color(hex: "B9C9DF"), price: "Owned")
                clothingCard(name: "Denim jeans", detail: "Bottoms · Blue", icon: "jeans", color: Color(hex: "8EA9C9"), price: "Owned")
            }
            Button {
                selectedTab = "Discover"
            } label: {
                Label("Get an outfit idea", systemImage: "sparkles")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(hex: "5f9fff"))
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
        }
    }

    private var tradeContent: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Clothing exchange")
                .font(.system(size: 29, weight: .bold, design: .rounded))
            Text("Browse sample community listings. No payments or real listings are connected.")
                .foregroundStyle(.secondary)
            tradeRow(icon: "bag", title: "Canvas tote", subtitle: "Like new · Lina", price: "$12")
            tradeRow(icon: "shoe", title: "White sneakers", subtitle: "Good condition · Adam", price: "$28")
            tradeRow(icon: "tshirt", title: "Linen shirt", subtitle: "Worn twice · Sara", price: "$16")
            Label("Demo listings only", systemImage: "info.circle")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .padding(.top, 4)
        }
    }

    private var profileContent: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Your profile")
                .font(.system(size: 29, weight: .bold, design: .rounded))
            HStack(spacing: 14) {
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 58))
                    .foregroundStyle(Color(hex: "5f9fff"))
                VStack(alignment: .leading, spacing: 5) {
                    Text(UserDefaults.standard.string(forKey: "clothy.demo.currentUser") ?? "Clothy Demo")
                        .font(.headline)
                    Text("Offline demo account")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.background)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            VStack(spacing: 0) {
                profileRow("Saved outfits", value: "4", icon: "heart")
                Divider().padding(.leading, 48)
                profileRow("Wardrobe pieces", value: "12", icon: "tshirt")
                Divider().padding(.leading, 48)
                profileRow("Trade listings", value: "3", icon: "arrow.left.arrow.right")
            }
            .padding(.horizontal, 14)
            .background(.background)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            Button(role: .destructive) {
                UserDefaults.standard.removeObject(forKey: "session")
                withAnimation {
                    isLoggedIn = false
                    selectedTab = "Discover"
                }
            } label: {
                Label("Sign out of demo", systemImage: "rectangle.portrait.and.arrow.right")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.background)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
        }
    }

    private func tabItem(_ title: String, icon: String) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.18)) { selectedTab = title }
        } label: {
            VStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                Text(title)
                    .font(.caption2.weight(.medium))
            }
            .foregroundStyle(selectedTab == title ? Color(hex: "5f9fff") : Color.secondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }

    private func sectionHeader(
        _ title: String,
        action: String,
        onTap: @escaping () -> Void
    ) -> some View {
        HStack {
            Text(title).font(.headline)
            Spacer()
            Button(action, action: onTap)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color(hex: "5f9fff"))
        }
    }

    private func clothingCard(
        name: String,
        detail: String,
        icon: String,
        color: Color,
        price: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 9) {
            ZStack {
                RoundedRectangle(cornerRadius: 18)
                    .fill(color.opacity(0.22))
                Image(systemName: icon == "jacket" ? "jacket" : icon == "jeans" ? "figure.walk" : icon == "shoe" ? "shoe" : "tshirt")
                    .font(.system(size: 42, weight: .light))
                    .foregroundStyle(color)
            }
            .frame(height: 122)
            Text(name).font(.subheadline.weight(.semibold))
                .lineLimit(1)
            Text(detail).font(.caption).foregroundStyle(.secondary)
                .lineLimit(1)
            Text(price).font(.subheadline.weight(.bold))
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private func categoryPill(_ title: String, selected: Bool = false) -> some View {
        Text(title)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 12)
            .padding(.vertical, 9)
            .background(selected ? Color(hex: "5f9fff") : Color(uiColor: .secondarySystemGroupedBackground))
            .foregroundStyle(selected ? Color.white : Color.primary)
            .clipShape(Capsule())
    }

    private func tradeRow(icon: String, title: String, subtitle: String, price: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon == "shoe" ? "figure.walk" : icon == "tshirt" ? "tshirt" : "bag")
                .font(.system(size: 26))
                .foregroundStyle(Color(hex: "5f9fff"))
                .frame(width: 62, height: 62)
                .background(Color(hex: "5f9fff").opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 16))
            VStack(alignment: .leading, spacing: 5) {
                Text(title).font(.subheadline.weight(.semibold))
                Text(subtitle).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            Text(price).font(.subheadline.bold())
        }
        .padding(12)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private func profileRow(_ title: String, value: String, icon: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(Color(hex: "5f9fff"))
                .frame(width: 24)
            Text(title)
            Spacer()
            Text(value).fontWeight(.semibold).foregroundStyle(.secondary)
        }
        .padding(.vertical, 14)
    }

    // MARK: - Landing

    private var content: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Choose Your Outfit Wisely")
                .font(.headline).bold()
                .frame(width: 260, alignment: .leading)

            Text("Clothy can choose the right outfit for you with a simple press, also here you can trade your clothes safely.")
                .font(.body).bold()
                .opacity(0.7)
                .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()

            button.view()
                .frame(width: 236, height: 64)
                .overlay(
                    Label("Start with Clothy", systemImage: "arrow.forward")
                        .offset(x: 4, y: 4)
                        .font(.headline)
                )
                .background(
                    Color.black
                        .cornerRadius(30)
                        .blur(radius: 10)
                        .opacity(0.3)
                        .offset(y: 10)
                )
                .onTapGesture {
                    button.play(animationName: "active")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                        withAnimation(.spring()) { showsignin = true }
                    }
                }

            Text("©Haithem&mtar.")
                .font(.footnote)
                .opacity(0.7)
        }
        .padding(40)
        .padding(.top, 40)
    }

    private var background: some View {
        RiveViewModel(fileName: "shapes").view()
            .ignoresSafeArea()
            .blur(radius: 30)
            .background(
                Image("Spline")
                    .blur(radius: 50)
                    .offset(x: 200, y: 100)
            )
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
            ContentView()
                .preferredColorScheme(.dark)
                .previewDevice("iPhone 13 mini")
        }
    }
}
