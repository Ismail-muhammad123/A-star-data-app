# A-Star Data App — Feature Upgrade Implementation Plan

## Background

This is an **incremental extension** of the existing A-Star Connect Flutter production app. All new features must be wired into the existing architecture without breaking anything.

### Confirmed Existing Architecture

| Layer | Pattern |
|---|---|
| State Management | `Provider` (`ChangeNotifier`) |
| Navigation | `go_router` |
| HTTP Client | `Dio` (raw, no interceptors yet) |
| Storage | `SharedPreferences` + `flutter_secure_storage` |
| Auth | JWT (access + refresh tokens) in `SharedPreferences` |
| Structure | Feature-based: `features/{name}/data/`, `providers/`, `views/` |

**Registered Providers (main.dart):** `AuthProvider`, `ProfileProvider`, `ThemeProvider`, `BalanceVisibilityProvider`, `WalletProvider`

---

## ✅ Verified API Endpoint Inventory

> Source: OpenAPI Schema & Staging Swagger UI  
> Base URL: `https://backend.stardata.com.ng/api` (production)

### `account` tag — Auth & Profile

| Method | Path | Purpose |
|---|---|---|
| POST | `/api/account/signup/` | Register (includes `referral_code`) |
| POST | `/api/account/login/` | Login with phone + PIN |
| POST | `/api/account/logout/` | Logout |
| POST | `/api/account/refresh-token/` | Refresh JWT |
| POST | `/api/account/activate-account/` | Activate via OTP |
| POST | `/api/account/change-pin/` | Change **Login** PIN |
| GET/PUT | `/api/account/profile/` | Fetch/Update user profile |
| POST | `/api/account/register-fcm-token/` | Register device FCM token |
| POST | `/api/account/verify-2fa/` | Submit 2FA OTP |

### Transaction PIN (Separate Security Layer)

| Method | Path | Purpose |
|---|---|---|
| POST | `/api/account/set-transaction-pin/` | First-time setup |
| POST | `/api/account/change-transaction-pin/` | Change PIN |
| POST | `/api/account/verify-transaction-pin/` | Verify before sensitive op |
| POST | `/api/account/reset-transaction-pin/` | Reset via OTP |

### Wallet & Payments

| Method | Path | Purpose |
|---|---|---|
| GET | `/api/wallet/` | Balance |
| GET | `/api/wallet/transactions/` | History |
| POST | `/api/wallet/p2p-transfer/` | User-to-User transfer |
| POST | `/api/wallet/lookup-user/` | Find recipient by phone |
| GET | `/api/wallet/withdrawal-account/` | Withdrawal bank info |
| POST | `/api/payment/withdrawal-request/` | Initiate withdrawal |

### Support, Notifications & Referrals

| Method | Path | Purpose |
|---|---|---|
| GET/POST | `/api/support/tickets/` | Support system |
| GET | `/api/notifications/` | Alerts & Messages |
| GET | `/api/account/referral/` | Referral stats/info |

---

## Confirmed Data Models

### `Signup` request body
```dart
{
  "phone_country_code": "+234",
  "phone_number": "8012345678",
  "pin": "123456",
  "referral_code": "ABC123", // Confirmed supported
  "email": "user@example.com"
}
```

---

## User Review Clarifications

> [!IMPORTANT]
> **Transaction PIN Security**: This is a distinct credential from the Login PIN. Even if a device is logged in, sensitive operations (purchases, transfers) require this separate PIN to prevent unauthorized access.

> [!IMPORTANT]
> **Beneficiary System**: Legacy bank-details endpoints are removed/unused. The system now relies on the `Beneficiary` model for both purchases and withdrawals.

> [!WARNING]
> **Firebase Setup**: Firebase is **not** yet configured. Implementation of FCM (Phase 4) will include:
> 1. Adding `google-services.json` / `GoogleService-Info.plist`.
> 2. Native configuration in `android/build.gradle` and `AppDelegate`.
> 3. Enabling FCM and potentially Google Sign-In as requested.

---efore implementation begins.

---

## Proposed Changes

---

### PHASE 0 — Shared Infrastructure (Prerequisites)

These changes underpin nearly every new feature and must be done first.

---

#### [MODIFY] `lib/core/constants/api_endpoints.dart`

