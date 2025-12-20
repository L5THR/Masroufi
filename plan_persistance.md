# 🗺️ Complete API Integration Master Plan

## 📦 Phase 0: Setup & Dependencies

### Step 0.1: Install Required Packages

Add to `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  flutter_bloc: ^8.1.3
  equatable: ^2.0.5
  
  # Networking
  dio: ^5.4.0
  
  # Local Storage
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  flutter_secure_storage: ^9.0.0
  path_provider: ^2.1.1
  
  # Utilities
  intl: ^0.18.1
  
dev_dependencies:
  hive_generator: ^2.0.1
  build_runner: ^2.4.6
  flutter_lints: ^3.0.0
```

Run:
```bash
flutter pub get
flutter pub run build_runner build
```

---

## 🏗️ Phase 1: Core Foundation (Day 1)

### ✅ Already Done:
- [x] DioClient setup
- [x] ApiEndpoints
- [x] Auth models & repository
- [x] Auth Cubit & State
- [x] Login & Register screens

### 🔧 Step 1.1: Setup Hive for Local Storage

**Create:** `core/storage/hive_storage.dart`

```dart
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class HiveStorage {
  static late Box _authBox;
  static late Box _userBox;
  static late Box _settingsBox;
  static const _secureStorage = FlutterSecureStorage();
  
  static Future<void> init() async {
    await Hive.initFlutter();
    
    // Open boxes
    _authBox = await Hive.openBox('auth');
    _userBox = await Hive.openBox('user');
    _settingsBox = await Hive.openBox('settings');
  }
  
  // Auth Token Management
  static Future<void> saveToken(String token) async {
    await _secureStorage.write(key: 'auth_token', value: token);
    await _authBox.put('token_timestamp', DateTime.now().millisecondsSinceEpoch);
  }
  
  static Future<String?> getToken() async {
    return await _secureStorage.read(key: 'auth_token');
  }
  
  static Future<void> saveRefreshToken(String token) async {
    await _secureStorage.write(key: 'refresh_token', value: token);
  }
  
  static Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: 'refresh_token');
  }
  
  static Future<void> clearAuth() async {
    await _secureStorage.delete(key: 'auth_token');
    await _secureStorage.delete(key: 'refresh_token');
    await _authBox.clear();
  }
  
  // User Data
  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    await _userBox.put('user_data', userData);
  }
  
  static Map<String, dynamic>? getUserData() {
    return _userBox.get('user_data');
  }
  
  static Future<void> clearUserData() async {
    await _userBox.clear();
  }
  
  // Settings
  static Future<void> saveThemeMode(String mode) async {
    await _settingsBox.put('theme_mode', mode);
  }
  
  static String getThemeMode() {
    return _settingsBox.get('theme_mode', defaultValue: 'dark');
  }
  
  static Future<void> clearAll() async {
    await clearAuth();
    await clearUserData();
    await _settingsBox.clear();
  }
}
```

### 🔧 Step 1.2: Update main.dart

```dart
import 'package:flutter/material.dart';
import 'core/storage/hive_storage.dart';
import 'core/network/dio_client.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await HiveStorage.init();
  
  // Load saved token
  final token = await HiveStorage.getToken();
  if (token != null) {
    DioClient.instance.setAuthToken(token);
  }
  
  runApp(const MasroufiApp());
}
```

### 🔧 Step 1.3: Update Auth Flow to Save Data

**Update:** `views/auth/logic/auth_cubit.dart`

Add after successful login:
```dart
if (state is AuthLoginSuccess) {
  // Save token
  await HiveStorage.saveToken(response.accessToken);
  await HiveStorage.saveRefreshToken(response.refreshToken);
  
  // Save basic user info
  await HiveStorage.saveUserData({
    'role': response.role,
    'status': response.status,
  });
  
  // Set token in Dio
  DioClient.instance.setAuthToken(response.accessToken);
}
```

---

## 📱 Phase 2: Profile Module (Day 2)

### Priority: HIGH (Needed for user context)

### Files to Create:

```
lib/views/profile/
├── data/
│   ├── models/
│   │   └── user_profile.dart
│   └── repositories/
│       └── profile_repository.dart
├── logic/
│   ├── profile_cubit.dart
│   └── profile_state.dart
└── presentation/
    └── pages/
        ├── view_profile_screen.dart
        ├── edit_job_seeker_profile_screen.dart
        └── edit_recruiter_profile_screen.dart
```

