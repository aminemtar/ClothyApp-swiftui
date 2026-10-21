# ClothyApp SwiftUI — Offline Demo

This branch is a **local-only demo** of Clothy. It does not require your backend, API key, or network API calls. The Xcode project resolves the Rive Swift package dependency when you first open the project, so internet access may be needed for that initial package download.

## Open and run the app

1. Check out this branch:
   `git fetch origin`
   `git checkout feature/offline-static-demo`
2. Open **`ClothyApp.xcodeproj`** in Xcode (open the project file, not the GitHub page or repository folder).
3. Wait for Xcode to resolve the `RiveRuntime` Swift package.
4. In the top toolbar, choose the **ClothyApp** scheme and an iPhone Simulator (for example, iPhone 16).
5. Click the triangular **Run ▶** button, or choose **Product → Run** (⌘R).

If you do not see the Run button, make sure the `.xcodeproj` is open in Xcode rather than the folder in VS Code/Finder. If package resolution fails, choose **File → Packages → Resolve Package Versions**.

## Demo sign-in

- **Email:** `demo@clothy.app`
- **Password:** `Clothy123`

You can also create a local demo account through **Sign Up**. Accounts are stored on the device in `UserDefaults` and are only intended for exploring the prototype.

## What you can explore

- **Discover:** sample outfit inspiration and featured pieces.
- **Wardrobe:** example clothing categories and sample items.
- **Trade:** sample listings for a clothing-exchange experience.
- **Profile:** mock profile statistics and sign-out.
- **Authentication:** local sign-in, sign-up, and password-reset flow.

## Password reset

For the local demo, use reset code `123456`. This code is intentionally fixed and is not sent by email.

## Important limitations

All clothing listings, outfit suggestions, prices, and profile statistics are static sample data. Sign-in and password reset are simulated locally. No real account is created, no email is sent, and no trading, payment, weather, image recognition, or backend service is connected.

This branch is intended for UI/feature exploration only. The production/API implementation on `main` is not modified by this branch.
