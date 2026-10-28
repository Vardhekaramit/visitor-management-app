# 🏢 Visitor Management System (VMS)

An enterprise-grade, responsive Flutter application designed for corporate front-desk and security gatekeeper operations. Features digital VIP pass generation, contactless QR code check-in, real-time arrival metrics, and host clearance workflows.

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)](https://dart.dev)
[![Architecture](https://img.shields.io/badge/Architecture-MVVM-6366F1)]()
[![State Management](https://img.shields.io/badge/State-Provider-2563EB)]()
[![Tests](https://img.shields.io/badge/Tests-100%25%20Passing-10B981)]()

---

## 🌟 Key Features

- **Dashboard & Live Analytics**: Real-time counters for *Total Visitors Today*, *Currently Checked In*, and *Checked Out Today* with quick action shortcuts.
- **Digital VIP Pass**: Issues formatted QR-encoded passes (`VMS:{id}:{phone}`) with pass IDs and security audit status.
- **Contactless QR Scanner**: Integrated camera viewfinder with auto-detection, debouncing frame-lock, vibration haptics, flashlight torch, and camera flip.
- **Fast-Track Registration**: Responsive form with guest identity validation, category selection (`Customer`, `Vendor`, `Other`), destination routing, and instant gate clearance switch.
- **Visitor Directory**: Search across name and mobile, animated category filter chips, pull-to-refresh (`RefreshIndicator`), and swipe-to-delete with modal confirmation.
- **Visit Lifecycle Pipeline**: 3-node connected timeline (`Pre-Registered` ➔ `Checked In` ➔ `Checked Out`) with timestamp audit trail.
- **Responsive & Adaptive**: Material 3 `NavigationRail` for tablets (>=640dp) and `NavigationBar` for mobile phones (<640dp); adaptive 2-column forms and split-view passes.
- **Design System (`AppColors`)**: Centralized semantic palette supporting dynamic Light and Dark mode.

---

## 📐 Architecture: MVVM with Provider

This project strictly follows the **Model-View-ViewModel (MVVM)** pattern powered by `provider`:

```
┌────────────────────────────────────────────────────────┐
│                      VIEW (UI)                         │
│  - MainShell (Adaptive NavigationBar / NavigationRail) │
│  - DashboardScreen                                     │
│  - VisitorListScreen (Search & Filter)                 │
│  - VisitorFormScreen (Adaptive 1-col / 2-col)          │
│  - VisitorDetailsScreen (Digital Pass & Timeline)      │
│  - QrScannerScreen                                     │
└──────────────────────────┬─────────────────────────────┘
                           │ context.watch<VisitorViewModel>()
                           │ context.read<VisitorViewModel>()
                           ▼
┌────────────────────────────────────────────────────────┐
│                   VIEWMODEL (State)                    │
│                 VisitorViewModel                       │
│  - Holds UI state and filters                          │
│  - Calculates live metrics                             │
│  - Calls notifyListeners() on state mutation           │
└──────────────────────────┬─────────────────────────────┘
                           │ Async REST operations
                           ▼
┌────────────────────────────────────────────────────────┐
│                  SERVICE (Mock API)                    │
│                 VisitorApiService                      │
│  - GET, POST, PUT, PATCH, DELETE                       │
│  - Simulates 250ms network delay & JSON serialization  │
└──────────────────────────┬─────────────────────────────┘
                           │ Serializes / Deserializes
                           ▼
┌────────────────────────────────────────────────────────┐
│                   MODEL (Entity)                       │
│  - Visitor (id, name, phone, email, purpose, etc.)     │
│  - VisitorStatus (registered, checkedIn, checkedOut)   │
└────────────────────────────────────────────────────────┘
```

> **Clean Architecture Decision**: To avoid anemic abstractions, `VisitorViewModel` communicates directly with `VisitorApiService`, eliminating unnecessary multi-layer repository wrappers while retaining complete unit testability via dependency injection.

---

## 🌐 Mock REST API Interface

The service layer (`VisitorApiService`) implements a full RESTful interface with 250ms simulated network latency, HTTP error handling, and JSON serialization:

| HTTP Method | Endpoint | Description |
|:---|:---|:---|
| `GET` | `/visitors` | Retrieve all visitor records |
| `GET` | `/visitors/:id` | Retrieve single visitor details |
| `POST` | `/visitors` | Register new visitor and generate Pass ID |
| `PUT` | `/visitors/:id` | Update visitor details |
| `PATCH` | `/visitors/:id/status` | Transition status (`registered` ➔ `checkedIn` ➔ `checkedOut`) |
| `DELETE` | `/visitors/:id` | Remove visitor record |

---

## 📱 Responsive & Adaptive Breakpoints

Layouts dynamically adapt based on device screen width:

| Device Type | Breakpoint | Navigation Pattern | Form / Details Layout |
|:---|:---|:---|:---|
| **Mobile** | `< 640 dp` | Bottom `NavigationBar` | 1-Column vertical scroll |
| **Tablet / Desktop** | `>= 640 dp` | Lateral `NavigationRail` | 2-Column split-view & side-by-side inputs |

---

## 📁 Project Structure

```
lib/
├── main.dart                  # Application entry point & Provider registration
├── models/
│   └── visitor.dart           # Domain entity, VisitorStatus enum & JSON serialization
├── screens/
│   ├── main_shell.dart        # Adaptive shell (NavigationRail / NavigationBar)
│   ├── dashboard_screen.dart  # Metrics, hero banner, quick actions & recent feed
│   ├── visitor_list_screen.dart # Search, status filter chips, pull-to-refresh
│   ├── visitor_form_screen.dart # Adaptive 2-column registration & edit form
│   ├── visitor_details_screen.dart # Digital VIP Pass with QR & timeline
│   └── qr_scanner_screen.dart # Viewfinder, torch toggle, haptics & detection
├── services/
│   └── visitor_service.dart   # Mock REST API service with JSON serialization
├── theme/
│   ├── app_colors.dart        # Centralized color tokens
│   └── app_theme.dart         # Material 3 light & dark theme definitions
├── utils/
│   ├── formatters.dart        # Date and time formatting utilities
│   ├── navigation.dart        # Type-safe routing helpers
│   └── responsive.dart        # Screen breakpoints & adaptive layout helpers
├── viewmodels/
│   └── visitor_viewmodel.dart # Central ChangeNotifier managing state & API calls
└── widgets/
    ├── custom_text_field.dart # Standardized text input decoration
    ├── dashboard_stat_card.dart # Clean metric statistic card
    ├── empty_state_widget.dart # Placeholder for empty filters or lists
    ├── info_pill.dart         # Compact icon and text badge
    ├── status_badge_chip.dart # Status chip with glowing indicator dot
    └── visitor_card.dart      # Summary visitor card with actions
```

---

## 🚀 Setup & Installation Instructions

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (version 3.35.0 or higher)
- [Dart SDK](https://dart.dev/get-dart) (version 3.9.0 or higher)
- Android Studio / VS Code with Flutter extension

### Steps to Run:
1. **Clone the repository**:
   ```bash
   git clone https://github.com/YOUR_USERNAME/visitor_management_app.git
   cd visitor_management_app
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Verify static analysis**:
   ```bash
   flutter analyze
   ```

4. **Run the automated test suite**:
   ```bash
   flutter test
   ```

5. **Run the app**:
   ```bash
   flutter run
   ```

6. **Build Release APK (Optional)**:
   ```bash
   flutter build apk --release
   ```