**I'll provide the complete code for this module.**

---

## 💼 Phase 3: Jobs Module Enhancement (Day 3-4)

### Priority: HIGH (Core feature)

### Tasks:
1. ✅ Models (Already done)
2. ✅ Repository (Already done)
3. ✅ Cubit & State (Already done)
4. 🔄 Integrate into existing screens:
   - `job_seeker_home_screen.dart` - List jobs
   - `job_details_screen.dart` - Show job details
   - `recruiter_home_screen.dart` - Show my jobs
   - `create_job_screen.dart` - Create new job
   - `edit_job_screen.dart` - Edit job

**I'll update each of your existing screens.**

---

## 📝 Phase 4: Applications Module (Day 5)

### Priority: HIGH (Core feature)

### Tasks:
1. ✅ Models (Already done)
2. ✅ Repository (Already done)
3. ✅ Cubit & State (Already done)
4. 🔄 Integrate into screens:
   - Job Details: Add "Apply" button
   - Create "My Applications" screen
   - Create "Application Management" screen (Recruiter)

**I'll provide updated screens.**

---

## 🔖 Phase 5: Saved Jobs Module (Day 6)

### Priority: MEDIUM

### Files to Create:

```
lib/views/saved_jobs/
├── data/
│   ├── models/
│   │   └── saved_job.dart
│   └── repositories/
│       └── saved_job_repository.dart
├── logic/
│   ├── saved_job_cubit.dart
│   └── saved_job_state.dart
└── presentation/
    └── pages/
        └── saved_jobs_screen.dart
```

**I'll provide complete implementation.**

---

## 📂 Phase 6: File Upload Module (Day 7)

### Priority: HIGH (Needed for CV, profile pics)

### Files to Create:

```
lib/views/file_upload/
├── data/
│   └── repositories/
│       └── file_upload_repository.dart
├── logic/
│   ├── file_upload_cubit.dart
│   └── file_upload_state.dart
└── presentation/
    └── widgets/
        ├── file_picker_widget.dart
        └── image_picker_widget.dart
```

**I'll provide complete implementation with image_picker & file_picker.**

---

## 🔔 Phase 7: Notifications Module (Day 8)

### Priority: MEDIUM

### Files to Create:

```
lib/views/notifications/
├── data/
│   ├── models/
│   │   └── notification.dart
│   └── repositories/
│       └── notification_repository.dart
├── logic/
│   ├── notification_cubit.dart
│   └── notification_state.dart
└── presentation/
    └── pages/
        └── notifications_screen.dart
```

---

## 📝 Phase 8: Quiz Module (Day 9-10)

### Priority: MEDIUM

### Files to Create:

```
lib/views/quiz/
├── data/
│   ├── models/
│   │   ├── quiz.dart
│   │   ├── question.dart
│   │   ├── option.dart
│   │   └── quiz_attempt.dart
│   └── repositories/
│       └── quiz_repository.dart
├── logic/
│   ├── quiz_cubit.dart
│   └── quiz_state.dart
└── presentation/
    └── pages/
        ├── quiz_screen.dart (update existing)
        ├── create_quiz_screen.dart
        └── quiz_attempts_screen.dart
```

---

## 💬 Phase 9: Chat Module (Day 11-12)

### Priority: LOW (Can be last)

### Files to Create:

```
lib/views/chat/
├── data/
│   ├── models/
│   │   └── chat_message.dart (update existing)
│   ├── repositories/
│   │   └── chat_repository.dart
│   └── services/
│       └── websocket_service.dart (update existing)
├── logic/
│   ├── chat_cubit.dart (update existing)
│   └── chat_state.dart (update existing)
└── presentation/
    └── pages/
        └── chat_page.dart (update existing)
```

---

## ⭐ Phase 10: Reviews & Reports (Day 13)

### Priority: LOW

### Files to Create:

```
lib/views/reviews/
└── [similar structure]

lib/views/reports/
└── [similar structure]
```

---

## 👨‍💼 Phase 11: Admin Module (Day 14-15)

### Priority: MEDIUM (If you have admin features)

### Files to Create:

```
lib/views/admin/
├── data/
│   ├── models/
│   │   ├── dashboard_stats.dart
│   │   └── activity.dart
│   └── repositories/
│       └── admin_repository.dart
├── logic/
│   ├── admin_cubit.dart
│   └── admin_state.dart
└── presentation/
    └── pages/
        └── admin_dashboard_screen.dart (update existing)
```

