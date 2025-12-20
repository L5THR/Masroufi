# User Profile Management Feature - Implementation Guide

**Date:** 2025-12-20
**Status:** ✅ READY TO TEST
**Feature:** View and Update User Profiles (Job Seeker & Recruiter)

---

## 🎯 Feature Overview

The user profile management feature allows both Job Seekers and Recruiters to:
- ✅ View their current profile information
- ✅ Update their profile details
- ✅ Upload profile pictures / company logos
- ✅ Does NOT require backend pagination fixes (uses simple PUT endpoints)

---

## 📁 Implementation Details

### 1. Data Layer
**File:** `lib/views/auth/data/repositories/user_repository.dart`

**Methods:**
- `getMe()` - `GET /api/users/me` - Fetch current user profile
- `updateJobSeekerProfile()` - `PUT /api/users/me/job-seeker-profile` - Update job seeker
- `updateRecruiterProfile()` - `PUT /api/users/me/recruiter-profile` - Update recruiter

### 2. Business Logic Layer
**Files:**
- `lib/views/auth/logic/cubit/user_cubit.dart` - State management
- `lib/views/auth/logic/cubit/user_state.dart` - States definition

**States:**
- `UserInitial` - Initial state
- `UserLoading` - Fetching user data
- `UserLoaded` - User data loaded
- `UserUpdating` - Updating profile
- `UserError` - Error occurred

### 3. Presentation Layer

**Job Seeker Profile:**
- **File:** `lib/views/home/presentation/pages/edit_job_seeker_profile.dart`
- **Route:** `/edit-job-seeker-profile`
- **Fields:**
  - First Name (required)
  - Last Name (required)
  - Phone Number (optional)
  - Profile Picture (optional - with image picker)

**Recruiter Profile:**
- **File:** `lib/views/recruiter/presentation/pages/edit_recruiter_profile.dart`
- **Route:** `/edit-recruiter-profile`
- **Fields:**
  - Company Name (required)
  - Website (optional - with URL validation)
  - Company Logo (optional - with image picker)

### 4. Data Models

**Job Seeker Profile:**
```dart
class JobSeekerProfile {
  final int id;
  final String firstName;
  final String lastName;
  final String? phoneNumber;
  final String? cvUrl;
  final String? profilePictureUrl;
}
```

**Recruiter Profile:**
```dart
class RecruiterProfile {
  final int id;
  final String companyName;
  final String? companyLogoUrl;
  final String? website;
}
```

**Me Response:**
```dart
class MeResponse {
  final int id;
  final String email;
  final String role;  // JOB_SEEKER, RECRUITER, ADMIN
  final String status;  // ACTIVE, BLOCKED
  final JobSeekerProfile? jobSeekerProfile;
  final RecruiterProfile? recruiterProfile;
}
```

---

## 🧪 How to Test

### Test 1: Job Seeker Profile Update

#### Prerequisites
- Backend running at `http://51.91.111.185:8088`
- Logged in as a Job Seeker

#### Steps:
1. **Login as Job Seeker**
   ```
   Email: [your job seeker email]
   Password: [your password]
   ```

2. **Navigate to Edit Profile**
   - From home screen, tap profile icon or menu
   - Select "Edit Profile"
   - **Expected Console Log:**
     ```
     📡 Fetching current user profile...
     📡 Endpoint: /api/users/me
     ✅ User profile fetched successfully
     ✅ Role: JOB_SEEKER, Email: [email]
     ✅ Form initialized with user data
     ```

3. **Update Profile Information**
   - Change first name to "Updated"
   - Change phone number to "+1234567890"
   - Tap "Update Profile"
   - **Expected Console Log:**
     ```
     🔵 Update profile button clicked
     ✅ Form validation passed
     🔵 Calling updateJobSeekerProfile...
     📡 Updating job seeker profile...
     📡 Endpoint: /api/users/me/job-seeker-profile
     📡 Data: {firstName: Updated, lastName: ..., phoneNumber: +1234567890}
     ✅ Job seeker profile updated successfully
     ✅ Profile updated successfully
     ```

4. **With Profile Picture Upload**
   - Tap camera icon
   - Select an image
   - **Expected Console Log:**
     ```
     📸 Opening image picker for profile picture
     ✅ Profile image selected: /path/to/image.jpg
     ```
   - Tap "Update Profile"
   - **Expected Console Log:**
     ```
     📤 Uploading profile picture...
     ✅ Profile picture uploaded: https://...
     📡 Updating job seeker profile...
     ✅ Job seeker profile updated successfully
     ```

