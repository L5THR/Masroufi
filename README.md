# 📱 MASROUFI - Job Portal Application

**A comprehensive Flutter-based job portal connecting job seekers with recruiters**

[![Flutter](https://img.shields.io/badge/Flutter-3.x-blue.svg)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.x-blue.svg)](https://dart.dev/)
[![BLoC](https://img.shields.io/badge/State-BLoC%2FCubit-orange.svg)](https://bloclibrary.dev/)
[![Backend](https://img.shields.io/badge/Backend-Spring%20Boot-green.svg)](https://spring.io/)

---

## 🎯 Project Overview

MASROUFI is a modern, feature-rich job portal mobile application that facilitates connections between job seekers and recruiters. Built with Flutter and Spring Boot, it provides dual interfaces optimized for both user types with advanced features like quiz assessments, real-time chat, and comprehensive application tracking.

### **Key Features:**
- 🔐 Complete authentication system with role-based access
- 👥 Dual interfaces (Job Seeker & Recruiter)
- 📱 Guest browsing capability
- 🎯 Advanced job filtering and search
- 📝 Quiz system for candidate assessment
- 💬 Chat functionality
- 📊 Application tracking and management
- 🖼️ Profile management with file uploads
- 🎨 Dark/Light theme support

---

## 🚀 Quick Start

### **Prerequisites:**
- Flutter SDK 3.x or higher
- Dart SDK 3.x or higher
- Android Studio / VS Code
- Backend server running (Spring Boot)

### **Installation:**

```bash
# Clone the repository
git clone <repository-url>
cd Flutter-4ALLINFO9

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### **Backend Setup:**
The app connects to a Spring Boot backend. Ensure the backend server is running:
- **API Base URL:** Update in `lib/core/network/dio_client.dart`
- **API Documentation:** See `fixed_api_spec.json`

---

## 📋 Documentation

### **📚 Main Documentation:**
- **[COMPREHENSIVE_PROJECT_SUMMARY.md](COMPREHENSIVE_PROJECT_SUMMARY.md)** ⭐ - Complete project overview, features, architecture, and status
- **[PROJECT_STATUS_AND_ROADMAP.md](PROJECT_STATUS_AND_ROADMAP.md)** - Current status, test credentials, and roadmap
- **[BACKEND_ISSUES_TRACKER.md](BACKEND_ISSUES_TRACKER.md)** - Backend issues and solutions

### **🎯 Feature Guides:**
- **[QUIZ_QUICK_START.md](QUIZ_QUICK_START.md)** - How to use the quiz system
- **[QUIZ_INTEGRATION_GUIDE.md](QUIZ_INTEGRATION_GUIDE.md)** - Technical quiz integration
- **[PROFILE_FEATURES_COMPLETE.md](PROFILE_FEATURES_COMPLETE.md)** - Profile editing guide
- **[IMPROVEMENTS_COMPLETED.md](IMPROVEMENTS_COMPLETED.md)** - Auth and error handling improvements

### **🔌 API & Integration:**
- **[IMPLEMENTABLE_FEATURES_NOW.md](IMPLEMENTABLE_FEATURES_NOW.md)** - Available API features
- **[CHAT_FEATURE_ANALYSIS.md](CHAT_FEATURE_ANALYSIS.md)** - Chat feature roadmap
- **[fixed_api_spec.json](fixed_api_spec.json)** - Complete OpenAPI specification

---

## 🏗️ Architecture

### **State Management:**
- **BLoC/Cubit Pattern** for predictable state management
- Separate Cubits for each feature domain
- Clean separation between UI and business logic

### **Project Structure:**
```
lib/
├── core/                     # Core utilities & configuration
│   ├── app_theme.dart       # Theme configuration
│   ├── network/             # HTTP client & error handling
│   ├── storage/             # Local storage (Hive)
│   └── utils/               # Utilities & helpers
│
├── views/                    # Feature modules
│   ├── auth/                # Authentication
│   ├── home/                # Job Seeker features
│   ├── recruiter/           # Recruiter features
│   ├── jobs/                # Job browsing & management
│   ├── applications/        # Application tracking
│   ├── quiz/                # Quiz system
│   ├── chat/                # Chat feature
│   └── widgets/             # Shared widgets
│
└── main.dart                 # App entry point
```

---

## ✅ Feature Status

| Feature | Job Seeker | Recruiter | Status |
|---------|-----------|-----------|--------|
| **Authentication** | ✅ Register, Login | ✅ Register, Login | 100% |
| **Profile Management** | ✅ Edit, Upload CV | ✅ Edit, Upload Logo | 100% |
| **Job Browsing** | ✅ Search, Filter, View | ✅ Create, Edit, Delete | 95% |
| **Applications** | ✅ Apply, Track | ⚠️ View (blocked) | 80% |
| **Saved Jobs** | ✅ Save, View List | N/A | 100% |
| **Quiz System** | ✅ Take, View Results | ✅ Create (no edit) | 85% |
| **Chat** | ⚠️ View only | ⚠️ View only | 40% |
| **Notifications** | ✅ View, Mark Read | ✅ View, Mark Read | 100% |
| **Theme** | ✅ Dark/Light | ✅ Dark/Light | 100% |
| **Guest Browsing** | ✅ Browse jobs | N/A | 100% |

**Overall:** 80% complete (28/35 API endpoints integrated)

---

## 🔧 Technologies Used

### **Frontend:**
- **Flutter** 3.x - UI framework
- **Dart** 3.x - Programming language
- **flutter_bloc** - State management
- **dio** - HTTP client
- **hive** - Local storage
- **image_picker** - Image selection
- **file_picker** - File selection

### **Backend:**
- **Spring Boot** - Java framework
- **PostgreSQL** - Database
- **JWT** - Authentication
- **OpenAPI 3.0** - API specification

---

## 🧪 Testing

### **Test Credentials:**
See **[PROJECT_STATUS_AND_ROADMAP.md](PROJECT_STATUS_AND_ROADMAP.md)** for:
- Job seeker test accounts
- Recruiter test accounts
- Admin credentials

### **Test Scripts:**
```bash
# Populate test data
./scripts/populate_complete.sh

# Test job creation
./scripts/test_job_creation.sh

# Check categories
./scripts/check_categories.sh
```

---

## ⚠️ Known Issues

### **Backend Issues (Require backend fixes):**

1. **Applicants Display Error** 🔴 CRITICAL
   - **Problem:** Hibernate serialization error
   - **Impact:** Cannot view job applicants
   - **Solution:** Documented in BACKEND_ISSUES_TRACKER.md Issue #1

2. **Chat POST Endpoint Missing** 🔴 CRITICAL
   - **Problem:** No endpoint to send messages
   - **Impact:** Chat is read-only
   - **Solution:** Documented in BACKEND_ISSUES_TRACKER.md Issue #2

3. **Quiz Edit/Delete Not Available** 🟡 MEDIUM
   - **Problem:** Each job can have only one quiz, no edit endpoint
   - **Impact:** Cannot modify quiz after creation
   - **Solution:** Documented in BACKEND_ISSUES_TRACKER.md Issue #3

**All issues documented with complete solution code ready for backend team.**

---

## 📊 Project Stats

- **Files Created/Modified:** 150+
- **Lines of Code:** 15,000+
- **Features Implemented:** 12 major features
- **API Endpoints Integrated:** 28/35 (80%)
- **Documentation Files:** 15
- **Development Time:** 60-80 hours

---

## 🗺️ Roadmap

### **Immediate (Backend Required):**
1. Fix applicants display (Issue #1)
2. Add chat POST endpoint (Issue #2)
3. Add quiz edit/delete (Issue #3)

### **Short Term (Frontend):**
1. Pull-to-refresh on lists
2. Loading skeletons
3. Infinite scroll
4. Advanced search filters

### **Medium Term:**
1. Notifications UI
2. Reviews & Ratings UI
3. Admin panel UI
4. Unit & widget tests

### **Long Term:**
1. Real-time chat (WebSocket)
2. Video interviews
3. Advanced analytics
4. Mobile-specific features (push notifications, etc.)

---

## 📞 Support

**Developer:** Jihed Mrouki
**Email:** jihedmrouki@yahoo.fr
**Project:** 4ALLINFO9

For detailed information:
- 📖 Read [COMPREHENSIVE_PROJECT_SUMMARY.md](COMPREHENSIVE_PROJECT_SUMMARY.md)
- 🐛 Check [BACKEND_ISSUES_TRACKER.md](BACKEND_ISSUES_TRACKER.md)
- 📋 Review [PROJECT_STATUS_AND_ROADMAP.md](PROJECT_STATUS_AND_ROADMAP.md)

---

## 📄 License

This project is part of an academic course (4ALLINFO9).

---

## 🙏 Acknowledgments

Built with Flutter and Spring Boot as part of the 4ALLINFO9 course project.

**Total Features:** 12 major features
**Backend Integration:** 80% complete
**Documentation:** Comprehensive guides available

---

**Made with ❤️ and lots of ☕**

---