---

## 🔄 Phase 12: Global State Management (Day 16)

### Setup App-Level BLoC Providers

**Update:** `main.dart`

```dart
MultiBlocProvider(
  providers: [
    // Global auth state
    BlocProvider(
      create: (context) => AuthCubit(AuthRepository())
        ..checkAuthStatus(),
    ),
    
    // Global profile state
    BlocProvider(
      create: (context) => ProfileCubit(ProfileRepository()),
    ),
    
    // Global notification state
    BlocProvider(
      create: (context) => NotificationCubit(NotificationRepository()),
    ),
  ],
  child: MaterialApp(...),
)
```

---

## 📊 Integration Timeline

### Week 1: Core Features
- **Day 1**: Setup Hive + Token Management
- **Day 2**: Profile Module
- **Day 3-4**: Jobs Module Integration
- **Day 5**: Applications Module

### Week 2: Additional Features
- **Day 6**: Saved Jobs
- **Day 7**: File Upload
- **Day 8**: Notifications
- **Day 9-10**: Quiz Module

### Week 3: Advanced Features
- **Day 11-12**: Chat Module
- **Day 13**: Reviews & Reports
- **Day 14-15**: Admin Module
- **Day 16**: Global State & Testing

---

## 🎯 Daily Workflow

Each day, we'll follow this pattern:

### 1. **You Provide:**
```
"Here's my [screen_name].dart file"
[paste code]
```

### 2. **I'll Provide:**
- ✅ Complete models
- ✅ Complete repository
- ✅ Complete cubit & state
- ✅ Updated screen with BLoC integration
- ✅ Example usage

### 3. **You Implement:**
- Copy files to correct locations
- Test the feature
- Report any issues

### 4. **We Move to Next Feature**

---

## 📝 What I Need From You Each Day

### Format:
```
**Current Phase:** [e.g., Phase 3: Jobs Module]
**Screen:** [e.g., job_seeker_home_screen.dart]

**Current Code:**
```dart
// Your existing screen code
```

**What I need:**
- [ ] Display list of jobs
- [ ] Search functionality
- [ ] Filter by category
- [ ] Pull to refresh
```

---

## 🛠️ Tools We'll Use

### State Management:
- `flutter_bloc` for all state management
- `BlocProvider` for dependency injection
- `BlocBuilder` for UI updates
- `BlocListener` for side effects
- `BlocConsumer` for both

### Storage:
- `hive` for local data persistence
- `flutter_secure_storage` for sensitive data (tokens)
- Cached user profile
- Cached categories
- Cached recent jobs

### Best Practices:
- Repository pattern for API calls
- Single Responsibility Principle
- Error handling at all levels
- Loading states
- Empty states
- Retry mechanisms

---

## 🎯 Success Criteria

For each module, we ensure:
- ✅ API calls work correctly
- ✅ Loading states shown
- ✅ Error messages displayed
- ✅ Data persists locally
- ✅ Pull to refresh works
- ✅ Pagination implemented
- ✅ User feedback provided

---

## 🚀 Let's Start!

### **Ready to Begin with Phase 1?**

I'll help you:
1. Setup Hive storage
2. Implement token persistence
3. Update auth flow to save data

**Just say:** "Let's start with Phase 1" and share your current `main.dart` file, and we'll begin! 🎉

---

## 📌 Quick Reference

### File Structure We'll Build:
```
lib/
├── core/
│   ├── network/
│   │   ├── dio_client.dart ✅
│   │   └── api_result.dart ✅
│   ├── storage/
│   │   └── hive_storage.dart 🔄 (Next)
│   └── utils/
│       └── endpoints.dart ✅
│
└── views/
    ├── auth/ ✅ DONE
    ├── profile/ 📝 Phase 2
    ├── jobs/ 🔄 Phase 3
    ├── applications/ 🔄 Phase 4
    ├── saved_jobs/ 📝 Phase 5
    ├── file_upload/ 📝 Phase 6
    ├── notifications/ 📝 Phase 7
    ├── quiz/ 📝 Phase 8
    ├── chat/ 📝 Phase 9
    ├── reviews/ 📝 Phase 10
    └── admin/ 📝 Phase 11
```

---

## 💪 You Got This!

We'll go **one module at a time**, no rush. Each day, we complete one feature properly with:
- Full BLoC integration
- Hive persistence
- Error handling
- Loading states
- Beautiful UI updates

**Ready when you are!** 🚀