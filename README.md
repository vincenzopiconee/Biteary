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
- **In-Place Photo Preview & Native iOS Markup (`QLPreviewController`):** Tap any dish photo (or the top-bar Markup button) in `FoodView` to open `QuickLookImageEditor`, a `UIViewControllerRepresentable` wrapper around `QLPreviewController` configured with `.updateContents` editing mode. Drawings and annotations made with iOS Markup are read back via `previewController(_:didUpdateContentsOf:)` and dismissal synchronization, persisting directly into `food.imageData` in SwiftData.
- **Memory-Safe ImageIO Thumbnail Downsampling:** `ThumbnailDownsampler` uses `ImageIO` (`CGImageSourceCreateWithData` and `CGImageSourceCreateThumbnailAtIndex` with EXIF transform preservation and immediate caching) backed by a cost-bounded `NSCache` keyed by SHA-256 content digest and target pixel size. Grid tiles (`FoodContainer`), folder cover cards (`FolderButton`), and detail previews decode only the exact pixels required for the current display scale without inflating full-resolution camera JPEGs into memory.
- **Locale-Aware Currency Formatting:** Automatically formats dish prices according to the user's device locale (`Locale.current.currency`), falling back to `EUR`.

### Quick Look Trip Culinary Guide PDF Export
- **Paginated A4 Trip Guides (`595 × 842` pt):** Tap the **Preview Trip Guide PDF** button (`doc.richtext`) in `FolderView`'s toolbar to generate a styled, multi-page A4 Culinary Guide themed with the folder's adaptive `FolderColors` palette.
- **Trip Summary & Dish Cards:** Includes a branded hero header (trip title, formatted date range, dish count, average star rating, and locale-aware total trip spend) followed by a 2-column grid of dish cards with downsampled photos (or themed placeholders), restaurant/city metadata, formatted prices, 5-star visual ratings, dates, and tasting notes.
- **Native Quick Look Preview & Sharing:** Rendered via `@MainActor ImageRenderer` into `UIGraphicsPDFRenderer` with searchable vector text and presented using SwiftUI's `.quickLookPreview($previewPDFURL)` modifier for native pinch-to-zoom, Markup annotation, AirDrop, printing, and saving to Files.

### Modern iOS 18 UI, UX & Accessibility
- **Interactive Scroll Transitions:** Smooth `.scrollTransition` scale animations and `.viewAligned` scroll target behaviors across folder lists and 3-column dish grids (`LazyVGrid`).
- **Context Menus (Long-Press / 3D Touch):** Quick-access **Edit** and **Delete** actions with item-bound confirmation alerts directly from folder cards and dish tiles.
- **Animated Empty States:** Uses `ContentUnavailableView` paired with interactive SF Symbols `.symbolEffect(.wiggle)` animations when a collection or folder is empty.
- **Full Dark Mode & iOS 18 App Icons:** Includes Default, Dark, and Tinted app icon variants along with dark-mode-aware form and component surfaces.
- **VoiceOver Accessibility:** The custom 5-star `Rating` component implements `.accessibilityElement()`, descriptive labels/values, and `.accessibilityAdjustableAction`, while Quick Look PDF export and in-place photo Markup controls provide clear VoiceOver accessibility labels and hints.

---

## Tech Stack & Architecture

| Layer | Technology / API | Usage in Biteary |
| :--- | :--- | :--- |
| **UI Framework** | **SwiftUI** (iOS 18+) | Declarative views, `NavigationStack`, `LazyVStack`, `LazyVGrid`, `.searchable`, `.sheet`, `.fullScreenCover`, `.quickLookPreview`, `.scrollTransition`, `ContentUnavailableView`, `@MainActor ImageRenderer` |
| **Persistence** | **SwiftData** | Local on-device database using `@Model` entities (`Folder`, `Food`), reactive `@Query` fetching, `@Bindable` two-way editing, `#Predicate` filtering, and `SortDescriptor` ordering |
| **Document Preview & Markup** | **QuickLook / PDFKit** | SwiftUI `.quickLookPreview(_:)` for A4 trip PDF guides; `QLPreviewController` (`QLPreviewItemEditingMode.updateContents`) via `QuickLookImageEditor` for in-place dish photo Markup editing; `UIGraphicsPDFRenderer` for vector PDF output |
| **Media & Image Rendering** | **ImageIO / CryptoKit / UIKit** | Memory-safe downsampling via `CGImageSourceCreateThumbnailAtIndex` (`ThumbnailDownsampler`) with SHA-256 keyed `NSCache`; `UIViewControllerRepresentable` bridges (`ImagePicker`, `QuickLookImageEditor`) |
| **Automated Testing** | **Swift Testing** (`Testing`) | In-memory SwiftData (`ModelConfiguration(isStoredInMemoryOnly: true)`), `PDFKit` PDF validation (page count, A4 dimensions, vector text orientation), and `ImageIO` downsampling assertions |
| **Design & Assets** | **Xcode Asset Catalogs** | Custom folder color sets (`FolderColors`), Dark & Tinted iOS 18 app icons, background textures |

