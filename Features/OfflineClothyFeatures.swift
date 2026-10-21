import Foundation
import SwiftUI
import Combine
import PhotosUI
import UIKit

struct ClosetItem: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var name: String
    var category: String
    var color: String
    var season: String
    var occasion: String
    var notes: String
    var imageData: Data?
    var createdAt: Date = Date()
}

struct SavedOutfit: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var name: String
    var itemIDs: [UUID]
    var occasion: String
    var createdAt: Date = Date()
}

struct ClosetListing: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var itemID: UUID?
    var title: String
    var condition: String
    var price: String
    var notes: String
    var createdAt: Date = Date()
}

@MainActor
final class ClothyStore: ObservableObject {
    @Published private(set) var items: [ClosetItem] = []
    @Published private(set) var outfits: [SavedOutfit] = []
    @Published private(set) var listings: [ClosetListing] = []

    private let itemsKey = "clothy.offline.items.v1"
    private let outfitsKey = "clothy.offline.outfits.v1"
    private let listingsKey = "clothy.offline.listings.v1"

    init() {
        items = Self.load([ClosetItem].self, key: itemsKey, fallback: [])
        outfits = Self.load([SavedOutfit].self, key: outfitsKey, fallback: [])
        listings = Self.load([ClosetListing].self, key: listingsKey, fallback: [])
        if items.isEmpty && UserDefaults.standard.bool(forKey: "clothy.offline.seeded") == false {
            items = Self.sampleItems
            persist(items, key: itemsKey)
            UserDefaults.standard.set(true, forKey: "clothy.offline.seeded")
        }
    }

    private static func load<T: Decodable>(_ type: T.Type, key: String, fallback: T) -> T {
        guard let data = UserDefaults.standard.data(forKey: key),
              let value = try? JSONDecoder().decode(type, from: data) else { return fallback }
        return value
    }

    private func persist<T: Encodable>(_ value: T, key: String) {
        guard let data = try? JSONEncoder().encode(value) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }

    static let categories = ["Tops", "Bottoms", "Outerwear", "Shoes", "Accessories", "Dresses", "Other"]
    static let seasons = ["All season", "Spring", "Summer", "Autumn", "Winter"]
    static let occasions = ["Everyday", "Work", "Formal", "Sport", "Party", "Travel"]

    private static let sampleItems: [ClosetItem] = [
        ClosetItem(name: "Classic white tee", category: "Tops", color: "White", season: "Summer", occasion: "Everyday", notes: "A versatile basic"),
        ClosetItem(name: "Blue denim jeans", category: "Bottoms", color: "Blue", season: "All season", occasion: "Everyday", notes: ""),
        ClosetItem(name: "Olive jacket", category: "Outerwear", color: "Olive", season: "Autumn", occasion: "Everyday", notes: ""),
        ClosetItem(name: "White sneakers", category: "Shoes", color: "White", season: "All season", occasion: "Everyday", notes: ""),
        ClosetItem(name: "Black trousers", category: "Bottoms", color: "Black", season: "All season", occasion: "Work", notes: ""),
        ClosetItem(name: "Blue button-up", category: "Tops", color: "Blue", season: "Spring", occasion: "Work", notes: "")
    ]

    func addItem(_ item: ClosetItem) {
        items.insert(item, at: 0)
        persist(items, key: itemsKey)
    }

    func deleteItems(at offsets: IndexSet, from filteredItems: [ClosetItem]) {
        let ids = offsets.map { filteredItems[$0].id }
        items.removeAll { ids.contains($0.id) }
        persist(items, key: itemsKey)
        for index in listings.indices where listings[index].itemID.map(ids.contains) == true {
            listings[index].itemID = nil
        }
        persist(listings, key: listingsKey)
    }

    func updateItem(_ item: ClosetItem) {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[index] = item
        persist(items, key: itemsKey)
    }

    func deleteItem(id: UUID) {
        items.removeAll { $0.id == id }
        persist(items, key: itemsKey)
    }