#### Success Indicators:
- ✅ Green SnackBar: "✅ Profile updated successfully!"
- ✅ Navigate back to home screen
- ✅ Changes persist on next profile view

---

### Test 2: Recruiter Profile Update

#### Prerequisites
- Backend running
- Logged in as a Recruiter

#### Steps:
1. **Login as Recruiter**
   ```
   Email: [your recruiter email]
   Password: [your password]
   ```

2. **Navigate to Edit Profile**
   - From recruiter home, tap profile icon or menu
   - Select "Edit Profile"
   - **Expected Console Log:**
     ```
     📡 Fetching current user profile...
     ✅ User profile fetched successfully
     ✅ Role: RECRUITER, Email: [email]
     ✅ Form initialized with recruiter data
     ```

3. **Update Company Information**
   - Change company name to "Updated Tech Corp"
   - Add/change website to "https://www.example.com"
   - Tap "Update Profile"
   - **Expected Console Log:**
     ```
     🔵 Update recruiter profile button clicked
     ✅ Form validation passed
     🔵 Calling updateRecruiterProfile...
     📡 Updating recruiter profile...
     📡 Endpoint: /api/users/me/recruiter-profile
     📡 Data: {companyName: Updated Tech Corp, website: https://...}
     ✅ Recruiter profile updated successfully
     ✅ Recruiter profile updated successfully
     ```

4. **With Company Logo Upload**
   - Tap camera icon on logo
   - Select an image
   - **Expected Console Log:**
     ```
     📸 Opening image picker for company logo
     ✅ Company logo selected: /path/to/logo.jpg
     ```
   - Tap "Update Profile"
   - **Expected Console Log:**
     ```
     📤 Uploading company logo...
     ✅ Company logo uploaded: https://...
     📡 Updating recruiter profile...
     ✅ Recruiter profile updated successfully
     ```

#### Success Indicators:
- ✅ Green SnackBar: "✅ Profile updated successfully!"
- ✅ Navigate back to home screen
- ✅ Updated company name shows in job listings

---

## 🔍 Troubleshooting

### Issue: Profile data not loading (blank form)
**Console Log:**
```
❌ Failed to fetch user profile: 401
```
**Cause:** Token expired or not authenticated
**Solution:**
1. Logout and login again
2. Check if token is being sent: Look for `Authorization: Bearer` in headers
3. Verify token in storage

### Issue: Update fails with 403 Forbidden
**Console Log:**
```
❌ Failed to update job seeker profile: 403
❌ Error: {message: "Access denied"}
```
**Cause:** Backend authorization issue
**Solution:**
1. Verify you're logged in with correct role
2. Check JWT token role matches (JOB_SEEKER or RECRUITER)
3. Backend may need to allow profile updates for authenticated users

### Issue: Form validation fails
**Console Log:**
```
❌ Form validation failed
```
**Cause:** Required fields are empty
**Solution:**
1. First name and last name are required for job seekers
2. Company name is required for recruiters
3. Website must start with http:// or https:// if provided

### Issue: Image picker not opening
**Console Log:**
```
❌ Error picking image: ...
```
**Cause:** Missing permissions or platform issue
**Solution:**
1. **iOS:** Add to `ios/Runner/Info.plist`:
   ```xml
   <key>NSPhotoLibraryUsageDescription</key>
   <string>We need access to your photos to update your profile picture</string>
   ```
2. **Android:** Add to `android/app/src/main/AndroidManifest.xml`:
   ```xml
   <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
   ```

### Issue: File upload fails
**Console Log:**
```
❌ Failed to upload profile picture: ...
```
**Cause:** File upload endpoint issue (from backend_api_fixes_required.md)
**Solution:**
1. Check if backend accepts multipart/form-data
2. Verify file upload endpoint is working
3. Try updating profile without image first

---

## 📊 API Contracts

### 1. Get Current User
```http
GET /api/users/me
Authorization: Bearer [token]
```

**Response (Job Seeker):**
```json
{
  "id": 1,
  "email": "john@example.com",
  "role": "JOB_SEEKER",
  "status": "ACTIVE",
  "jobSeekerProfile": {
    "id": 1,
    "firstName": "John",
    "lastName": "Doe",
    "phoneNumber": "+1234567890",
    "cvUrl": null,
    "profilePictureUrl": "https://..."
  },
  "recruiterProfile": null
}
```