Extend with new endpoint classes. **All existing endpoint classes remain untouched.**

```dart
// ---- NEW: 2FA ----
class TwoFAEndpoints {
  final String settings = "$baseUrl/account/2fa/settings/";
  final String verify = "$baseUrl/account/verify-2fa/";
  final String resend = "$baseUrl/account/2fa/resend/";
  final String reset = "$baseUrl/account/2fa/reset/";
}

// ---- NEW: Transaction PIN ----
class TransactionPinEndpoints {
  final String setPin = "$baseUrl/account/set-transaction-pin/";
  final String changePin = "$baseUrl/account/change-transaction-pin/";
  final String verifyPin = "$baseUrl/account/verify-transaction-pin/";
  final String requestResetOtp = "$baseUrl/account/request-transaction-pin-reset-otp/";
  final String resetPin = "$baseUrl/account/reset-transaction-pin/";
}

// ---- NEW: FCM ----
class FCMEndpoints {
  final String registerToken = "$baseUrl/account/register-fcm-token/";
}

// ---- NEW: Support Tickets ----
class SupportEndpoints {
  final String tickets = "$baseUrl/support/tickets/";
  String messages(int id) => "$baseUrl/support/tickets/$id/messages/";
  String closeTicket(int id) => "$baseUrl/support/tickets/$id/close/";
}

// ---- NEW: Notifications ----
class NotificationEndpoints {
  final String list = "$baseUrl/notifications/";
  String markRead(int id) => "$baseUrl/notifications/$id/read/";
  final String markAllRead = "$baseUrl/notifications/mark-all-read/";
}

// ---- NEW: KYC ----
class KycEndpoints {
  final String status = "$baseUrl/account/kyc/";
  final String submit = "$baseUrl/account/kyc/submit/";
}

// ---- NEW: Referral ----
class ReferralEndpoints {
  final String info = "$baseUrl/account/referral/";
}

// ---- NEW: Beneficiaries ----
class BeneficiaryEndpoints {
  final String purchaseBeneficiaries = "$baseUrl/account/purchase-beneficiaries/";
  String deletePurchaseBeneficiary(int id) => "$baseUrl/account/purchase-beneficiaries/$id/";
}

// ---- NEW: P2P Transfer (Inside Wallet) ----
// Handled by WalletEndpoints or a new P2PEndpoints inside Wallet feature
class P2PEndpoints {
  final String lookupUser = "$baseUrl/wallet/lookup-user/";
  final String transfer = "$baseUrl/wallet/p2p-transfer/";
}
```

---

#### [NEW] `lib/core/network/dio_client.dart`
```dart
class DioClient {
  // Shared Dio instance for new features
  // Uses interceptors for Auth header and Logging
  // Prevents repeating header logic in every service
}
```

---

#### [NEW] `lib/core/services/dio_client.dart` — Shared Dio singleton with auth interceptor

> [!NOTE]
> Currently every service creates its own `Dio()` instance and attaches the auth token manually per request. This causes duplication across 10+ new services. We introduce **one shared `DioClient`** that auto-attaches the `Authorization` header from `SharedPreferences`. Existing services are **not refactored** — only new services use this. This is the minimal change needed to avoid repeating header logic 30+ times.

```dart
class DioClient {
  static Dio createAuthorizedClient(String token) {
    return Dio(BaseOptions(
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      validateStatus: (s) => true,
    ));
  }
}
```

---

### PHASE 1 — Two-Factor Authentication (2FA)

Extends the **existing login flow** without modifying the happy path.

---

#### [MODIFY] `lib/features/auth/data/repository/auth_repo.dart`

Add two new methods:
- `verify2FA(String tempToken, String otp)` → returns `{access, refresh}`
- `resend2FAOtp(String tempToken)` → void

The existing `login()` method already returns a `Map`. We simply handle the new `requires_2fa: true` key in the provider.

---

#### [MODIFY] `lib/features/auth/providers/auth_provider.dart`

In `login()`, after receiving the response:
```dart
if (res['requires_2fa'] == true) {
  // Save temp_token to secure storage
  // Return special flag to UI
  return {'success': false, 'requires_2fa': true, 'temp_token': res['temp_token']};
}
```
Also add:
- `verify2FA(String otp)` — reads `temp_token` from secure storage, calls service, validates tokens, sets auth state
- `resend2FAOtp()` — reads temp token, calls resend service

