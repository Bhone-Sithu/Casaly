# CLAUDE.md — Casaly

## Project Overview

Casaly (from "casa" — home in Spanish/Italian/Portuguese) is a shared-living coordination platform that replaces the need for a "house leader" by making shared responsibilities visible and accountable through passive transparency.

**Core insight**: Shared living coordination fails because it depends on one person managing everything. When visibility is passive and persistent, accountability emerges naturally without anyone needing to play leader.

**Long-term vision**: Start as a dorm/shared-house utility tool → grow into a student living platform with community, events, and local business partnerships (restaurants, services). Revenue comes from local businesses paying to reach the student user base.

## Core Principles

1. **Clean code from day one** — Maintainability is not optional. Proper architecture, design tokens, abstractions, and testing. No "fix later" debt.
2. **Passive accountability over active confrontation** — The app makes responsibility visible so the group self-governs without needing a leader.
3. **Push information where users already live** — Notifications are the trigger; the app is the system of record.
4. **Security ships with v1** — Firestore rules and GDPR compliance are non-negotiable before launch.

## Tech Stack

- **Frontend**: Flutter (cross-platform, iOS + Android)
- **Backend**: Firebase
  - **Database**: Cloud Firestore (document model, real-time sync)
  - **Auth**: Firebase Authentication
  - **Notifications**: Firebase Cloud Messaging (FCM)
  - **Functions**: Cloud Functions for scheduled reminders
  - **Storage**: Firebase Storage (profile images, cleaning verification photos)
- **State Management**: Riverpod (type-safe, testable, scalable)
- **Architecture**: Clean Architecture with Repository pattern

---

## 📊 Current Implementation Status (Updated: March 23, 2026)

### ✅ Completed Features

#### 🏗️ **Core Architecture (100%)**
- ✅ Clean Architecture implemented across all features
- ✅ Feature-first folder structure with domain/data/presentation layers
- ✅ Riverpod state management with proper providers
- ✅ Either pattern for error handling with `dartz`
- ✅ Repository pattern with abstract interfaces
- ✅ Firebase integration with proper error handling
- ✅ 91 Dart files following established patterns

#### 🎨 **Design System (95%)**
- ✅ "Botanical Archivist" theme implemented (evolved from "Summer Garden")
- ✅ Complete design token system (`AppColors`, `AppSpacing`, `AppRadius`, `AppTypography`)
- ✅ Glass morphism UI components
- ✅ Consistent warm paper surface hierarchy
- ✅ Reusable widgets (`CasalyButton`, `CasalyTextField`, `GlassContainer`, etc.)
- ⚠️ Some legacy color references remain for migration

#### 🔐 **Authentication (100%)**
- ✅ Firebase Auth integration
- ✅ Email/password authentication
- ✅ Google Sign-In integration
- ✅ Auth state management with providers
- ✅ Protected route navigation

#### 🏠 **Dorm Management (100%)**
- ✅ Create dorm functionality
- ✅ Join dorm by invite code (6-character alphanumeric)
- ✅ Dorm member management
- ✅ Admin/member roles
- ✅ Real-time dorm status updates
- ✅ Fixed: Proper redirect to dashboard after join/create

#### 💬 **Chat System (100%)**
- ✅ Real-time messaging with Firestore
- ✅ Single automatic chat room per dorm
- ✅ WhatsApp-style message bubbles
- ✅ Message read indicators
- ✅ Proper message pagination and scrolling
- ✅ Fixed: Firebase composite index issues resolved

#### 🧹 **Cleaning Schedule (90%)**
- ✅ Weekly cleaning rotation system
- ✅ Calendar view with assignment history
- ✅ Cleaning groups management
- ✅ Mark cleaning as done/missed
- ✅ Visual compliance tracking
- ❌ Swap functionality (deferred)
- ❌ Photo verification (V2)

#### 🧺 **Laundry Management (85%)**
- ✅ Multiple washing machine support
- ✅ Timer functionality with real-time updates
- ✅ Machine availability tracking
- ✅ Visual status indicators
- ❌ Push notifications for timer completion (pending FCM setup)
- ❌ Follow-up reminders

#### 🔄 **Navigation & Routing (100%)**
- ✅ Go Router implementation
- ✅ Smart authentication-based routing
- ✅ Bottom navigation with glass morphism
- ✅ Proper state persistence
- ✅ Fixed: Dorm join redirect issues

