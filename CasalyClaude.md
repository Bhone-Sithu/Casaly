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

## Design System — "Summer Garden" Theme

**Design philosophy**: Someone in a cold Dutch winter opens Casaly and feels warmth, green, and summer. Every color comes from a summer garden — green leaves, sunset sky, sunflowers, ripe berries. The background is never cold white — always warm cream, like late afternoon sunlight on a wall.

### Design Tokens (Single Source of Truth)

All colors, spacing, typography, and radii are defined ONCE in `core/theme/` and referenced everywhere else. Never hardcode hex values in widgets.

#### Colors — `app_colors.dart`

```dart
abstract class AppColors {
  // === PRIMARY — Garden Green ===
  // Fresh leaves, summer grass, life growing
  // Use for: brand, primary actions, hero cards, nav active, "clean/done"
  static const green50  = Color(0xFFEAF5E4);
  static const green100 = Color(0xFFB8DCA4);
  static const green200 = Color(0xFF8BBC78);
  static const green400 = Color(0xFF4A9E60);  // ← Primary brand color
  static const green600 = Color(0xFF3A7A44);
  static const green800 = Color(0xFF245030);

  // === SECONDARY — Sunset Orange ===
  // Golden hour warmth, urgency without stress
  // Use for: timers, alerts, washer status, warm accents
  static const orange50  = Color(0xFFFFF0E0);
  static const orange100 = Color(0xFFFCCFA0);
  static const orange200 = Color(0xFFF0A060);
  static const orange400 = Color(0xFFE8884A);  // ← Secondary brand color
  static const orange600 = Color(0xFFC06830);
  static const orange800 = Color(0xFF8A4820);

  // === ACCENT — Sunflower ===
  // Cheerful, optimistic, summer fields
  // Use for: shopping lists, info badges, counts, gentle reminders
  static const yellow50  = Color(0xFFFEF8E0);
  static const yellow100 = Color(0xFFF5E08A);
  static const yellow200 = Color(0xFFF2C24E);
  static const yellow400 = Color(0xFFD4A420);
  static const yellow600 = Color(0xFFA08420);
  static const yellow800 = Color(0xFF6A5810);

  // === ACCENT — Warm Berry ===
  // Strawberry warmth, excitement without aggression
  // Use for: events, social features, missed tasks, errors
  static const berry50  = Color(0xFFFDEAEA);
  static const berry100 = Color(0xFFF0AAAA);
  static const berry200 = Color(0xFFE87070);
  static const berry400 = Color(0xFFD04848);
  static const berry600 = Color(0xFFA03434);
  static const berry800 = Color(0xFF6A2020);

  // === NEUTRALS — Warm Cream ===
  // Every surface has a warm tint. No cold grays anywhere.
  static const cream50  = Color(0xFFFFFAF0);  // ← Page background
  static const cream100 = Color(0xFFFFF3E0);  // ← Card highlight bg
  static const cream200 = Color(0xFFEDE0CC);  // ← Borders
  static const cream400 = Color(0xFFA09080);  // ← Placeholder text
  static const cream600 = Color(0xFF5A4E42);  // ← Secondary text
  static const cream800 = Color(0xFF302820);  // ← Primary text

  // === SEMANTIC (mapped from above) ===
  static const success = green400;
  static const warning = yellow400;
  static const error   = berry400;
  static const info    = orange400;
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