---

#### [NEW] `lib/features/auth/views/pages/two_fa_otp_page.dart`

- Receives `phoneNumber` as display text (not for use in request)
- OTP input (6 digits, styled like existing PIN input)
- Timer countdown for resend (60s)
- "Resend OTP" button (active after timer expires)
- On success → navigates to `/home`
- Uses existing `_inputDecoration()` style pattern

---

#### [MODIFY] `lib/features/auth/views/pages/login.dart`

After login call:
```dart
if (res['requires_2fa'] == true) {
  context.push('/verify-2fa', extra: phoneNumber);
}
```

---

#### [MODIFY] `lib/core/app_router.dart`

Add route: `/verify-2fa`

---

### PHASE 2 — Transaction PIN System

> [!IMPORTANT]
> The **Transaction PIN** is a **separate credential** from the login PIN. The staging Swagger confirms dedicated endpoints: `set-transaction-pin`, `change-transaction-pin`, `verify-transaction-pin`. The login PIN uses `/api/account/change-pin/` only. These are two distinct PIN systems.

---

#### [NEW] `lib/core/widgets/pin_entry_bottom_sheet.dart`

A reusable bottom sheet widget:
- Custom **numeric keypad** (0-9 + backspace + confirm)
- 4-dot masked PIN indicator
- `onConfirmed(String pin)` callback
- Timeout: auto-dismiss after 60s of inactivity
- On first use: detect if transaction PIN is set → if not, redirect to `SetTransactionPinPage`

Usage pattern:
```dart
final pin = await showTransactionPinSheet(context);
if (pin != null) {
  // Call verify-transaction-pin first, then proceed if valid
  final valid = await txPinProvider.verifyPin(pin);
  if (valid) await purchaseService.purchase(...);
}
```

---

#### [NEW] `lib/features/settings/views/pages/transaction_pin/set_transaction_pin_page.dart`

First-time PIN setup form — triggers `/api/account/set-transaction-pin/`.

#### [NEW] `lib/features/settings/views/pages/transaction_pin/change_transaction_pin_page.dart`

Change existing transaction PIN — triggers `/api/account/change-transaction-pin/`.

#### [NEW] `lib/features/settings/views/pages/transaction_pin/reset_transaction_pin_page.dart`

Forgot transaction PIN flow:
1. Request OTP → `/api/account/request-transaction-pin-reset-otp/`
2. Enter OTP + new PIN → `/api/account/reset-transaction-pin/`

---

#### Integration points (no refactor of existing calls, simple injection):

| Feature | Where to inject |
|---|---|
| Buy Airtime | `AirtimePurchaseFormPage` → `showTransactionPinSheet()` before `purchaseAirtime()` |
| Buy Data | `DataPurchaseFormPage` → same pattern |
| Buy Electricity | `PurchaseElectricityFormPage` → same pattern |
| Buy TV | `PurchaseTVSubscriptionFormPage` → same pattern |
| P2P Transfer | New transfer flow |
| Repeat Purchase | New repeat flow |

---

### PHASE 3 — Support & Ticket System

---

#### [NEW] `lib/features/support/`

Full feature folder structure:
```
support/
  data/
    models/
      ticket_model.dart
      message_model.dart
    repositories/
      support_service.dart
  providers/
    support_provider.dart
  views/
    pages/
      tickets_list_page.dart
      ticket_detail_page.dart   ← Chat UI
    widgets/
      ticket_status_chip.dart
      message_bubble.dart
      tickets_empty_state.dart
```

---

#### `ticket_model.dart`
```dart
class SupportTicket {
  final int id;
  final String title;
  final String status; // 'open' | 'closed'
  final DateTime createdAt;
  // fromJson / toJson
}
```

#### `message_model.dart`
```dart
class TicketMessage {
  final int id;
  final int ticketId;
  final String sender; // 'user' | 'support'
  final String content;
  final DateTime timestamp;
  // fromJson / toJson
}
```

---