### 🚧 In Progress / Pending

#### 📱 **Push Notifications (0%)**
- ❌ FCM setup and configuration
- ❌ Cleaning reminder notifications
- ❌ Laundry timer completion alerts
- ❌ Firebase Cloud Functions for scheduled reminders

#### 🔒 **Security & Compliance (30%)**
- ✅ Basic Firebase connection security
- ❌ Comprehensive Firestore security rules
- ❌ GDPR compliance implementation
- ❌ User data deletion capabilities

#### 📋 **Shopping List (0%)**
- ❌ Real-time shopping list (V2 feature)
- ❌ Item management
- ❌ Purchase tracking

### 📊 **Code Quality Metrics**
- **Total Files**: 91 Dart files
- **Architecture Compliance**: 100%
- **Error Handling**: 95% (Either pattern throughout)
- **State Management**: 100% (Riverpod providers)
- **TODOs/FIXMEs**: 50 items identified (mostly UI polish)
- **Firebase Integration**: 90% (missing FCM and security rules)

### 🎯 **MVP Readiness Assessment**

| Feature | Status | Completion |
|---------|--------|------------|
| Authentication | ✅ Complete | 100% |
| Dorm Management | ✅ Complete | 100% |
| Cleaning Schedule | 🔶 Core Done | 90% |
| Chat System | ✅ Complete | 100% |
| Laundry Timer | 🔶 Core Done | 85% |
| Push Notifications | ❌ Missing | 0% |
| Security Rules | 🔶 Basic | 30% |

**Overall MVP Status: 85% Complete**

### 🚀 **Next Priority Tasks for MVP**

1. **Firebase Cloud Messaging Setup** - Enable push notifications
2. **Firestore Security Rules** - Implement comprehensive access control
3. **Laundry Timer Notifications** - Complete notification integration
4. **Cleaning Reminder Notifications** - Weekly automated reminders
5. **Code Cleanup** - Address remaining TODO items
6. **Testing & QA** - End-to-end testing of all features

### 🔧 **Technical Debt & Improvements**

1. **Legacy Color Migration**: Complete migration from "Summer Garden" to "Botanical Archivist"
2. **Unused Code Cleanup**: Remove unused methods flagged by analyzer
3. **Error Handling Polish**: Improve user-facing error messages
4. **Performance Optimization**: Implement proper loading states
5. **Accessibility**: Add proper accessibility labels and navigation

### 📱 **Platform Status**
- **iOS**: ✅ Configured with Firebase
- **Android**: ✅ Configured with Firebase
- **Web**: 🔶 Basic setup (not primary target)

---

## Architecture & Code Quality

### Folder Structure (Feature-First)

```
lib/
├── app/
│   ├── app.dart                    # MaterialApp, router, theme
│   ├── router.dart                 # GoRouter configuration
│   └── providers.dart              # Global providers
├── core/
│   ├── theme/
│   │   ├── app_theme.dart          # ThemeData builder
│   │   ├── app_colors.dart         # Design token colors (single source of truth)
│   │   ├── app_typography.dart     # Text styles
│   │   ├── app_spacing.dart        # Spacing constants
│   │   └── app_radius.dart         # Border radius constants
│   ├── constants/
│   │   └── firestore_paths.dart    # Collection/doc path constants
│   ├── errors/
│   │   ├── failures.dart           # Failure classes
│   │   └── exceptions.dart         # Exception classes
│   ├── utils/
│   │   ├── date_utils.dart
│   │   └── validators.dart
│   └── widgets/                    # Shared reusable widgets
│       ├── casaly_card.dart
│       ├── casaly_button.dart
│       ├── status_badge.dart
│       └── loading_indicator.dart
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── repositories/       # Firebase implementations
│   │   │   └── models/             # Data transfer objects
│   │   ├── domain/
│   │   │   ├── repositories/       # Abstract interfaces
│   │   │   └── entities/           # Domain models
│   │   └── presentation/
│   │       ├── providers/          # Riverpod providers
│   │       ├── screens/
│   │       └── widgets/
│   ├── dorm/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── cleaning/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── washer/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   └── home/
│       └── presentation/           # Home screen assembling feature widgets
└── main.dart
```

### Architecture Rules