**Response (Recruiter):**
```json
{
  "id": 2,
  "email": "recruiter@company.com",
  "role": "RECRUITER",
  "status": "ACTIVE",
  "jobSeekerProfile": null,
  "recruiterProfile": {
    "id": 1,
    "companyName": "Tech Corp",
    "website": "https://www.techcorp.com",
    "companyLogoUrl": "https://..."
  }
}
```

### 2. Update Job Seeker Profile
```http
PUT /api/users/me/job-seeker-profile
Authorization: Bearer [token]
Content-Type: application/json

{
  "firstName": "John",
  "lastName": "Doe",
  "phoneNumber": "+1234567890",
  "profilePictureUrl": "https://..."
}
```

**Response:** Same as GET /api/users/me

### 3. Update Recruiter Profile
```http
PUT /api/users/me/recruiter-profile
Authorization: Bearer [token]
Content-Type: application/json

{
  "companyName": "Tech Corp",
  "website": "https://www.techcorp.com",
  "companyLogoUrl": "https://..."
}
```

**Response:** Same as GET /api/users/me

---

## 🎨 UI Features

### Job Seeker Edit Profile Screen
- ✅ Circular profile picture with camera overlay
- ✅ First name and last name fields
- ✅ Optional phone number field
- ✅ Form validation
- ✅ Loading state during update
- ✅ Success/error feedback with SnackBars

### Recruiter Edit Profile Screen
- ✅ Square company logo with camera overlay
- ✅ Company name field
- ✅ Optional website field with URL validation
- ✅ Form validation
- ✅ Loading state during update
- ✅ Success/error feedback with SnackBars

### Shared Features
- ✅ Auto-populated form fields from API
- ✅ Disabled fields during update
- ✅ Image picker integration
- ✅ File upload with progress indication
- ✅ Dark/light theme support
- ✅ Responsive layout

---

## ✅ Testing Checklist

### Job Seeker Profile
- [ ] Login as job seeker
- [ ] Navigate to edit profile
- [ ] Verify form is populated with current data
- [ ] Update first name
- [ ] Update last name
- [ ] Update phone number
- [ ] Click camera icon and select image
- [ ] Verify image preview updates
- [ ] Tap "Update Profile"
- [ ] Check console for success logs
- [ ] Verify green SnackBar appears
- [ ] Verify navigation back to home
- [ ] Navigate to edit profile again
- [ ] Verify changes persisted

### Recruiter Profile
- [ ] Login as recruiter
- [ ] Navigate to edit profile
- [ ] Verify form is populated with current data
- [ ] Update company name
- [ ] Update website (with https://)
- [ ] Try invalid URL (without https://)
- [ ] Verify validation error appears
- [ ] Fix URL format
- [ ] Click camera icon and select logo
- [ ] Verify logo preview updates
- [ ] Tap "Update Profile"
- [ ] Check console for success logs
- [ ] Verify green SnackBar appears
- [ ] Verify navigation back to home
- [ ] Navigate to edit profile again
- [ ] Verify changes persisted

### Error Scenarios
- [ ] Try updating without changing anything
- [ ] Try updating with empty required fields
- [ ] Try updating with invalid URL format
- [ ] Logout and try to access profile (should redirect)
- [ ] Update profile with very long text values

---

## 🎯 Summary

The user profile management feature is **fully implemented and ready to test**. It:
- ✅ Uses simple GET and PUT endpoints (no pagination issues)
- ✅ Has comprehensive form validation
- ✅ Has debug logging for easy troubleshooting
- ✅ Supports image upload for profile pictures/logos
- ✅ Has good UI/UX with loading states and feedback
- ✅ Should work with current backend (no fixes required for core functionality)

**Note:** File upload might have issues if backend hasn't fixed the content-type (see backend_api_fixes_required.md Issue #4). You can still test profile updates without images.

---

## 🚀 Next Steps

Once profile management is working:

1. **Test without image upload first** - Verify basic profile updates work
2. **Test image upload** - Upload profile pictures/company logos
3. **Verify persistence** - Logout and login again, check if updates persisted
4. **Profile completion** - Ensure users complete profiles before applying to jobs
5. **Profile display** - Show profile info in home screens and job applications

Share the console logs if you encounter any issues!