#### `support_service.dart`
- `fetchTickets(token, {String? status})` → `List<SupportTicket>`
- `createTicket(token, String title, String firstMessage)` → `SupportTicket`
- `fetchMessages(token, int ticketId, {int page})` → paginated `List<TicketMessage>`
- `sendMessage(token, int ticketId, String content)` → `TicketMessage`
- `closeTicket(token, int ticketId)` → void

---

#### `support_provider.dart`
`ChangeNotifier` with:
- `List<SupportTicket> tickets` + loading/error state
- `Map<int, List<TicketMessage>> messages` (per-ticket cache)
- `String statusFilter` ('all' | 'open' | 'closed')
- Optimistic UI: add message to list immediately, roll back on error
- Pagination cursor per ticket

---

#### `tickets_list_page.dart`
- Filter chips: All / Open / Closed
- `RefreshIndicator` for pull-to-refresh
- FAB to create new ticket
- Shows `ticket_status_chip.dart` per item

#### `ticket_detail_page.dart` (Chat UI)
- `ListView.builder` with messages grouped by sender
- Auto-scroll to bottom on new message (`ScrollController`)
- User messages: right-aligned, primary color background
- Support messages: left-aligned, grey background
- `message_bubble.dart` widget handles both
- Bottom input bar: `TextField` + Send `IconButton`
- "Close Ticket" button in AppBar if status == 'open'
- Pagination: load older messages on scroll-to-top

---

#### Endpoint reference for `support_service.dart`

```dart
// Uses SupportEndpoints class added in Phase 0
// POST   $baseUrl/support/tickets/              → createTicket
// GET    $baseUrl/support/tickets/              → fetchTickets
// GET    $baseUrl/support/tickets/{id}/messages/ → fetchMessages
// POST   $baseUrl/support/tickets/{id}/messages/ → sendMessage
// POST   $baseUrl/support/tickets/{id}/close/   → closeTicket

// ⚠️ Backend team must implement these endpoints.
```

---

#### [MODIFY] `lib/core/app_router.dart`
Add: `/support/tickets`, `/support/tickets/:ticketId`

#### [MODIFY] `lib/features/settings/views/pages/settings_page.dart`
Replace WhatsApp tile with a new "Support & Help" tile that pushes to `/support/tickets`.

#### [MODIFY] `main.dart`
Register `SupportProvider`.

---

### PHASE 4 — Push Notifications (FCM)

---

#### New packages required:
- `firebase_core`
- `firebase_messaging`

---

#### [NEW] `lib/core/services/fcm_service.dart`
```dart
class FCMService {
  // Confirmed staging endpoint: POST /api/account/register-fcm-token/
  // Remove endpoint: confirm with backend (not yet in schema)
  
  Future<void> initialize();   // request permission, set up handlers
  Future<String?> getToken();
  // registerToken → POST $baseUrl/account/register-fcm-token/
  //   body: { "fcm_token": "<token>" }  (field name TBC with backend)
  Future<void> registerToken(String authToken, String fcmToken);
  Future<void> removeToken(String authToken, String fcmToken);
  void handleForegroundMessage(RemoteMessage msg);
  void setupBackgroundHandler();
}
```

---

#### [MODIFY] `lib/features/auth/providers/auth_provider.dart`

- In `login()` success path: call `FCMService().registerToken()` (fire-and-forget, wrapped in try/catch)
- In `logout()`: call `FCMService().removeToken()`

---

#### [MODIFY] `lib/main.dart`
- Add `WidgetsFlutterBinding.ensureInitialized()` already exists ✓
- Add `await Firebase.initializeApp()` before `runApp()`

---

#### Notification tap navigation:
- Use `go_router` to navigate based on `notification.data['route']` field
- Map: `{'route': '/orders/history/123'}` → `context.go('/orders/history/123')`

---

### PHASE 5 — Notifications Page

---

#### [NEW] `lib/features/notifications/`
```
notifications/
  data/
    models/notification_model.dart
    repositories/notifications_service.dart
  providers/notifications_provider.dart
  views/
    pages/notifications_page.dart
    widgets/notification_tile.dart
```

#### `notification_model.dart`
```dart
class AppNotification {
  final int id;
  final String title;
  final String body;
  final bool isRead;
  final DateTime createdAt;
  final String? route; // for tap navigation
}
```