1. **Domain layer has ZERO dependencies** on Flutter, Firebase, or any package. Pure Dart only.
2. **Data layer** implements domain interfaces. All Firebase calls live here and nowhere else.
3. **Presentation layer** depends on domain, never on data directly.
4. **Providers** bridge presentation and domain. Screens never call repositories directly.
5. **Every repository has an abstract interface** in domain/ and a Firebase implementation in data/.
6. **No magic strings** — Firestore collection paths, error messages, and asset paths are constants.
7. **Models vs Entities** — Models (data/) handle JSON serialization. Entities (domain/) are clean domain objects. Map between them at the repository boundary.

### Naming Conventions

- Files: `snake_case.dart`
- Classes: `PascalCase`
- Variables/functions: `camelCase`
- Constants: `camelCase` (Dart convention, not SCREAMING_CASE)
- Private members: `_prefixed`
- Providers: `descriptiveNameProvider` (e.g., `cleaningScheduleProvider`)
- Repositories: `ICleaningRepository` (interface), `FirebaseCleaningRepository` (implementation)

### Code Style Rules

- Max 80 characters per line
- Prefer `const` constructors everywhere possible
- Use `final` for all variables that don't need reassignment
- No `dynamic` types — everything explicitly typed
- Prefer named parameters for functions with 2+ parameters
- Use `sealed` classes for state management (Dart 3)
- Use `freezed` or manual `copyWith` for immutable data classes
- Comments explain "why", not "what" — the code should explain "what"
- Every public API has a dartdoc comment

### Error Handling

- Use `Either<Failure, T>` pattern (from `dartz` or `fpdart`) or sealed Result classes
- Never let exceptions propagate to UI — catch at repository boundary
- User-facing error messages are friendly, not technical
- Log technical details for debugging

---

## Design System — "Botanical Archivist" Theme (Current Implementation)

**Design philosophy**: Editorial-inspired design system with warm paper surfaces. Like a botanical journal or natural history archive — sophisticated, organized, yet warm and inviting. The interface feels like working with high-quality paper documents, with proper hierarchy and thoughtful spacing.

**Previous "Summer Garden" concept evolved into this more refined approach for better user experience and accessibility.**

### Design Tokens (Single Source of Truth)

All colors, spacing, typography, and radii are defined ONCE in `core/theme/` and referenced everywhere else. Never hardcode hex values in widgets.

#### Colors — `app_colors.dart` (Current Implementation)

```dart
abstract class AppColors {
  // === THE BOTANICAL ARCHIVIST PALETTE ===
  
  // === PRIMARY — Deep Forest Green ===
  static const primary = Color(0xFF245030);  // Deep forest green for brand
  static const primaryContainer = Color(0xFFBDEFC3);  // Light green container
  static const onPrimary = Color(0xFFFFFFFF);  // White text on primary
  static const onPrimaryContainer = Color(0xFF234F30);  // Dark green text

  // === SECONDARY — Sunset Orange ===
  static const secondary = Color(0xFFE8884A);  // Warm orange for active states
  static const secondaryContainer = Color(0xFFFFDBC9);  // Light orange container
  static const onSecondary = Color(0xFFFFFFFF);  // White text on orange

  // === TERTIARY — Deep Berry ===
  static const tertiary = Color(0xFFD04848);  // Alert red for warnings
  static const tertiaryContainer = Color(0xFFFFDADA);  // Light red container
  static const onTertiary = Color(0xFFFFFFFF);  // White text on red

  // === SURFACE HIERARCHY — The "Warm Paper" System ===
  static const surface = Color(0xFFFFF8F4);  // Warm paper base
  static const surfaceContainerLowest = Color(0xFFFFFFFF);  // Pure white highlights
  static const surfaceContainerLow = Color(0xFFF9F2EE);  // Structural blocks
  static const surfaceContainer = Color(0xFFF3EDE9);  // Mid-level grouping
  static const surfaceContainerHigh = Color(0xFFEEE7E3);  // Input fields
  static const surfaceContainerHighest = Color(0xFFE8E1DD);  // Interactive elements

  // === TEXT & OUTLINES ===
  static const onSurface = Color(0xFF1D1B19);  // Main text
  static const onSurfaceVariant = Color(0xFF4F4539);  // Secondary text
  static const outline = Color(0xFF80736A);  // Subtle outlines
  static const outlineVariant = Color(0xFFC1C9BF);  // Ghost borders

  // === SEMANTIC MAPPINGS ===
  static const success = primaryContainer;  // Completed tasks
  static const warning = secondaryContainer;  // Attention needed
  static const error = tertiary;  // High-priority warnings
  static const info = secondary;  // General information
}
```