    func saveOutfit(name: String, itemIDs: [UUID], occasion: String) {
        guard !itemIDs.isEmpty else { return }
        outfits.insert(SavedOutfit(name: name, itemIDs: itemIDs, occasion: occasion), at: 0)
        persist(outfits, key: outfitsKey)
    }

    func deleteOutfit(_ outfit: SavedOutfit) {
        outfits.removeAll { $0.id == outfit.id }
        persist(outfits, key: outfitsKey)
    }

    func addListing(item: ClosetItem, price: String, condition: String, notes: String) {
        listings.insert(ClosetListing(itemID: item.id, title: item.name, condition: condition, price: price, notes: notes), at: 0)
        persist(listings, key: listingsKey)
    }

    func addManualListing(title: String, price: String, condition: String, notes: String) {
        listings.insert(ClosetListing(title: title, condition: condition, price: price, notes: notes), at: 0)
        persist(listings, key: listingsKey)
    }

    func deleteListing(_ listing: ClosetListing) {
        listings.removeAll { $0.id == listing.id }
        persist(listings, key: listingsKey)
    }

    func item(for id: UUID) -> ClosetItem? { items.first { $0.id == id } }

    func outfitSuggestion(occasion: String, season: String) -> [ClosetItem] {
        let seasonal = items.filter { season == "All season" || $0.season == season || $0.season == "All season" }
        let seasonSource = seasonal.isEmpty ? items : seasonal
        let matching = seasonSource.filter { $0.occasion == occasion || $0.occasion == "Everyday" }
        let source = matching.isEmpty ? seasonSource : matching
        var chosen: [ClosetItem] = []
        for category in ["Tops", "Bottoms", "Dresses", "Outerwear", "Shoes", "Accessories"] {
            if let item = source.first(where: { $0.category == category }) { chosen.append(item) }
            if category == "Dresses", chosen.contains(where: { $0.category == "Dresses" }) {
                chosen.removeAll { $0.category == "Tops" || $0.category == "Bottoms" }
            }
        }
        return Array(chosen.prefix(4))
    }

    func clearAllLocalData() {
        items = []
        outfits = []
        listings = []
        persist(items, key: itemsKey)
        persist(outfits, key: outfitsKey)
        persist(listings, key: listingsKey)
    }
}

struct ClothingThumbnail: View {
    let item: ClosetItem
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16).fill(Color(hex: "5f9fff").opacity(0.12))
            if let data = item.imageData, let image = UIImage(data: data) {
                Image(uiImage: image).resizable().scaledToFill().clipShape(RoundedRectangle(cornerRadius: 16))
            } else {
                Image(systemName: Self.symbol(for: item.category))
                    .font(.system(size: 38, weight: .light))
                    .foregroundStyle(Color(hex: "5f9fff"))
            }
        }
        .frame(height: 116)
        .clipped()
    }

    static func symbol(for category: String) -> String {
        switch category {
        case "Tops": return "tshirt"
        case "Bottoms": return "figure.walk"
        case "Outerwear": return "jacket"
        case "Shoes": return "shoe"
        case "Accessories": return "bag"
        case "Dresses": return "hanger"
        default: return "tag"
        }
    }
}