#### `notifications_service.dart`
- `fetchNotifications(token)` → `List<AppNotification>`
- `markAsRead(token, int id)` → void
- `markAllRead(token)` → void

#### `notifications_provider.dart`
- `int get unreadCount` → used to show badge on nav
- `markRead` updates locally first (optimistic), then syncs

#### `notifications_page.dart`
- `ExpansionTile` per notification: title (preview) → full body on expand
- "Mark all read" action in AppBar
- Unread items have a colored left border indicator
- Empty state when list is empty

---

#### [MODIFY] `lib/core/app_router.dart`
Add: `/notifications`

#### [MODIFY] `lib/home.dart`
- Add notification bell icon to AppBar with unread badge
- Badge driven by `context.watch<NotificationsProvider>().unreadCount`

#### [MODIFY] `main.dart`
Register `NotificationsProvider`.

---

### PHASE 6 — KYC Module (Complete existing skeleton)

The `KYCData` model already exists. The settings page already shows a "Verify Account" prompt.

---

#### [NEW] `lib/features/settings/data/repositories/kyc_service.dart`
```dart
class KycService {
  Future<KYCData?> fetchKycStatus(String token);
  Future<bool> submitKyc(String token, {required String nin, required File idImage});
}
```

---

#### [MODIFY] `lib/features/settings/providers/profile_provider.dart`
Currently it only has a stub. Extend to:
- `KYCData? kycData`
- `Future<void> loadKycStatus(String token)`
- `Future<bool> submitKyc(...)` with loading state

---

#### [NEW] `lib/features/settings/views/pages/kyc/kyc_status_page.dart`
- Status card: shows current status (Not Submitted / Pending / Approved / Rejected)
- Color-coded: green (approved), orange (pending), red (rejected), grey (none)
- "Submit / Resubmit" button → pushes to form
- Shows `feedback` message if rejected

#### [NEW] `lib/features/settings/views/pages/kyc/kyc_form_page.dart`
- NIN text input
- ID image upload (uses existing `image_picker` already in `pubspec.yaml`)
- Submit button with loading state

---

#### [MODIFY] `lib/core/constants/api_endpoints.dart`
```dart
class KycEndpoints {
  final String status = "$baseUrl/account/kyc/";
  final String submit = "$baseUrl/account/kyc/submit/";
}
```

#### [MODIFY] `lib/core/app_router.dart`
Add: `/profile/kyc`, `/profile/kyc/form`

#### [MODIFY] `lib/features/settings/views/pages/settings_page.dart`
Add a "KYC Verification" tile under Account Details section.

---

### PHASE 7 — Referral System

---

#### [NEW] `lib/features/referral/`
```
referral/
  data/
    models/referral_model.dart
    repositories/referral_service.dart
  providers/referral_provider.dart
  views/
    pages/referral_page.dart
    widgets/referral_stat_card.dart
```

#### `referral_model.dart`
```dart
class ReferralInfo {
  final String referralCode;
  final int totalReferrals;
  final double totalEarnings;
  // Agent-extended fields (nullable, future-proof):
  final double? agentEarnings;
  final int? agentTier;
}
```

#### `referral_page.dart`
- Dashboard with `referral_stat_card.dart` for each metric
- Share referral code button (uses existing `share_plus` package)
- Copy referral code to clipboard

---

#### [MODIFY] `lib/features/auth/views/pages/sign_up.dart` **(Referral Signup)**
- Add optional `referralCodeController`
- A "Have a referral code?" collapsible section or simple text field
- Pass to `authProvider.register(... referralCode: ...)`

#### [MODIFY] `lib/features/auth/providers/auth_provider.dart`
- Accept `referralCode` as optional param in `register()`

#### [MODIFY] `lib/features/auth/data/repository/auth_repo.dart`
- Add `referral_code` to register request body if present (Supported as per User Feedback)

---

#### [MODIFY] `lib/core/constants/api_endpoints.dart`
```dart
class ReferralEndpoints {
  final String info = "$baseUrl/account/referral/";
}
```

#### [MODIFY] `lib/core/app_router.dart`
Add: `/referral`

#### [MODIFY] `lib/features/settings/views/pages/settings_page.dart`
Add a "Referral Program" tile under Account Details.

#### [MODIFY] `main.dart`
Register `ReferralProvider`.