#### Spacing — `app_spacing.dart`

```dart
abstract class AppSpacing {
  static const xs   = 4.0;
  static const sm   = 8.0;
  static const md   = 12.0;
  static const lg   = 16.0;
  static const xl   = 20.0;
  static const xxl  = 24.0;
  static const xxxl = 32.0;

  // Semantic spacing
  static const cardPadding     = 16.0;
  static const cardGap         = 8.0;
  static const screenPadding   = 20.0;
  static const sectionGap      = 24.0;
}
```

#### Border Radius — `app_radius.dart`

```dart
abstract class AppRadius {
  static const sm  = 8.0;   // Badges, small chips
  static const md  = 12.0;  // Cards, buttons, inputs
  static const lg  = 16.0;  // Hero cards, modals
  static const xl  = 24.0;  // Screen containers, bottom sheets
  static const pill = 999.0; // Fully rounded pills

  // Semantic
  static const card   = md;
  static const button = md;
  static const input  = md;
  static const badge  = sm;
  static const sheet  = xl;
}
```

#### Typography — `app_typography.dart`

```dart
abstract class AppTypography {
  static const _fontFamily = 'Inter'; // Or your chosen font

  // Headings
  static const h1 = TextStyle(fontSize: 24, fontWeight: FontWeight.w600, fontFamily: _fontFamily);
  static const h2 = TextStyle(fontSize: 20, fontWeight: FontWeight.w600, fontFamily: _fontFamily);
  static const h3 = TextStyle(fontSize: 16, fontWeight: FontWeight.w600, fontFamily: _fontFamily);

  // Body
  static const bodyLg  = TextStyle(fontSize: 16, fontWeight: FontWeight.w400, fontFamily: _fontFamily);
  static const bodyMd  = TextStyle(fontSize: 14, fontWeight: FontWeight.w400, fontFamily: _fontFamily);
  static const bodySm  = TextStyle(fontSize: 12, fontWeight: FontWeight.w400, fontFamily: _fontFamily);

  // Labels
  static const labelLg = TextStyle(fontSize: 14, fontWeight: FontWeight.w500, fontFamily: _fontFamily);
  static const labelMd = TextStyle(fontSize: 12, fontWeight: FontWeight.w500, fontFamily: _fontFamily);
  static const labelSm = TextStyle(fontSize: 10, fontWeight: FontWeight.w500, fontFamily: _fontFamily);

  // Caption
  static const caption = TextStyle(fontSize: 11, fontWeight: FontWeight.w400, fontFamily: _fontFamily);
}
```

#### Theme Builder — `app_theme.dart`

```dart
class AppTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.cream50,
    colorScheme: ColorScheme.light(
      primary: AppColors.green400,
      secondary: AppColors.orange400,
      surface: AppColors.cream50,
      error: AppColors.berry400,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: AppColors.cream800,
      onError: Colors.white,
    ),
    // Card, AppBar, BottomNav, Input, Button themes all reference AppColors
    // Never hardcode colors in widget files
  );

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.cream800,
    // Dark mode inverts: green800 bg, green50 text, etc.
  );
}
```

### UI Shape Language

- **User-facing elements** (cards, buttons, avatars): Rounded corners (AppRadius.md = 12px). Friendly, approachable.
- **Data/schedule elements** (calendar cells, table rows, timeline): Subtle corners (AppRadius.sm = 8px). Clean, readable.
- **Status indicators**: Circular dots (border-radius: pill). Quick visual scanning.

### Component Design Rules

- Every reusable widget lives in `core/widgets/` or the feature's `widgets/` folder
- Widgets accept semantic props, not raw colors (e.g., `CasalyCard(variant: CardVariant.success)` not `CasalyCard(color: Color(0xFF4A9E60))`)
- All hardcoded values (colors, spacing, radius) come from the token files — never inline hex codes
- Dark mode support from the start using `Theme.of(context)` — never check brightness manually

### Color Usage Guide

