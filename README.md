# ClothyApp SwiftUI — Offline-first demo

Clothy is a wardrobe and outfit-planning app. This branch brings the main app experience into a native SwiftUI project that can be explored without a backend, API key, or network connection. It has no third-party package dependencies.

## Open and run

1. Fetch and check out this branch:
   `git fetch origin`
   `git checkout feature/offline-static-demo`
2. Open **ClothyApp.xcodeproj** in Xcode.
3. Select the **ClothyApp** scheme and an iPhone or iPhone Simulator.
4. Press **Run** (⌘R).

The project targets iOS 16 or later.

## Demo sign-in

- **Email:** `demo@clothy.app`
- **Password:** `Clothy123`

You can also create a local demo account through Sign Up. Accounts are stored locally in `UserDefaults`; they are for prototype exploration and are not secure production authentication.

## Implemented offline features

- **Discover:** entry points to wardrobe, outfit creation, and exchange listings.
- **Wardrobe:** add clothing items, attach photos from the photo library, categorize and tag by color, season and occasion, search items, edit details, and delete items.
- **Outfit ideas:** generate rule-based combinations from saved items by occasion and season, then save favorite combinations.
- **Saved outfits:** view outfit combinations and their pieces, and remove saved outfits.
- **Clothing exchange demo:** create and remove local listings with price, condition and description.
- **Profile:** local wardrobe/outfit/listing counts and a clear-local-data action.
- **Authentication UI:** local sign-in, sign-up and password-reset flow.
- **Persistence:** clothing, photo data, outfits and demo listings are saved on the device and remain available after restarting the app.

Sample wardrobe items are seeded on first launch so the app is not empty. Add, edit through deleting/re-adding, or remove items to explore your own collection.

## Password reset

For this local demo, use reset code `123456`. The code is fixed and is not sent by email.

## What is not connected

This is a deliberately offline-first demo, not a production marketplace:

- **Live weather:** no network weather service is called. Outfit ideas can be filtered by a manually selected season instead.
- **Automatic clothing recognition:** photos are saved, but a computer-vision model does not automatically identify garment type, color, or attributes. Categorization is manual.
- **Real AI stylist:** outfit combinations use local category/occasion/season rules, not a generative AI model.
- **Real community trading:** listings are private to the device. Other users cannot discover them; chat, exchange requests, payment and delivery are not implemented.
- **Cloud accounts and sync:** login and password recovery are simulated locally. No email is sent, and local accounts are not synced or backed up.
- **Production security:** local demo credentials are not suitable for real user accounts.

The branch is intended to make the app's main flows testable without a backend. It does not modify `main`.