struct AddClothingView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var store: ClothyStore
    var existingItem: ClosetItem? = nil
    @State private var name = ""
    @State private var category = "Tops"
    @State private var color = ""
    @State private var season = "All season"
    @State private var occasion = "Everyday"
    @State private var notes = ""
    @State private var imageData: Data?
    @State private var photoItem: PhotosPickerItem?
    @State private var validationMessage = ""

    init(store: ClothyStore, item: ClosetItem? = nil) {
        self.store = store
        self.existingItem = item
        _name = State(initialValue: item?.name ?? "")
        _category = State(initialValue: item?.category ?? "Tops")
        _color = State(initialValue: item?.color ?? "")
        _season = State(initialValue: item?.season ?? "All season")
        _occasion = State(initialValue: item?.occasion ?? "Everyday")
        _notes = State(initialValue: item?.notes ?? "")
        _imageData = State(initialValue: item?.imageData)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Photo") {
                    PhotosPicker(selection: $photoItem, matching: .images) {
                        HStack {
                            if let data = imageData, let image = UIImage(data: data) {
                                Image(uiImage: image).resizable().scaledToFill().frame(width: 68, height: 68).clipShape(RoundedRectangle(cornerRadius: 12))
                            } else {
                                Image(systemName: "camera.fill").font(.title2).frame(width: 68, height: 68).background(Color.blue.opacity(0.1)).clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            Text(imageData == nil ? "Choose a clothing photo" : "Change photo")
                        }
                    }
                    .onChange(of: photoItem) { newValue in
                        Task {
                            if let data = try? await newValue?.loadTransferable(type: Data.self) {
                                imageData = Self.optimizedImageData(data)
                            }
                        }
                    }
                }
                Section("Clothing details") {
                    TextField("Item name (required)", text: $name)
                    Picker("Category", selection: $category) { ForEach(ClothyStore.categories, id: \.self) { Text($0) } }
                    TextField("Color", text: $color)
                    Picker("Season", selection: $season) { ForEach(ClothyStore.seasons, id: \.self) { Text($0) } }
                    Picker("Occasion", selection: $occasion) { ForEach(ClothyStore.occasions, id: \.self) { Text($0) } }
                    TextField("Notes (optional)", text: $notes, axis: .vertical)
                }
                if !validationMessage.isEmpty {
                    Text(validationMessage).foregroundStyle(.red)
                }
            }
            .navigationTitle(existingItem == nil ? "Add to wardrobe" : "Edit clothing")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let cleanName = name.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !cleanName.isEmpty else { validationMessage = "Enter a name for this item."; return }
                        let item = ClosetItem(id: existingItem?.id ?? UUID(), name: cleanName, category: category, color: color.trimmingCharacters(in: .whitespacesAndNewlines), season: season, occasion: occasion, notes: notes, imageData: imageData, createdAt: existingItem?.createdAt ?? Date())
                        if existingItem == nil { store.addItem(item) } else { store.updateItem(item) }
                        dismiss()
                    }
                }
            }
        }
    }

    private static func optimizedImageData(_ data: Data) -> Data? {
        guard let image = UIImage(data: data) else { return data }
        let maxDimension: CGFloat = 1200
        let scale = min(1, maxDimension / max(image.size.width, image.size.height))
        let size = CGSize(width: image.size.width * scale, height: image.size.height * scale)
        let renderer = UIGraphicsImageRenderer(size: size)
        let resized = renderer.image { _ in image.draw(in: CGRect(origin: .zero, size: size)) }
        return resized.jpegData(compressionQuality: 0.78) ?? data
    }
}

struct OutfitGeneratorView: View {
    @ObservedObject var store: ClothyStore
    @State private var occasion = "Everyday"
    @State private var season = "All season"
    @State private var generated: [ClosetItem] = []
    @State private var showSavedMessage = false

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Outfit ideas").font(.system(size: 29, weight: .bold, design: .rounded))
            Text("Build combinations from your own wardrobe. Suggestions are generated locally; no AI service is required.")
                .foregroundStyle(.secondary)
            Picker("Occasion", selection: $occasion) {
                ForEach(ClothyStore.occasions, id: \.self) { Text($0) }
            }
            .pickerStyle(.menu)
            Picker("Season", selection: $season) {
                ForEach(ClothyStore.seasons, id: \.self) { Text($0) }
            }
            .pickerStyle(.menu)
            Button {
                generated = store.outfitSuggestion(occasion: occasion, season: season)
                showSavedMessage = false
            } label: {
                Label("Generate outfit", systemImage: "sparkles")
                    .font(.headline).frame(maxWidth: .infinity).padding()
                    .background(Color(hex: "5f9fff")).foregroundStyle(.white).clipShape(RoundedRectangle(cornerRadius: 16))
            }
            if generated.isEmpty {
                EmptyFeatureState(title: "Ready to style?", systemImage: "tshirt", message: "Choose an occasion and generate an outfit from your saved clothing items.")
                    .frame(maxWidth: .infinity, minHeight: 170)
            } else {
                VStack(spacing: 10) {
                    ForEach(generated) { item in
                        HStack(spacing: 12) {
                            ClothingThumbnail(item: item).frame(width: 76)
                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.name).font(.headline)
                                Text("\(item.category) · \(item.color.isEmpty ? "Color not set" : item.color)").font(.caption).foregroundStyle(.secondary)
                            }
                            Spacer()
                        }
                    }
                }
                Button {
                    store.saveOutfit(name: "\(occasion) look", itemIDs: generated.map(\.id), occasion: occasion)
                    showSavedMessage = true
                } label: {
                    Label("Save this outfit", systemImage: "heart.fill").frame(maxWidth: .infinity).padding()
                        .background(Color.pink.opacity(0.12)).foregroundStyle(.pink).clipShape(RoundedRectangle(cornerRadius: 14))
                }
                if showSavedMessage { Text("Outfit saved on this device.").font(.footnote).foregroundStyle(.secondary) }
            }
            Spacer(minLength: 0)
            Label("Offline limitation: this is rule-based matching, not an AI stylist. Weather-aware suggestions need live weather data.", systemImage: "info.circle")
                .font(.footnote).foregroundStyle(.secondary)
        }
    }
}