### Data Model (`SwiftData`)

Biteary uses a one-to-many persistent relationship between `Folder` and `Food` managed by SwiftData's `.modelContainer(for: Folder.self)`:

- **`Folder` (`@Model`)**
  - `id: UUID`
  - `name: String`
  - `startDate: Date` & `endDate: Date`
  - `color: String` (mapped to adaptive SwiftUI `Color` assets via `getFolderColor()` and `getFolderBackColor()`)
  - `foods: [Food]` (one-to-many collection of dishes in the folder)
  - `dateCreated: Date`
- **`Food` (`@Model`)**
  - `id: UUID`
  - `dishName: String`, `restaurantName: String`, `city: String`
  - `price: Double`, `rating: Int` (1–5), `notes: String`, `date: Date`
  - `imageData: [Data]?` (stores compressed JPEG data with helpers `addImage(_:)`, `deleteImage(at:)`, `getImages()`, `getFirstImage()`, and memory-safe `getThumbnail(maxPixelSize:)` / `getThumbnail(pointSize:scale:)`)

---

## Project Structure

```text
Biteary/
├── LICENSE
├── README.md
└── Biteary/
    ├── Biteary.xcodeproj/
    │   └── xcshareddata/xcschemes/Biteary.xcscheme
    ├── Biteary/
    │   ├── BitearyApp.swift                      # App entry point & SwiftData ModelContainer setup
    │   ├── Models/
    │   │   ├── Folder.swift                      # @Model definition for trip/collection folders & color helpers
    │   │   └── Food.swift                        # @Model definition for dish entries, JPEG Data & thumbnail helpers
    │   ├── Services/
    │   │   ├── ThumbnailDownsampler.swift        # Thread-safe ImageIO thumbnail downsampler & SHA-256 keyed NSCache
    │   │   └── TripPDFRenderer.swift             # @MainActor A4 PDF generator (UIGraphicsPDFRenderer + TripGuidePDFView)
    │   ├── Views/
    │   │   ├── ContentView.swift                 # Root NavigationStack, search bar, sort menu & add CTA
    │   │   ├── FolderListView.swift              # Dynamic @Query folder list with #Predicate search & context menus
    │   │   ├── FolderView.swift                  # 3-column LazyVGrid of dishes + Quick Look Trip Guide PDF export
    │   │   ├── FoodView.swift                    # Detailed dish view with Quick Look photo preview & live Markup editing
    │   │   ├── CreateFolderView.swift            # Form sheet to create a new folder with date & color pickers
    │   │   ├── EditFolderView.swift              # Form view to edit or delete an existing folder
    │   │   ├── CreateFoodView.swift              # Form sheet + ImagePicker to log a new dish with photo
    │   │   ├── EditFoodView.swift                # Form view to update dish details or replace its photo
    │   │   ├── ColorPickerView.swift             # Custom gradient circle color selectors for folder creation/editing
    │   │   ├── WelcomeScreenView.swift           # ContentUnavailableView empty state with SF Symbol wiggle effect
    │   │   ├── NavigationUtil.swift              # UIKit navigation helper to pop to root after folder deletion
    │   │   └── Components/
    │   │       ├── AddButton.swift               # Floating circular "+" action button
    │   │       ├── AddImage.swift                # Dark-mode-adaptive photo placeholder card
    │   │       ├── FolderButton.swift            # Styled folder card with layered gradient tabs & downsampled cover thumbnail
    │   │       ├── FoodContainer.swift           # Grid tile displaying downsampled dish thumbnail & title overlay
    │   │       ├── ImageContainer.swift          # Reusable rounded image preview container
    │   │       ├── QuickLookImageEditor.swift    # QLPreviewController wrapper supporting in-place iOS Markup (.updateContents)
    │   │       └── Rating.swift                  # Accessible 5-star interactive rating component
    │   └── Assets.xcassets/
    │       ├── AppIcon.appiconset/               # Light, Dark, and Tinted iOS 18 App Icons
    │       ├── FolderColors/                     # Adaptive color sets for 7 folder themes & UI surfaces
    │       └── TestImages/                       # Background textures & preview sample imagery
    └── BitearyTests/
        └── TripPDFAndThumbnailTests.swift        # Swift Testing suite for PDF generation, pagination & ImageIO downsampling
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
5. **Run Unit Tests:**
   - Press **`Cmd + U`** in Xcode, or run from the command line:
     ```bash
     xcodebuild test -project Biteary/Biteary.xcodeproj -scheme Biteary -destination 'platform=iOS Simulator,name=iPhone 16 Pro'
     ```

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