---

### PHASE 8 — Purchase & Transfer Beneficiaries

---

#### [NEW] `lib/features/beneficiaries/`
```
beneficiaries/
  data/
    models/
      purchase_beneficiary_model.dart
      transfer_beneficiary_model.dart
    repositories/
      beneficiary_service.dart
  providers/
    beneficiary_provider.dart
  views/
    widgets/
      beneficiary_selector_sheet.dart
```

#### Models
```dart
class PurchaseBeneficiary {
  final int id;
  final String phoneNumber;
  final String? label; // e.g. "MTN - 08012345678"
  final String serviceType; // 'data' | 'airtime'
}

class TransferBeneficiary {
  final int id;
  final String phoneNumber;
  final String? name;
}
```

#### `beneficiary_service.dart`
- `fetchPurchaseBeneficiaries(token, serviceType)` → List
- `savePurchaseBeneficiary(token, ...)` → PurchaseBeneficiary
- `fetchTransferBeneficiaries(token)` → List
- `saveTransferBeneficiary(token, ...)` → TransferBeneficiary
- `deleteTransferBeneficiary(token, id)` → void

#### `beneficiary_provider.dart`
- Separate lists and loading states for purchase/transfer beneficiaries
- `autofill(phoneNumber)` → triggers a stream/callback back to form

---

#### [MODIFY] `lib/features/orders/views/pages/data/buy_data.dart`
- Add "Saved Numbers" chip above phone field
- On tap: `showBeneficiarySelector(context)` → fills phone field
- After success: conditionally `savePurchaseBeneficiary()` based on checkbox

#### Same pattern for: `buy_airtime.dart`, `buy_electricity_page.dart`, `buy_tv_page.dart`

---

#### [MODIFY] `lib/core/constants/api_endpoints.dart`
```dart
class BeneficiaryEndpoints {
  final String purchaseBeneficiaries = "$baseUrl/account/purchase-beneficiaries/";
  String deletePurchaseBeneficiary(int id) => "$baseUrl/account/purchase-beneficiaries/$id/";
  final String transferBeneficiaries = "$baseUrl/account/transfer-beneficiaries/";
  String deleteTransferBeneficiary(int id) => "$baseUrl/account/transfer-beneficiaries/$id/";
}
```

#### [MODIFY] `main.dart`
Register `BeneficiaryProvider`.

---

### PHASE 9 — Repeat Purchase

> [!WARNING]
> A `/api/orders/repeat-purchase/` endpoint is **NOT in the current schema**. However, the schema does have `/api/orders/purchase-status/{id}/` which queries transaction status. Confirm with the backend whether repeat purchase uses a dedicated endpoint or simply re-submits the original purchase data. The UI can be built regardless; only the service method needs the confirmed endpoint.

---

#### [MODIFY] `lib/features/orders/views/pages/history/order_details.dart`

Add a "Repeat Purchase" button (visible only for `status == 'success'` purchases of type data/airtime):
```dart
// On tap:
final pin = await showTransactionPinSheet(context);
if (pin != null) {
  await orderProvider.repeatPurchase(transactionId, pin);
}
```

---

#### [MODIFY] `lib/features/orders/data/services.dart`
Add:
```dart
// POST $baseUrl/orders/repeat-purchase/
// Body: { "transaction_id": id, "pin": pin }
// ⚠️ Endpoint must be confirmed with backend
Future<void> repeatPurchase({
  required String authToken,
  required int transactionId,
  required String pin,
})
```

---

### PHASE 10 — P2P Transfer (Inside Wallet)

---

#### Architecture Consistency:
P2P Transfer is placed inside the `wallet` feature to match existing patterns.

```
lib/features/wallet/
  data/
    models/p2p_transfer_model.dart
    repositories/p2p_service.dart
  providers/p2p_provider.dart // Optional, or extend WalletProvider
  views/
    pages/p2p/
      p2p_transfer_page.dart
      recipient_lookup_screen.dart
```

#### Flow:
1. Enter recipient phone number
2. On "Lookup" tap: call `fetchRecipient(phone)`
3. Enter amount
4. Transaction PIN sheet (Verified before API call)
5. Confirm → call `p2p_service.executeTransfer()`


