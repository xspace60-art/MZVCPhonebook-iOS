# Mizoram Village Council (MZ VC) Phonebook - iOS Application

Native iOS application for the **Mizoram Village Council Phonebook and Emergency Directory**.

Built with **SwiftUI** (iOS 16.0+), supporting 100% offline caching, real-time sync, multi-district switching, 1-tap phone calls, WhatsApp integration, and correction reporting.

---

## 📱 Features

- **Multi-District Selector**: Easily switch across all 11 Mizoram districts (Kolasib, Aizawl, Lunglei, Champhai, Mamit, Serchhip, Saitual, Khawzawl, Hnahthial, Lawngtlai, Siaha).
- **Executive Village Council Directory**:
  - Filter by Category (Town Area, Vairengte, Bilkhawthlir, Bairabi, Kawnpui, etc.)
  - Filter by Designation (VCP / President, VCVP, Secretary, Treasurer, Member, Worker)
  - Real-time search by name, village, designation, and phone number.
- **1-Tap Direct Actions**:
  - ⭐ **Favorites & Bookmarks**: 1-tap star bookmarking with persistent offline storage, dedicated quick-access scope selector, and cross-district saved favorites.
  - 📞 **Direct Call**: Instantly dials the phone number via iOS Phone app (`tel://`).
  - 💬 **WhatsApp**: Opens WhatsApp chat directly with a polite prefilled Mizo greeting (`whatsapp://`).
  - 📋 **Copy**: Copies number to clipboard with haptic feedback.
  - ⚠️ **Report Incorrect Info**: Submit wrong numbers, expired terms, or spelling mistakes directly to the District Administrator.
- **Village Councils Directory**: Browse all Village Councils in the district and tap to view executive committee members.
- **Government & District Offices**: Browse line departments, DC office, police, and collapsible staff directory cards.
- **Emergency Directory**: DC Office, Police, Hospitals, Ambulance, and Fire & Emergency lines with high-visibility calling.
- **District Announcements**: Live announcement banner and notification history modal.
- ⚡ **Real-Time Push Engine (SSE)**: Streams live directory updates, newly appointed members, and urgent broadcasts straight from Oracle Cloud without requiring manual pull-to-refresh.
- 100% Offline Access: Caches directory data locally on the iPhone so citizens can search and call even without an active internet connection.

---

## 🛠️ Project Structure

```
MZVCPhonebook-iOS/
├── .github/
│   └── workflows/
│       └── build-ios.yml              # Cloud macOS compiler & TestFlight uploader
├── TESTFLIGHT_DEPLOYMENT_GUIDE.md     # Automated TestFlight deployment instructions
├── MZVCPhonebook/
│   ├── App/
│   │   ├── MZVCPhonebookApp.swift     # Main @main App entry
│   │   └── Info.plist                 # ATS config & URL schemes
│   ├── Models/
│   │   ├── District.swift             # District data model
│   │   ├── Contact.swift              # VC Contact data model
│   │   ├── Village.swift              # Village Council data model
│   │   ├── Office.swift               # Government Office & Staff models
│   │   ├── EmergencyContact.swift     # Emergency service contact model
│   │   ├── BroadcastNotice.swift      # Announcement / Broadcast model
│   │   └── AppInfo.swift              # Developer info & report payload models
│   ├── Services/
│   │   ├── APIService.swift           # Async/await REST API networking
│   │   ├── RealtimeSyncService.swift  # Server-Sent Events (SSE) live push stream
│   │   ├── CacheManager.swift         # Local persistent JSON cache for offline use
│   │   └── PhonebookStore.swift       # ObservableObject state manager
│   ├── Views/
│   │   ├── MainTabView.swift          # Bottom TabView (VCs, Councils, Offices, Emergency, About)
│   │   ├── ContactsView.swift         # Primary search & directory screen
│   │   ├── ContactCardView.swift      # Card with Call, WhatsApp, Copy, Report
│   │   ├── CouncilsView.swift         # Councils directory
│   │   ├── OfficesView.swift          # Government offices & staff directory
│   │   ├── EmergencyView.swift        # Emergency directory
│   │   ├── AboutView.swift            # About & developer support
│   │   ├── DistrictPickerSheet.swift  # District switcher modal
│   │   ├── NotificationHistorySheet.swift # Notices modal
│   │   └── ReportCorrectionSheet.swift    # Report error form modal
│   └── Resources/
│       └── Assets.xcassets/           # App icon and theme accent colors
└── MZVCPhonebook.xcodeproj/           # Xcode project
```

---

## 💻 How to Build and Run on Windows (Without a Mac)

Since you are developing on Windows, here are the 3 ways to build and run this iOS app:

### Method 1: Free Cloud Build via GitHub Actions (Recommended)
1. Push this folder to a GitHub repository (e.g. `github.com/your-username/MZVCPhonebook-iOS`).
2. Go to the **Actions** tab in GitHub.
3. The included workflow (`.github/workflows/build-ios.yml`) will automatically run on a **free cloud macOS runner**, compile the Xcode project, and generate the iOS build archive.
4. Download the compiled build artifact from the Actions summary.

### Method 2: Instant PWA Testing on Physical iPhone (Zero Build Needed)
To test right now on your iPhone without any build tools:
1. Open Safari on your iPhone.
2. Navigate to your VC Phonebook portal.
3. Tap the **Share** button (box with an arrow pointing up at the bottom).
4. Tap **"Add to Home Screen"**.
5. It will install the **MZ VC Phonebook** icon directly to your iPhone home screen with standalone app mode and offline support!

### Method 3: Opening in Xcode (If you or a colleague have a Mac)
1. Copy the `MZVCPhonebook-iOS` folder to a Mac.
2. Double-click `MZVCPhonebook.xcodeproj` to open it in **Xcode**.
3. Select your iPhone or an iOS Simulator in the top toolbar.
4. Press `Cmd + R` to build and run.
