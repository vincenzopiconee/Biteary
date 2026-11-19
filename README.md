# Biteary

**Biteary** is a native iOS travel food journal built with **SwiftUI** and **SwiftData** at the **Apple Developer Academy**. Designed for travelers and food enthusiasts, Biteary lets users organize their culinary memories into customizable trip folders and log detailed entries, complete with photos, ratings, prices, locations, and tasting notes, for every dish they try along the way.

---

## Key Features

### Trip & Collection Folders
- **Custom Trip Folders:** Group dishes by destination, vacation, or occasion with a custom title and validated start/end date ranges.
- **7 Curated Color Themes:** Personalize folders with custom gradient color palettes (*Orange, Blue, Red, Purple, Green, Yellow, Gray*) backed by adaptive light/dark asset catalogs.
- **Automatic Cover Previews:** Folders dynamically display a preview thumbnail from the first dish photo added to the collection.
- **Live Search & Multi-Criteria Sorting:** Filter folders in real time with case- and diacritic-insensitive SwiftData predicates (`localizedStandardContains`), and sort collections by **Newest**, **Oldest**, **Name**, or **Trip Start Date**.

### Dish Journaling & Media Capture
- **Comprehensive Dish Records:** Log the dish name, restaurant name, city, date, price, 1–5 star rating, and free-form tasting notes.
- **Camera & Photo Library Integration:** Capture photos directly with the device camera or import from the photo library via a custom `UIImagePickerController` bridge, automatically persisted in SwiftData with JPEG compression (`0.8` quality).
- **Locale-Aware Currency Formatting:** Automatically formats dish prices according to the user's device locale (`Locale.current.currency`), falling back to `EUR`.

### Modern iOS 18 UI, UX & Accessibility
- **Interactive Scroll Transitions:** Smooth `.scrollTransition` scale animations and `.viewAligned` scroll target behaviors across folder lists and 2-column dish grids (`LazyVGrid`).
- **Context Menus (Long-Press / 3D Touch):** Quick-access **Edit** and **Delete** actions with item-bound confirmation alerts directly from folder cards and dish tiles.
- **Animated Empty States:** Uses `ContentUnavailableView` paired with interactive SF Symbols `.symbolEffect(.wiggle)` animations when a collection or folder is empty.
- **Full Dark Mode & iOS 18 App Icons:** Includes Default, Dark, and Tinted app icon variants along with dark-mode-aware form and component surfaces.
- **VoiceOver Accessibility:** The custom 5-star `Rating` component implements `.accessibilityElement()`, descriptive labels/values, and `.accessibilityAdjustableAction` so VoiceOver users can increment or decrement ratings via swipe gestures.

---

## Tech Stack & Architecture

| Layer | Technology / API | Usage in Biteary |
| :--- | :--- | :--- |
| **UI Framework** | **SwiftUI** (iOS 18) | Declarative views, `NavigationStack`, `LazyVStack`, `LazyVGrid`, `.searchable`, `.sheet`, `.fullScreenCover`, `.scrollTransition`, `ContentUnavailableView` |
| **Persistence** | **SwiftData** | Local on-device database using `@Model` entities (`Folder`, `Food`), reactive `@Query` fetching, `@Bindable` two-way editing, `#Predicate` filtering, and `SortDescriptor` ordering |
| **Media & UIKit Interop** | **UIKit / PhotosUI** | `UIViewControllerRepresentable` wrapper (`ImagePicker`) bridging `UIImagePickerController` for `.camera` and `.photoLibrary` capture; binary `[Data]` persistence |
| **Design & Assets** | **Xcode Asset Catalogs** | Custom folder color sets (`FolderColors`), Dark & Tinted iOS 18 app icons, background textures |

### Data Model (`SwiftData`)

Biteary uses a one-to-many persistent relationship between `Folder` and `Food` managed by SwiftData's `.modelContainer(for: Folder.self)`:

- **`Folder` (`@Model`)**
  - `id: UUID`
  - `name: String`
  - `startDate: Date` & `endDate: Date`
  - `color: String` (mapped to adaptive SwiftUI `Color` assets)
  - `foods: [Food]` (one-to-many collection of dishes in the folder)
  - `dateCreated: Date`