| Context | Color Token | Example |
|---------|------------|---------|
| Brand/primary actions | green400 | Main buttons, hero card, logo, nav active |
| Cleaning schedule | green400 / green50 bg | "Your cleaning week" card |
| Task completed | green400 | "Done" badge, checkmark |
| Washer timer/alerts | orange400 / orange50 bg | "4 min left" countdown |
| Shopping list/info | yellow400 / yellow50 bg | Item count badge |
| Events/social | berry400 / berry50 bg | "Movie night Friday" |
| Missed/overdue tasks | berry400 | "Missed" status |
| Page background | cream50 | Always warm, never #FFFFFF |
| Card background | white with cream200 border | Content cards |
| Primary text | cream800 | Headings, body text |
| Secondary text | cream600 | Descriptions, timestamps |
| Placeholder text | cream400 | Input hints, empty states |
| Borders | cream200 | Card borders, dividers |

---

## MVP Features (v1)

### 1. Cleaning Schedule + Calendar
- Admin creates cleaning rotation (assign groups/individuals to weeks)
- Calendar view showing who is responsible for which week
- Full history of past assignments (the "proof")
- Swap functionality — recorded as swap events (never mutate original records)
- Status tracking — mark cleaning as done/not done
- Visual compliance indicator per member over time

### 2. Washing Machine Timer
- Start timer when putting laundry in (select machine number)
- Real-time countdown visible to all house members
- Push notification when cycle ends
- Follow-up reminder if not collected within 15 minutes
- House-wide notification when machine becomes free

### 3. Automated Reminders (Push Notifications)
- Weekly push to assigned cleaning group (e.g., Monday morning)
- End-of-week reminder if cleaning not marked as done
- WhatsApp integration deferred to v1.1

### 4. House Group Management
- Create house group with invite code/link (6 chars, alphanumeric)
- Member management (join/leave)
- Assign members to cleaning groups
- Roles: admin and member
- House profile with basic info

## V2 Features (Post-Validation)

- Shopping list with real-time sync
- Inter-house discovery (location-based)
- Events & parties (create, invite, coordinate)
- Expense splitting
- Cleaning verification (photo proof)
- Local business partnerships (restaurant deals, promoted events)

---

## Firestore Data Model

```
/dorms/{dormId}
  - name: string
  - inviteCode: string
  - createdAt: timestamp
  - createdBy: string (userId)
  - memberCount: number

  /members/{userId}
    - displayName: string
    - role: "admin" | "member"
    - joinedAt: timestamp
    - cleaningGroupId: string | null

  /cleaningGroups/{groupId}
    - name: string (e.g., "Group A")
    - memberIds: string[]

  /cleaningSchedule/{scheduleId}
    - groupId: string
    - weekStartDate: timestamp
    - status: "pending" | "done" | "missed"
    - markedDoneBy: string | null (userId)
    - markedDoneAt: timestamp | null
    - createdAt: timestamp

  /cleaningSwaps/{swapId}
    - fromGroupId: string
    - toGroupId: string
    - fromWeek: timestamp
    - toWeek: timestamp
    - requestedBy: string (userId)
    - acceptedBy: string (userId)
    - status: "pending" | "accepted" | "rejected"
    - createdAt: timestamp

  /washingMachines/{machineId}
    - label: string (e.g., "Machine 1")
    - inUse: boolean
    - currentUserId: string | null
    - startedAt: timestamp | null
    - estimatedEndAt: timestamp | null
    - collectedAt: timestamp | null

  /shoppingList/{itemId}  // V2
    - name: string
    - addedBy: string (userId)
    - addedAt: timestamp
    - purchased: boolean
    - purchasedBy: string | null

/users/{userId}
  - displayName: string
  - email: string
  - dormId: string | null
  - fcmToken: string
  - createdAt: timestamp
```

**Firestore path constants** — never use string literals for collection paths:

```dart
abstract class FirestorePaths {
  static const users = 'users';
  static const dorms = 'dorms';
  static const members = 'members';
  static const cleaningGroups = 'cleaningGroups';
  static const cleaningSchedule = 'cleaningSchedule';
  static const cleaningSwaps = 'cleaningSwaps';
  static const washingMachines = 'washingMachines';
  static const shoppingList = 'shoppingList';

  static String dormMembers(String dormId) => '$dorms/$dormId/$members';
  static String dormSchedule(String dormId) => '$dorms/$dormId/$cleaningSchedule';
  static String dormMachines(String dormId) => '$dorms/$dormId/$washingMachines';
}
```