struct WardrobeView: View {
    @ObservedObject var store: ClothyStore
    @State private var searchText = ""
    @State private var category = "All"
    @State private var showingAdd = false
    @State private var itemToEdit: ClosetItem?

    private var filtered: [ClosetItem] {
        store.items.filter { item in
            (category == "All" || item.category == category) &&
            (searchText.isEmpty || item.name.localizedCaseInsensitiveContains(searchText) || item.color.localizedCaseInsensitiveContains(searchText) || item.notes.localizedCaseInsensitiveContains(searchText))
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("My wardrobe").font(.system(size: 29, weight: .bold, design: .rounded))
                    Text("\(store.items.count) items saved on this device").foregroundStyle(.secondary)
                }
                Spacer()
                Button { showingAdd = true } label: {
                    Image(systemName: "plus").font(.headline).foregroundStyle(.white).frame(width: 44, height: 44).background(Color(hex: "5f9fff")).clipShape(Circle())
                }
                .accessibilityLabel("Add clothing")
            }
            TextField("Search clothes or colors", text: $searchText)
                .textFieldStyle(.roundedBorder)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    categoryChip("All")
                    ForEach(ClothyStore.categories, id: \.self) { categoryChip($0) }
                }
            }
            if filtered.isEmpty {
                EmptyFeatureState(title: "No clothing found", systemImage: "tshirt", message: "Add an item or change your search.")
                    .frame(maxWidth: .infinity, minHeight: 200)
            } else {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                    ForEach(filtered) { item in
                        VStack(alignment: .leading, spacing: 7) {
                            ClothingThumbnail(item: item)
                            Text(item.name).font(.subheadline.weight(.semibold)).lineLimit(1)
                            Text([item.category, item.color].filter { !$0.isEmpty }.joined(separator: " · "))
                                .font(.caption).foregroundStyle(.secondary).lineLimit(1)
                            HStack {
                                Text(item.season).font(.caption2).foregroundStyle(.secondary)
                                Spacer()
                                Menu {
                                    Button { itemToEdit = item } label: { Label("Edit item", systemImage: "pencil") }
                                    Button(role: .destructive) { store.deleteItem(id: item.id) } label: { Label("Delete item", systemImage: "trash") }
                                } label: { Image(systemName: "ellipsis.circle").foregroundStyle(.secondary) }
                            }
                        }
                        .padding(10).background(.background).clipShape(RoundedRectangle(cornerRadius: 18))
                    }
                }
            }
            Spacer(minLength: 0)
        }
        .sheet(isPresented: $showingAdd) { AddClothingView(store: store) }
        .sheet(item: $itemToEdit) { item in AddClothingView(store: store, item: item) }
    }

    @ViewBuilder private func categoryChip(_ title: String) -> some View {
        Button { category = title } label: {
            Text(title).font(.caption.weight(.semibold)).padding(.horizontal, 13).padding(.vertical, 9)
                .background(category == title ? Color(hex: "5f9fff") : Color(uiColor: .secondarySystemGroupedBackground))
                .foregroundStyle(category == title ? Color.white : Color.primary).clipShape(Capsule())
        }
    }
}