- **`Food` (`@Model`)**
  - `id: UUID`
  - `dishName: String`, `restaurantName: String`, `city: String`
  - `price: Double`, `rating: Int` (1–5), `notes: String`, `date: Date`
  - `imageData: [Data]?` (stores compressed JPEG data with helper methods `addImage(_:)`, `deleteImage(at:)`, `getImages()`, and `getFirstImage()`)

---

## Project Structure

```text
Biteary/
├── README.md
└── Biteary/
    ├── Biteary.xcodeproj/
    └── Biteary/
        ├── BitearyApp.swift                 # App entry point & SwiftData ModelContainer setup
        ├── Models/
        │   ├── Folder.swift                 # @Model definition for trip/collection folders
        │   └── Food.swift                   # @Model definition for dish entries & JPEG Data helpers
        ├── Views/
        │   ├── ContentView.swift            # Root NavigationStack, search bar, sort menu & add CTA
        │   ├── FolderListView.swift         # Dynamic @Query folder list with #Predicate search & context menus
        │   ├── FolderView.swift             # 2-column LazyVGrid of dishes inside a selected folder
        │   ├── FoodView.swift               # Read-only detailed view of a recorded dish
        │   ├── CreateFolderView.swift       # Form sheet to create a new folder with date & color pickers
        │   ├── EditFolderView.swift         # Form view to edit or delete an existing folder
        │   ├── CreateFoodView.swift         # Form sheet + ImagePicker to log a new dish with photo
        │   ├── EditFoodView.swift           # Form view to update dish details or replace its photo
        │   ├── ColorPickerView.swift        # Custom gradient circle color selectors for folder creation/editing
        │   ├── WelcomeScreenView.swift      # ContentUnavailableView empty state with SF Symbol wiggle effect
        │   ├── NavigationUtil.swift         # UIKit navigation helper to pop to root after folder deletion
        │   └── Components/
        │       ├── AddButton.swift          # Floating circular "+" action button
        │       ├── AddImage.swift           # Dark-mode-adaptive photo placeholder card
        │       ├── FolderButton.swift       # Styled folder card with layered gradient tabs & dish thumbnail
        │       ├── FoodContainer.swift      # Grid tile displaying dish thumbnail and title overlay
        │       ├── ImageContainer.swift     # Reusable rounded image preview container
        │       └── Rating.swift             # Accessible 5-star interactive rating component
        └── Assets.xcassets/
            ├── AppIcon.appiconset/          # Light, Dark, and Tinted iOS 18 App Icons
            ├── FolderColors/                # Adaptive color sets for 7 folder themes & UI surfaces
            └── TestImages/                  # Background textures & preview sample imagery
```

---

## Getting Started

### Requirements
- **macOS** with **Xcode 16.0** or later
- **iOS 18.0+** deployment target (Simulator or physical iPhone)

### Installation & Running Locally
1. **Clone the repository:**
   ```bash
   git clone https://github.com/vincenzopiconee/Biteary.git
   cd Biteary
   ```
2. **Open the project in Xcode:**
   ```bash
   open Biteary/Biteary.xcodeproj
   ```
3. **Configure Code Signing (for physical devices):**
   - Select the **Biteary** project in the Xcode Project Navigator.
   - Open the **Signing & Capabilities** tab for the `Biteary` target.
   - Select your personal **Team** and update the **Bundle Identifier** if needed.
4. **Build and Run:**
   - Choose an iPhone Simulator (e.g., *iPhone 16 Pro*) or connected iPhone and press **`Cmd + R`**.

> **Note:** Taking a photo via the camera requires running on a physical iPhone (the iOS Simulator supports selecting images from the Photo Library).

---

## Developers

Developed at the **Apple Developer Academy** by:
- **Vincenzo Picone**
- **Rodrigo Llaguno**
- **Giulia Piscitelli**
- **Rezzan Tekinsen**
- **Mike Kostenko**

---

## License

This project is licensed under the **MIT License** — see the [LICENSE](LICENSE) file for details.