## Firestore Security Rules (Must Ship With v1)

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    match /dorms/{dormId} {
      allow read: if request.auth != null
        && exists(/databases/$(database)/documents/dorms/$(dormId)/members/$(request.auth.uid));
      allow create: if request.auth != null;

      match /{subcollection}/{docId} {
        allow read: if request.auth != null
          && exists(/databases/$(database)/documents/dorms/$(dormId)/members/$(request.auth.uid));
        allow write: if request.auth != null
          && exists(/databases/$(database)/documents/dorms/$(dormId)/members/$(request.auth.uid));
      }
    }
  }
}
```

---

## Target Users

- **Primary**: University students in shared dorms/housing (especially international students)
- **Champion user**: The person who already made a spreadsheet or who cleans more than their share — they install the app and drag everyone else in
- **Initial market**: University of Twente campus housing, Enschede, Netherlands
- **Sweet spot**: Houses that WANT to be organized but lack infrastructure

## Go-to-Market (UT Campus)

1. Find the spreadsheet makers — people who already tried to organize their house
2. Post in UT housing WhatsApp/Facebook groups asking about cleaning pain points
3. ESN Twente and international student communities
4. Study association borrels for organic conversations
5. Target Kick-In week (semester start) when new houses form
6. Built-in virality: one person installs → must invite entire house

## Marketing Message

**Don't say**: "Organize your dorm cleaning"
**Do say**: "Stop being the only one who cleans" / "Know who's actually doing their share"

Sell fairness, not organization. For business partners: "Reach every student household in Enschede through Casaly."

---

## Development Phases

### Phase 1 — MVP
- [ ] Flutter project setup with clean architecture scaffold
- [ ] Design token system (colors, typography, spacing, radius)
- [ ] Firebase project setup + auth (email/Google sign-in)
- [ ] House creation + invite code join flow
- [ ] Cleaning group assignment
- [ ] Cleaning schedule creation (weekly rotation)
- [ ] Calendar view of schedule + history
- [ ] Mark cleaning as done
- [ ] Washing machine timer (start/stop/notify)
- [ ] Push notifications (FCM) for cleaning reminders + laundry alerts
- [ ] Firestore security rules
- [ ] Light + dark mode support

### Phase 2 — Post-Launch Iteration
- [ ] WhatsApp Business API integration
- [ ] Shopping list with real-time sync
- [ ] Swap request flow
- [ ] Cleaning compliance stats per member
- [ ] UI/UX improvements from user feedback

### Phase 3 — Growth
- [ ] Inter-house features (discovery, events)
- [ ] Expense splitting
- [ ] Local business partnerships (restaurant deals)
- [ ] Multi-university expansion
- [ ] Localization (Dutch, English, others)

---

## Key Decisions Log

| Decision | Choice | Reasoning |
|----------|--------|-----------|
| App name | Casaly | "Casa" = home internationally, scales beyond dorms, credible for business partnerships |
| Backend | Firebase over Supabase | Real-time sync is core need, superior Flutter SDK, FCM built-in |
| State mgmt | Riverpod | Type-safe, testable, scalable, better than Provider for clean architecture |
| Architecture | Clean Architecture + Repository | Maintainable, testable, Firebase-swappable |
| Theme | "Summer Garden" (green primary) | Warm, inviting, feels like summer in cold Dutch winters |
| Data model | Document-based hierarchy | Dorm → subcollections maps naturally |
| Swap tracking | Separate swap events | Never mutate schedule records — maintain audit trail |
| WhatsApp | Deferred to v1.1 | Start with push notifications, add WhatsApp once core validated |
| Code quality | Clean from day one | Proper tokens, abstractions, naming. No technical debt by design. |

## Notes

- GDPR compliance required (EU users) — add privacy policy, data deletion capability
- Washing machine timer uses real-time listeners — optimize for battery/bandwidth
- Calendar is read-heavy — consider caching strategies
- Invite code: 6 chars alphanumeric, short and memorable
- The app replaces the NEED for a house leader, it doesn't replace a house leader
- Background color is NEVER pure white (#FFFFFF) — always warm cream (#FFFAF0)