#### [MODIFY] `lib/core/app_router.dart`
Add: `/wallet/p2p-transfer`

#### [MODIFY] `lib/features/wallet/views/` (wallet page)
Add "Send Money" button that navigates to `/wallet/p2p-transfer`

#### [MODIFY] `main.dart`
Register `P2PProvider`.

---

## File Structure Changes (New Files Summary)

```
lib/
├── core/
│   ├── services/
│   │   ├── dio_client.dart                        [NEW]
│   │   └── fcm_service.dart                       [NEW]
│   └── widgets/
│       └── pin_entry_bottom_sheet.dart            [NEW]
│
├── features/
│   ├── auth/
│   │   └── views/pages/
│   │       └── two_fa_otp_page.dart               [NEW]
│   │
│   ├── support/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   ├── ticket_model.dart              [NEW]
│   │   │   │   └── message_model.dart             [NEW]
│   │   │   └── repositories/
│   │   │       └── support_service.dart           [NEW]
│   │   ├── providers/
│   │   │   └── support_provider.dart              [NEW]
│   │   └── views/
│   │       ├── pages/
│   │       │   ├── tickets_list_page.dart         [NEW]
│   │       │   └── ticket_detail_page.dart        [NEW]
│   │       └── widgets/
│   │           ├── ticket_status_chip.dart        [NEW]
│   │           └── message_bubble.dart            [NEW]
│   │
│   ├── notifications/
│   │   ├── data/
│   │   │   ├── models/notification_model.dart     [NEW]
│   │   │   └── repositories/
│   │   │       └── notifications_service.dart     [NEW]
│   │   ├── providers/
│   │   │   └── notifications_provider.dart        [NEW]
│   │   └── views/
│   │       ├── pages/notifications_page.dart      [NEW]
│   │       └── widgets/notification_tile.dart     [NEW]
│   │
│   ├── referral/
│   │   ├── data/
│   │   │   ├── models/referral_model.dart         [NEW]
│   │   │   └── repositories/referral_service.dart [NEW]
│   │   ├── providers/referral_provider.dart       [NEW]
│   │   └── views/
│   │       ├── pages/referral_page.dart           [NEW]
│   │       └── widgets/referral_stat_card.dart    [NEW]
│   │
│   ├── beneficiaries/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   ├── purchase_beneficiary_model.dart [NEW]
│   │   │   │   └── transfer_beneficiary_model.dart [NEW]
│   │   │   └── repositories/
│   │   │       └── beneficiary_service.dart       [NEW]
│   │   ├── providers/beneficiary_provider.dart    [NEW]
│   │   └── views/widgets/
│   │       └── beneficiary_selector_sheet.dart    [NEW]
│   │
│   ├── p2p/
│   │   ├── data/
│   │   │   ├── models/p2p_transfer_model.dart     [NEW]
│   │   │   └── repositories/p2p_service.dart      [NEW]
│   │   ├── providers/p2p_provider.dart            [NEW]
│   │   └── views/
│   │       ├── pages/p2p_transfer_page.dart       [NEW]
│   │       └── widgets/recipient_confirm_card.dart [NEW]
│   │
│   └── settings/
│       ├── data/repositories/
│       │   └── kyc_service.dart                   [NEW]
│       └── views/pages/kyc/
│           ├── kyc_status_page.dart               [NEW]
│           └── kyc_form_page.dart                 [NEW]
```

---

## New Dependencies

| Package | Purpose | Already in pubspec? |
|---|---|---|
| `firebase_core` | Firebase init | ❌ Add |
| `firebase_messaging` | FCM push notifications | ❌ Add |
| `dio` | HTTP client | ✅ Yes |
| `shared_preferences` | Local storage | ✅ Yes |
| `flutter_secure_storage` | Secure token storage | ✅ Yes |
| `image_picker` | KYC image upload | ✅ Yes |
| `share_plus` | Share referral code | ✅ Yes |
| `permission_handler` | FCM permission | ✅ Yes |

---

## Integration Points With Existing Code