struct SavedOutfitsView: View {
    @ObservedObject var store: ClothyStore
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Saved outfits").font(.system(size: 29, weight: .bold, design: .rounded))
            if store.outfits.isEmpty {
                EmptyFeatureState(title: "No saved outfits yet", systemImage: "heart", message: "Generate an outfit and save it to keep your favorite combinations here.")
            } else {
                ForEach(store.outfits) { outfit in
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            VStack(alignment: .leading, spacing: 3) {
                                Text(outfit.name).font(.headline)
                                Text("\(outfit.occasion) · \(outfit.itemIDs.count) pieces").font(.caption).foregroundStyle(.secondary)
                            }
                            Spacer()
                            Menu {
                                Button(role: .destructive) { store.deleteOutfit(outfit) } label: { Label("Delete outfit", systemImage: "trash") }
                            } label: { Image(systemName: "ellipsis.circle") }
                        }
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(outfit.itemIDs, id: \.self) { id in
                                    if let item = store.item(for: id) {
                                        VStack(alignment: .leading, spacing: 5) {
                                            ClothingThumbnail(item: item).frame(width: 112)
                                            Text(item.name).font(.caption).lineLimit(1).frame(width: 112, alignment: .leading)
                                        }
                                    }
                                }
                            }
                        }
                    }.padding(14).background(.background).clipShape(RoundedRectangle(cornerRadius: 18))
                }
            }
            Spacer(minLength: 0)
        }
    }
}

struct TradeView: View {
    @ObservedObject var store: ClothyStore
    @State private var showingCreate = false
    @State private var title = ""
    @State private var price = ""
    @State private var condition = "Good"
    @State private var notes = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Clothing exchange").font(.system(size: 29, weight: .bold, design: .rounded))
                    Text("Local listings saved only on this device").foregroundStyle(.secondary)
                }
                Spacer()
                Button { showingCreate = true } label: { Image(systemName: "plus").font(.headline).foregroundStyle(.white).frame(width: 44, height: 44).background(Color(hex: "5f9fff")).clipShape(Circle()) }
                    .accessibilityLabel("Create listing")
            }
            Label("Offline demo: listings are private to this device. Other users cannot see them and no messages, payments, or exchanges are processed.", systemImage: "info.circle")
                .font(.footnote).foregroundStyle(.secondary).padding(12).background(Color.blue.opacity(0.07)).clipShape(RoundedRectangle(cornerRadius: 12))
            if store.listings.isEmpty {
                EmptyFeatureState(title: "No listings yet", systemImage: "arrow.left.arrow.right", message: "Create a local listing to try the trading flow.")
            } else {
                ForEach(store.listings) { listing in
                    HStack(spacing: 12) {
                        if let id = listing.itemID, let item = store.item(for: id) {
                            ClothingThumbnail(item: item).frame(width: 76)
                        } else {
                            Image(systemName: "tag.fill").font(.title2).foregroundStyle(Color(hex: "5f9fff")).frame(width: 76, height: 76).background(Color.blue.opacity(0.1)).clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        VStack(alignment: .leading, spacing: 4) {
                            Text(listing.title).font(.headline)
                            Text("\(listing.condition) condition").font(.caption).foregroundStyle(.secondary)
                            if !listing.notes.isEmpty { Text(listing.notes).font(.caption).foregroundStyle(.secondary).lineLimit(2) }
                        }
                        Spacer()
                        VStack(alignment: .trailing) {
                            Text(listing.price.isEmpty ? "Price not set" : listing.price).font(.subheadline.bold())
                            Menu {
                                Button(role: .destructive) { store.deleteListing(listing) } label: { Label("Remove listing", systemImage: "trash") }
                            } label: { Image(systemName: "ellipsis") }
                        }
                    }.padding(12).background(.background).clipShape(RoundedRectangle(cornerRadius: 18))
                }
            }
            Spacer(minLength: 0)
        }
        .sheet(isPresented: $showingCreate) {
            NavigationStack {
                Form {
                    Section("Listing") {
                        TextField("Item name", text: $title)
                        TextField("Price (e.g. 25 TND)", text: $price)
                        Picker("Condition", selection: $condition) { ForEach(["New", "Like new", "Good", "Fair"], id: \.self) { Text($0) } }
                        TextField("Description (optional)", text: $notes, axis: .vertical)
                    }
                    Section {
                        Text("This creates a local sample listing only. It will not be published to a marketplace.")
                            .font(.footnote).foregroundStyle(.secondary)
                    }
                }
                .navigationTitle("New listing")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) { Button("Cancel") { showingCreate = false } }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            let clean = title.trimmingCharacters(in: .whitespacesAndNewlines)
                            guard !clean.isEmpty else { return }
                            store.addManualListing(title: clean, price: price, condition: condition, notes: notes)
                            title = ""; price = ""; notes = ""; condition = "Good"; showingCreate = false
                        }
                    }
                }
            }
        }
    }
}