| Existing File | Change Type | Reason |
|---|---|---|
| `auth_repo.dart` | Extend | Add 2FA verify/resend; referral_code in register (backend permitting) |
| `auth_provider.dart` | Extend | 2FA flow handling; FCM token register on login, remove on logout |
| `sign_up.dart` | Extend | Optional referral code field (backend-dependent) |
| `settings_page.dart` | Extend | Add KYC, Referral, Support, Transaction PIN management tiles |
| `app_router.dart` | Extend | Register all new routes |
| `main.dart` | Extend | Register all new providers + `Firebase.initializeApp()` |
| `home.dart` | Extend | Notification bell icon with unread badge in AppBar |
| `buy_data.dart` | Extend | Beneficiary selector + transaction PIN sheet before submit |
| `buy_airtime.dart` | Extend | Same pattern |
| `buy_electricity_page.dart` | Extend | Same pattern |
| `buy_tv_page.dart` | Extend | Same pattern |
| `order_details.dart` | Extend | "Repeat Purchase" button for eligible orders |
| `api_endpoints.dart` | Extend (append only) | New endpoint classes — no existing code changed |
| `profile_provider.dart` | Extend | Add KYC state; transaction PIN status |
| `orders/data/services.dart` | Extend | Add `repeatPurchase()` method |

---

## Edge Case Handling

| Scenario | Handling Strategy |
|---|---|
| Network failure | Dio `DioException` caught in service, propagated as `Exception`; Provider exposes `errorMessage` string |
| Token expiration | FCM token removal on logout; 401 responses show re-login prompt |
| Expired 2FA OTP | Backend returns error; shown in OTP page as inline error message |
| Resend OTP | Cooldown timer in UI; button disabled until timer expires |
| Partial 2FA login | `temp_token` stored in `flutter_secure_storage`, cleared on success or cancellation |
| Invalid PIN | Backend error surfaced as SnackBar; bottom sheet stays open |
| Duplicate requests | `isLoading` flag in provider prevents double submissions |
| Empty states | Each list screen has a dedicated empty state widget |
| Paginated messages | `hasMore` flag in support provider; `ScrollController` triggers next page fetch |
| Optimistic UI rollback | Support message reverted if send API fails |
| KYC resubmission | `kycStatus == 'rejected'` → show resubmit button on status page |
| Beneficiary autofill | Phone field populated via controller; user can still edit before submitting |

---

## Implementation Order (Phased Execution)

```
Phase 0: api_endpoints.dart extensions + DioClient [1-2h]
Phase 1: 2FA (auth_repo + auth_provider + OTP page)  [2-3h]
Phase 2: PIN bottom sheet widget + inject into purchase flows [2-3h]
Phase 3: Support & ticket system (full feature)  [4-6h]
Phase 4: FCM setup (native + service + provider hooks)  [2-3h]
Phase 5: Notifications page  [2-3h]
Phase 6: KYC module (complete existing skeleton)  [2-3h]
Phase 7: Referral system + signup field  [2-3h]
Phase 8: Beneficiaries (purchase + transfer)  [3-4h]
Phase 9: Repeat purchase  [1-2h]
Phase 10: P2P transfer  [2-3h]
```

---

## Verification Plan

### Automated
- Run `flutter analyze` after each phase — zero new errors/warnings
- Run `flutter test` for any unit-testable business logic in providers

### Manual Regression (existing features must not break)
- [ ] Login → home flow works
- [ ] Biometric login still works
- [ ] Buy airtime
- [ ] Buy data (with network selection)
- [ ] Buy electricity
- [ ] Buy TV subscription
- [ ] Wallet balance loads
- [ ] Wallet transaction history
- [ ] Withdrawal flow
- [ ] Change PIN
- [ ] Profile update
- [ ] Logout
- [ ] Dark/light theme toggle

### New Feature Verification
- [ ] 2FA: normal login not broken; 2FA OTP screen appears when backend sends `requires_2fa: true`
- [ ] PIN sheet: appears before each purchase; dismissible; correct PIN proceeds
- [ ] Support: create ticket → chat UI → send message → close ticket
- [ ] Notifications: list loads; mark read updates badge count
- [ ] KYC: status loads; form submits with image
- [ ] Referral: code displays; share works
- [ ] Beneficiary: save on purchase; autofill on next purchase
- [ ] Repeat: tapping repeat on history item shows PIN sheet then repeats
- [ ] P2P: phone lookup → confirm card → amount → PIN → success