struct ClothyProfileView: View {
    @ObservedObject var store: ClothyStore
    @State private var showingReset = false
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Your profile").font(.system(size: 29, weight: .bold, design: .rounded))
            HStack(spacing: 14) {
                Image(systemName: "person.crop.circle.fill").font(.system(size: 58)).foregroundStyle(Color(hex: "5f9fff"))
                VStack(alignment: .leading, spacing: 5) {
                    Text(UserDefaults.standard.string(forKey: "clothy.demo.currentUser") ?? "Clothy Demo").font(.headline)
                    Text("Offline account · Data stored on this device").font(.subheadline).foregroundStyle(.secondary)
                }
            }.padding(18).frame(maxWidth: .infinity, alignment: .leading).background(.background).clipShape(RoundedRectangle(cornerRadius: 20))
            HStack(spacing: 10) {
                statCard("Wardrobe", value: "\(store.items.count)", icon: "tshirt")
                statCard("Outfits", value: "\(store.outfits.count)", icon: "heart")
                statCard("Listings", value: "\(store.listings.count)", icon: "tag")
            }
            VStack(alignment: .leading, spacing: 12) {
                Label("Works offline", systemImage: "checkmark.circle.fill").foregroundStyle(.green)
                Text("Clothing, photos, outfit combinations and demo listings stay on this device. They are not synced or backed up to an account.")
                    .font(.subheadline).foregroundStyle(.secondary)
                Label("Not connected", systemImage: "wifi.slash").foregroundStyle(.orange)
                Text("Live weather, AI image recognition, social trading, chat, payments and cloud sync are not available in this offline build.")
                    .font(.subheadline).foregroundStyle(.secondary)
            }.padding(16).frame(maxWidth: .infinity, alignment: .leading).background(.background).clipShape(RoundedRectangle(cornerRadius: 18))
            Button(role: .destructive) { showingReset = true } label: {
                Label("Clear local wardrobe and data", systemImage: "trash").frame(maxWidth: .infinity).padding().background(.background).clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .confirmationDialog("Delete all local clothing, outfits and listings?", isPresented: $showingReset, titleVisibility: .visible) {
                Button("Delete local data", role: .destructive) { store.clearAllLocalData() }
            } message: { Text("This cannot be undone.") }
            Spacer(minLength: 0)
        }
    }

    private func statCard(_ title: String, value: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon).foregroundStyle(Color(hex: "5f9fff"))
            Text(value).font(.title2.bold())
            Text(title).font(.caption).foregroundStyle(.secondary)
        }.frame(maxWidth: .infinity, alignment: .leading).padding(12).background(.background).clipShape(RoundedRectangle(cornerRadius: 16))
    }
}


struct EmptyFeatureState: View {
    let title: String
    let systemImage: String
    let message: String

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: systemImage)
                .font(.system(size: 34))
                .foregroundStyle(Color(hex: "5f9fff"))
                .padding(.bottom, 4)
            Text(title).font(.headline)
            Text(message).font(.subheadline).foregroundStyle(.secondary).multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(24)
    }
}
