# Backend Integration Plan - MASROUFI

> A comprehensive task list for integrating all API endpoints into the Flutter application, organized by SCREEN.

---

## Table of Contents

1. [Project Overview](#project-overview)
2. [Integration Approach](#integration-approach)
3. [Screen-by-Screen Integration Plan](#screen-by-screen-integration-plan)
   - [🟢 Phase 1: Recruiter Module](#phase-1-recruiter-module-priority-1)
   - [Phase 2: Job Seeker Module](#phase-2-job-seeker-module)
   - [Phase 3: Applications Module](#phase-3-applications-module)
   - [Phase 4: Communication Module](#phase-4-communication-module)
   - [Phase 5: Admin Module](#phase-5-admin-module)
4. [API Endpoints Reference](#api-endpoints-reference)

---

## Project Overview

**App Name:** MASROUFI
**Purpose:** Platform connecting students (job seekers) with recruiters for small jobs/tasks
**Base URL:** `http://51.91.111.185:8088`
**WebSocket URL:** `ws://51.91.111.185:8088/ws/chat`

### Tech Stack
- **State Management:** flutter_bloc (Cubits)
- **HTTP Client:** Dio
- **Local Storage:** hive_ce + flutter_secure_storage
- **WebSocket:** web_socket_channel (prepared, not active)

---

## Integration Approach

**Philosophy:** Screen-Based Dynamic Integration

Instead of building features in isolation, we integrate APIs directly into screens to make them dynamic and functional. Each screen becomes fully operational before moving to the next.

**Benefits:**
- ✅ Immediate user-facing value
- ✅ Easier testing (test complete flows)
- ✅ Better progress visibility
- ✅ Reduced integration issues

**Process Per Screen:**
1. **Analyze** - Understand screen requirements and API endpoints
2. **Model** - Create/verify data models match API response
3. **Repository** - Implement API calls in repository layer
4. **Cubit** - Create state management logic
5. **UI Integration** - Connect screen to cubit and handle states
6. **Test** - Verify end-to-end functionality

---

## Screen-by-Screen Integration Plan

---

## Phase 1: Recruiter Module (PRIORITY 1)

### 🎯 Goal
Complete all recruiter job management functionality to allow recruiters to fully manage their job postings.

---

### Screen 1: Create Job Screen
**File:** `lib/views/recruiter/presentation/pages/create_job_screen.dart`
**Status:** ✅ **COMPLETE** - Fully integrated with API

**Implemented Features:**
- ✅ Fetch categories from API
- ✅ Form validation
- ✅ Image upload to server
- ✅ Create job API call
- ✅ Success/error handling
- ✅ Navigation back on success

**API Endpoints Used:**
- `GET /api/categories` - Fetch job categories
- `POST /api/files/upload` - Upload job image
- `POST /api/jobs` - Create new job

**Models Used:**
- `Category` - Job categories
- `JobRequest` - Create job request
- `Job` - Job response

**State Management:**
- `CreateJobCubit` - Handles job creation logic
- States: `CreateJobInitial`, `CreateJobLoading`, `CreateJobSuccess`, `CreateJobFailure`

---

### Screen 2: Recruiter Home Screen
**File:** `lib/views/recruiter/presentation/pages/recruiter_home_screen.dart`
**Status:** ⚠️ **PARTIAL** - List jobs works, needs delete & pagination

**Implemented Features:**
- ✅ Fetch recruiter's jobs
- ✅ Display jobs list
- ✅ Navigate to edit job
- ✅ Navigate to view job details
- ✅ Navigate to view applications
- ⚠️ Pull-to-refresh (exists but could be improved)

**Needs Implementation:**
- ❌ Delete job functionality
- ❌ Pagination/infinite scroll
- ❌ Filter jobs by status (OPEN/CLOSED/FLAGGED)
- ❌ Close job action

**API Endpoints:**
- ✅ `GET /api/jobs/recruiters/me/jobs` - Get recruiter's jobs
- ❌ `DELETE /api/jobs/{id}` - Delete job (not implemented)
- ❌ `PUT /api/jobs/{id}` - Update job status (not used for closing)

**Models Used:**
- `PaginatedResponse<Job>` - Paginated jobs list
- `Job` - Job details

**State Management:**
- `RecruiterJobsCubit` - Handles fetching jobs
- States: `RecruiterJobsInitial`, `RecruiterJobsLoading`, `RecruiterJobsLoaded`, `RecruiterJobsFailure`

**Tasks:**
1. ❌ Add delete job method to `JobRepository`
2. ❌ Add delete job method to `RecruiterJobsCubit`
3. ❌ Add delete confirmation dialog in UI
4. ❌ Implement pagination with `hasNextPage` check
5. ❌ Add status filter chips

---

### Screen 3: Edit Job Screen
**File:** `lib/views/recruiter/presentation/pages/edit_job_screen.dart`
**Status:** ❌ **NOT INTEGRATED** - UI exists with hardcoded data

**Current State:**
- Has complete UI with form fields
- Shows hardcoded job data
- No API integration

**Needs Implementation:**
- ❌ Load job details from API using job ID
- ❌ Pre-fill form with existing job data
- ❌ Connect to `CreateJobCubit.updateJob()` method
- ❌ Handle image upload for updated image
- ❌ Success/error handling
- ❌ Refresh job list on successful update

**API Endpoints:**
- ❌ `GET /api/jobs/{id}` - Fetch job details for editing
- ❌ `PUT /api/jobs/{id}` - Update job
- ❌ `POST /api/files/upload` - Upload new image (if changed)

**Models Used:**
- `Job` - Existing job details
- `JobRequest` - Update job request

**State Management:**
- Can reuse `CreateJobCubit` (already has `updateJob` method)
- Needs to add `EditJobLoading` state or reuse existing states

**Tasks:**
1. ❌ Accept jobId parameter in screen
2. ❌ Fetch job details on screen init
3. ❌ Pre-fill all form fields from job data
4. ❌ Load category selection from job.category
5. ❌ Show existing skills as selected
6. ❌ Call `updateJob()` on submit
7. ❌ Handle success and navigate back

---

---

## Phase 2: Job Seeker Module

Coming soon after Phase 1 completion...

---

## Phase 3: Applications Module

Coming soon after Phase 2 completion...

---

## Phase 4: Communication Module

Coming soon after Phase 3 completion...

---

## Phase 5: Admin Module

Coming soon after Phase 4 completion...

---

## Core Infrastructure Tasks (Already Implemented)

### Task I-1: Create User Repository & Cubit

**Files to create:**
- `lib/views/auth/data/repositories/user_repository.dart`
- `lib/views/auth/logic/cubit/user_cubit.dart`
- `lib/views/auth/logic/cubit/user_state.dart`

**API Endpoints:**
```
GET  /api/users/me                         -> Get current user profile
PUT  /api/users/me/job-seeker-profile      -> Update job seeker profile
PUT  /api/users/me/recruiter-profile       -> Update recruiter profile
```

**Implementation:**
```dart
// user_repository.dart
class UserRepository {
  Future<MeResponse> getMe();
  Future<MeResponse> updateJobSeekerProfile(JobSeekerProfileUpdateRequest request);
  Future<MeResponse> updateRecruiterProfile(RecruiterProfileUpdateRequest request);
}
```

---

### Task I-2: Create File Upload Service

**File to create:**
- `lib/core/services/file_upload_service.dart`

**API Endpoint:**
```
POST /api/files/upload (multipart/form-data)
Response: { "url": "string" }
```

**Implementation:**
```dart
class FileUploadService {
  Future<String> uploadFile(File file); // Returns URL
  Future<String> uploadProfilePicture(File image);
  Future<String> uploadCV(File document);
  Future<String> uploadCompanyLogo(File image);
}
```

**Notes:**
- Use `dio` FormData for multipart upload
- Handle progress callbacks for UX

---

### Task I-3: Create Notification Repository & Cubit

**Files to create:**
- `lib/views/notifications/data/models/notification.dart`
- `lib/views/notifications/data/repositories/notification_repository.dart`
- `lib/views/notifications/logic/notification_cubit.dart`

**API Endpoints:**
```
GET /api/notifications                      -> List notifications (paginated)
PUT /api/notifications/{notificationId}/read -> Mark as read
```

---

### Task I-4: Create Saved Jobs Repository & Cubit

**Files to create:**
- `lib/views/jobs/data/models/saved_job.dart`
- `lib/views/jobs/data/repositories/saved_job_repository.dart`
- `lib/views/jobs/logic/saved_job_cubit.dart`

**API Endpoints:**
```
POST   /api/jobs/{jobId}/save         -> Save a job
DELETE /api/jobs/{jobId}/save         -> Unsave a job
GET    /api/job-seekers/me/saved-jobs -> Get saved jobs (paginated)
```

---

### Task I-5: Create Quiz Repository & Cubit

**Files to create:**
- `lib/views/quiz/data/models/quiz.dart`
- `lib/views/quiz/data/models/quiz_attempt.dart`
- `lib/views/quiz/data/repositories/quiz_repository.dart`
- `lib/views/quiz/logic/quiz_cubit.dart`

**API Endpoints:**
```
POST /api/quizzes                  -> Create quiz (recruiter)
GET  /api/jobs/{jobId}/quiz        -> Get quiz for a job
POST /api/quizzes/{quizId}/submit  -> Submit quiz answers
GET  /api/quizzes/{quizId}/attempts -> Get quiz attempts (paginated)
```

---

### Task I-6: Create Review & Report Repositories

**Files to create:**
- `lib/views/reviews/data/models/review.dart`
- `lib/views/reviews/data/repositories/review_repository.dart`
- `lib/views/reports/data/models/report.dart`
- `lib/views/reports/data/repositories/report_repository.dart`

**API Endpoints:**
```
POST /api/reviews -> Create review (for completed jobs)
POST /api/reports -> Report a job or user
```

---

### Task I-7: Create Admin Repository & Cubit

**Files to create:**
- `lib/views/admin/data/models/dashboard_response.dart`
- `lib/views/admin/data/models/activity.dart`
- `lib/views/admin/data/repositories/admin_repository.dart`
- `lib/views/admin/logic/admin_cubit.dart`

**API Endpoints:**
```
GET    /api/admin/dashboard              -> Dashboard stats
GET    /api/admin/users                  -> List users (paginated)
PUT    /api/admin/users/{userId}/status  -> Update user status (ACTIVE/BLOCKED)
PUT    /api/admin/users/{userId}/role    -> Update user role
DELETE /api/admin/users/{userId}         -> Delete user
GET    /api/admin/reports                -> List reports (paginated)
PUT    /api/admin/reports/{reportId}/status -> Update report status
GET    /api/admin/activities             -> List activities (paginated)
```

---

### Task I-8: Enable Chat WebSocket & REST Integration

**Files to update/create:**
- `lib/views/chat/data/models/chat_message.dart` (update to match API)
- `lib/views/chat/data/repositories/chat_repository.dart`
- `lib/views/chat/logic/cubit/chat_cubit.dart` (uncomment & update)

**API Endpoints:**
```
GET /api/chat/conversations       -> Get list of conversations
GET /api/chat/history/{userId}    -> Get chat history with a user
WS  ws://51.91.111.185:8088/ws/chat -> Real-time messaging
```

---

## Screen-by-Screen Integration Tasks

---

### 1. Authentication Screens

#### Task AUTH-1: Complete Login Integration
**Screen:** `lib/views/auth/presentation/pages/login_screen.dart`
**Cubit:** `lib/views/auth/logic/cubit/auth_cubit.dart`

**Current Status:** Partial - API call exists

**Tasks:**
- [ ] Verify login response handling matches `AuthResponse` schema
- [ ] Store `accessToken` and `refreshToken` properly
- [ ] Handle `BLOCKED` user status (show error, prevent login)
- [ ] Implement proper error messages for different HTTP codes
- [ ] Add "Remember me" functionality using Hive
- [ ] Call `GET /api/users/me` after login to get full profile

**API Details:**
```json
POST /api/auth/login
Request: { "email": "string", "password": "string" }
Response: {
  "accessToken": "string",
  "refreshToken": "string",
  "tokenType": "string",
  "role": "JOB_SEEKER|RECRUITER|ADMIN",
  "status": "ACTIVE|BLOCKED"
}
```

---

#### Task AUTH-2: Complete Job Seeker Registration
**Screen:** `lib/views/auth/presentation/pages/register_job_seeker_screen.dart`

**Tasks:**
- [ ] Verify request body matches `RegisterJobSeekerRequest`
- [ ] Add phone number field (optional)
- [ ] Handle registration errors (email already exists, etc.)
- [ ] Auto-login after successful registration
- [ ] Store tokens and navigate to home

**API Details:**
```json
POST /api/auth/register/job-seeker
Request: {
  "email": "string" (required),
  "password": "string" (required, min 8 chars),
  "firstName": "string" (required),
  "lastName": "string" (required),
  "phoneNumber": "string" (optional)
}
```

---

#### Task AUTH-3: Complete Recruiter Registration
**Screen:** `lib/views/auth/presentation/pages/register_recruiter_screen.dart`

**Tasks:**
- [ ] Verify request body matches `RegisterRecruiterRequest`
- [ ] Add website field (optional)
- [ ] Handle registration errors
- [ ] Auto-login after successful registration

**API Details:**
```json
POST /api/auth/register/recruiter
Request: {
  "email": "string" (required),
  "password": "string" (required, min 8 chars),
  "companyName": "string" (required),
  "website": "string" (optional)
}
```

---

#### Task AUTH-4: Implement Splash Screen User Check
**Screen:** `lib/views/splash/presentation/pages/splash_screen.dart`

**Tasks:**
- [ ] Check if token exists in secure storage
- [ ] Validate token by calling `GET /api/users/me`
- [ ] If token valid, navigate to appropriate home screen based on role
- [ ] If token invalid/expired, clear storage and go to login
- [ ] Handle token refresh if implemented on backend

---

### 2. Job Seeker Home Screen

#### Task JS-HOME-1: Complete Jobs Listing
**Screen:** `lib/views/home/presentation/pages/job_seeker_home_screen.dart`
**Cubit:** `lib/views/jobs/logic/job_cubit.dart`

**Tasks:**
- [ ] Verify `GET /api/jobs` response matches `PageJob` schema
- [ ] Implement category filtering with `?category={categoryId}`
- [ ] Implement sorting with `?sort=createdAt,desc`
- [ ] Handle empty state when no jobs
- [ ] Show loading shimmer while fetching
- [ ] Implement pull-to-refresh
- [ ] Implement infinite scroll pagination

**API Details:**
```
GET /api/jobs?page=0&size=10&category=1&sort=createdAt,desc
```

---

#### Task JS-HOME-2: Complete Search Functionality
**Screen:** `lib/views/home/presentation/pages/job_seeker_home_screen.dart`

**Tasks:**
- [ ] Implement search with debounce (500ms delay)
- [ ] Call `GET /api/jobs/search?query={search}&page=0&size=10`
- [ ] Show search results in same list format
- [ ] Handle empty search results
- [ ] Show search history (optional, store in Hive)

---

#### Task JS-HOME-3: Load Categories
**Tasks:**
- [ ] Call `GET /api/categories` on screen init
- [ ] Cache categories in Hive (24hr TTL)
- [ ] Display category chips for filtering
- [ ] Map category icons to Flutter icons

---

#### Task JS-HOME-4: Display Saved Jobs Indicator
**Tasks:**
- [ ] Fetch saved job IDs on home load
- [ ] Show filled/unfilled bookmark icon on job cards
- [ ] Toggle save state locally for instant feedback
- [ ] Sync with `POST/DELETE /api/jobs/{jobId}/save`

---

### 3. Job Details Screen

#### Task JOB-DETAIL-1: Complete Job Details Loading
**Screen:** `lib/views/jobs/presentation/pages/job_details_screen.dart`
**Cubit:** `lib/views/jobs/logic/job_cubit.dart`

**Tasks:**
- [ ] Verify `GET /api/jobs/{id}` response matches `Job` schema
- [ ] Display all job fields:
  - Title, Description, Requirements
  - Location, Salary, Duration
  - Skills (as chips)
  - Category
  - Recruiter info (company name, logo)
  - requiresQuiz flag
  - createdAt, updatedAt
- [ ] Handle job not found (404)
- [ ] Handle job closed/flagged status

---

#### Task JOB-DETAIL-2: Implement Apply Button (Job Seeker)
**Tasks:**
- [ ] Show "Apply" button for job seekers on OPEN jobs
- [ ] Check if already applied (disable button, show status)
- [ ] If `requiresQuiz` is true:
  - Fetch quiz with `GET /api/jobs/{jobId}/quiz`
  - Navigate to quiz screen before allowing application
  - Submit quiz first, then call apply
- [ ] Call `POST /api/jobs/{jobId}/apply`
- [ ] Show success/error feedback
- [ ] Update local state to reflect application

**API Details:**
```json
POST /api/jobs/{jobId}/apply
Response: JobApplication { id, job, jobSeeker, status: "PENDING", appliedAt }
```

---

#### Task JOB-DETAIL-3: Implement Save/Unsave Job
**Tasks:**
- [ ] Show bookmark icon on job details
- [ ] Call `POST /api/jobs/{jobId}/save` to save
- [ ] Call `DELETE /api/jobs/{jobId}/save` to unsave
- [ ] Toggle icon state with optimistic update

---

#### Task JOB-DETAIL-4: Implement Report Job
**Tasks:**
- [ ] Add "Report" option in overflow menu
- [ ] Show dialog to enter reason
- [ ] Call `POST /api/reports`

**API Details:**
```json
POST /api/reports
Request: {
  "targetId": 123,
  "targetType": "JOB",
  "reason": "Inappropriate content"
}
```

---

#### Task JOB-DETAIL-5: Recruiter View - Edit/Delete Options
**Tasks:**
- [ ] If user is recruiter and owns this job:
  - Show "Edit" button -> Navigate to EditJobScreen
  - Show "Delete" button -> Confirm dialog -> Call `DELETE /api/jobs/{id}`
- [ ] Show "View Applications" button -> Navigate to ApplicationManagementScreen

---

### 4. My Applications Screen

#### Task MY-APP-1: Complete Applications Listing
**Screen:** `lib/views/applications/presentation/pages/my_applications_screen.dart`
**Cubit:** `lib/views/applications/logic/application_cubit.dart`

**Tasks:**
- [ ] Call `GET /api/job-seekers/me/applications?page=0&size=10`
- [ ] Verify response matches `PageJobApplication`
- [ ] Display application cards with:
  - Job title, company name
  - Application status (color-coded badge)
  - Applied date
- [ ] Implement pagination (load more)
- [ ] Implement status filter tabs (All, Pending, Accepted, etc.)
- [ ] Pull-to-refresh
- [ ] Empty state for no applications

**Application Statuses:**
- `PENDING` - Yellow
- `VIEWED` - Blue
- `REJECTED` - Red
- `ACCEPTED` - Green
- `HIRED` - Purple
- `COMPLETED` - Gray

---

#### Task MY-APP-2: Application Detail View
**Tasks:**
- [ ] Tap on application to view full details
- [ ] Show job details
- [ ] Show status timeline (when status changed)
- [ ] If `COMPLETED`, show "Leave Review" button

---

#### Task MY-APP-3: Leave Review for Completed Job
**Tasks:**
- [ ] After job is `COMPLETED`, allow leaving review
- [ ] Call `POST /api/reviews`

**API Details:**
```json
POST /api/reviews
Request: {
  "jobApplicationId": 123,
  "rating": 5,  // 1-5
  "comment": "Great experience!"
}
```

---

### 5. Recruiter Home Screen

#### Task REC-HOME-1: Load My Jobs
**Screen:** `lib/views/recruiter/presentation/pages/recruiter_home_screen.dart`

**Tasks:**
- [ ] Create RecruiterJobCubit or extend JobCubit
- [ ] Call `GET /api/jobs/recruiters/me/jobs?page=0&size=10`
- [ ] Display recruiter's job postings with:
  - Title, Status (OPEN/CLOSED/FLAGGED)
  - Number of applications (from local count or separate API)
  - Created date
- [ ] Implement pagination
- [ ] Pull-to-refresh
- [ ] FAB to create new job

---

#### Task REC-HOME-2: Quick Actions on Job Cards
**Tasks:**
- [ ] "View Applications" -> Navigate to ApplicationManagementScreen
- [ ] "Edit" -> Navigate to EditJobScreen
- [ ] "Close Job" -> Call `PUT /api/jobs/{id}` with `status: "CLOSED"`
- [ ] "Delete" -> Confirm -> Call `DELETE /api/jobs/{id}`

---

### 6. Create/Edit Job Screens

#### Task CREATE-JOB-1: Complete Create Job
**Screen:** `lib/views/recruiter/presentation/pages/create_job_screen.dart`

**Tasks:**
- [ ] Create JobFormCubit for form management
- [ ] Validate all required fields:
  - title (required)
  - description (required)
  - categoryId (required)
- [ ] Optional fields: requirements, location, salary, duration, skills, imageUrl, requiresQuiz
- [ ] Call `POST /api/jobs`
- [ ] Handle success -> Navigate back with job created
- [ ] Handle errors (validation, server)

**API Details:**
```json
POST /api/jobs
Request: {
  "title": "string" (required),
  "description": "string" (required),
  "requirements": "string",
  "location": "string",
  "salary": 50.0,
  "duration": "2 hours",
  "categoryId": 1 (required),
  "requiresQuiz": false,
  "imageUrl": "string",
  "skills": ["flutter", "dart"]
}
```

---

#### Task CREATE-JOB-2: Add Image Upload for Job
**Tasks:**
- [ ] Add image picker button
- [ ] Upload image via `POST /api/files/upload`
- [ ] Set returned URL to `imageUrl` field

---

#### Task EDIT-JOB-1: Complete Edit Job
**Screen:** `lib/views/recruiter/presentation/pages/edit_job_screen.dart`

**Tasks:**
- [ ] Load existing job data on screen init
- [ ] Pre-fill form fields
- [ ] Call `PUT /api/jobs/{id}` on submit
- [ ] Handle success -> Navigate back with updated job

---

#### Task CREATE-JOB-3: Create Quiz for Job (Optional)
**Tasks:**
- [ ] If `requiresQuiz` is checked, show quiz builder
- [ ] Allow adding questions with options
- [ ] After job is created, call `POST /api/quizzes`

**API Details:**
```json
POST /api/quizzes
Request: {
  "jobId": 123,
  "title": "Flutter Assessment",
  "questions": [
    {
      "text": "What is a Widget?",
      "type": "SINGLE_CHOICE",
      "options": [
        { "text": "A UI component", "correct": true },
        { "text": "A database", "correct": false }
      ]
    }
  ]
}
```

---

### 7. Application Management Screen

#### Task APP-MGT-1: Load Job Applications
**Screen:** `lib/views/applications/presentation/pages/application_management_screen.dart`
**Cubit:** `lib/views/applications/logic/application_cubit.dart`

**Tasks:**
- [ ] Call `GET /api/jobs/{jobId}/applications?page=0&size=10`
- [ ] Display applicant cards with:
  - Job seeker name, profile picture
  - Current status
  - Applied date
  - CV link (if available)
- [ ] Implement pagination
- [ ] Filter by status

---

#### Task APP-MGT-2: Update Application Status
**Tasks:**
- [ ] Add action buttons per application:
  - "Mark Viewed" (PENDING -> VIEWED)
  - "Accept" (-> ACCEPTED)
  - "Reject" (-> REJECTED)
  - "Hire" (ACCEPTED -> HIRED)
  - "Complete" (HIRED -> COMPLETED)
- [ ] Call `PUT /api/applications/{applicationId}/status`
- [ ] Update local state immediately

**API Details:**
```json
PUT /api/applications/{applicationId}/status
Request: { "status": "ACCEPTED" }
```

---

#### Task APP-MGT-3: View Quiz Results (if applicable)
**Tasks:**
- [ ] If job requires quiz, show quiz score for each applicant
- [ ] Call `GET /api/quizzes/{quizId}/attempts` to get scores
- [ ] Display score badge on application card

---

#### Task APP-MGT-4: Contact Applicant
**Tasks:**
- [ ] Add "Message" button on applicant card
- [ ] Navigate to chat screen with that user
- [ ] Start conversation if not exists

---

### 8. Edit Profile Screens

#### Task PROFILE-JS-1: Job Seeker Profile Edit
**Screen:** `lib/views/home/presentation/pages/edit_job_seeker_profile_screen.dart`

**Tasks:**
- [ ] Load current profile from `GET /api/users/me`
- [ ] Pre-fill form fields
- [ ] Allow editing:
  - firstName (required)
  - lastName (required)
  - phoneNumber (optional)
  - profilePictureUrl (with image upload)
  - cvUrl (with file upload)
- [ ] Call `PUT /api/users/me/job-seeker-profile`
- [ ] Update local storage after success

**API Details:**
```json
PUT /api/users/me/job-seeker-profile
Request: {
  "firstName": "string" (required),
  "lastName": "string" (required),
  "phoneNumber": "string",
  "cvUrl": "string",
  "profilePictureUrl": "string"
}
```

---

#### Task PROFILE-JS-2: Upload Profile Picture
**Tasks:**
- [ ] Add avatar picker (camera/gallery)
- [ ] Upload via `POST /api/files/upload`
- [ ] Set URL to profilePictureUrl
- [ ] Show preview

---

#### Task PROFILE-JS-3: Upload CV
**Tasks:**
- [ ] Add file picker for PDF/DOC
- [ ] Upload via `POST /api/files/upload`
- [ ] Set URL to cvUrl
- [ ] Show file name after upload

---

#### Task PROFILE-REC-1: Recruiter Profile Edit
**Screen:** `lib/views/recruiter/presentation/pages/edit_recruiter_profile_screen.dart`

**Tasks:**
- [ ] Load current profile from `GET /api/users/me`
- [ ] Pre-fill form fields
- [ ] Allow editing:
  - companyName (required)
  - website (optional)
  - companyLogoUrl (with image upload)
- [ ] Call `PUT /api/users/me/recruiter-profile`

**API Details:**
```json
PUT /api/users/me/recruiter-profile
Request: {
  "companyName": "string" (required),
  "website": "string",
  "companyLogoUrl": "string"
}
```

---

### 9. Quiz Screen

#### Task QUIZ-1: Load Quiz for Job
**Screen:** `lib/views/quiz/presentation/pages/quiz_screen.dart`

**Tasks:**
- [ ] Receive jobId as parameter
- [ ] Call `GET /api/jobs/{jobId}/quiz`
- [ ] Parse quiz with questions and options
- [ ] Display quiz UI:
  - Title
  - Progress indicator
  - Question text
  - Options (radio for SINGLE_CHOICE, checkbox for MULTIPLE_CHOICE)
- [ ] Track selected answers

**Quiz Response Structure:**
```json
{
  "id": 1,
  "title": "Flutter Assessment",
  "job": { ... },
  "questions": [
    {
      "id": 1,
      "text": "What is Flutter?",
      "type": "SINGLE_CHOICE",
      "options": [
        { "id": 1, "text": "SDK", "correct": null },
        { "id": 2, "text": "Language", "correct": null }
      ]
    }
  ]
}
```

---

#### Task QUIZ-2: Submit Quiz Answers
**Tasks:**
- [ ] Collect selected option IDs
- [ ] Call `POST /api/quizzes/{quizId}/submit`
- [ ] Display result (score)
- [ ] If passed, proceed to apply for job

**API Details:**
```json
POST /api/quizzes/{quizId}/submit
Request: {
  "answers": [1, 5, 8]  // Array of selected option IDs
}
Response: {
  "id": 1,
  "jobSeeker": { ... },
  "quiz": { ... },
  "score": 80.0,
  "submittedAt": "2024-01-15T10:30:00"
}
```

---

#### Task QUIZ-3: Quiz Already Taken Check
**Tasks:**
- [ ] Before showing quiz, check if user already attempted
- [ ] Could call `GET /api/quizzes/{quizId}/attempts` filtered by current user
- [ ] If already attempted, show score and skip quiz

---

### 10. Chat Screen

#### Task CHAT-1: Enable WebSocket Connection
**Screen:** `lib/views/chat/presentation/pages/chat_page.dart`

**Tasks:**
- [ ] Uncomment/update WebSocketService
- [ ] Connect to `ws://51.91.111.185:8088/ws/chat`
- [ ] Send authentication token on connect
- [ ] Handle connection states (connecting, connected, disconnected)
- [ ] Implement reconnection logic

---

#### Task CHAT-2: Load Conversations List
**Tasks:**
- [ ] Create ConversationsScreen (new)
- [ ] Call `GET /api/chat/conversations?page=0&size=20`
- [ ] Display list of users chatted with
- [ ] Show last message preview
- [ ] Show unread count (if available)

---

#### Task CHAT-3: Load Chat History
**Tasks:**
- [ ] When opening chat with user, call `GET /api/chat/history/{userId}`
- [ ] Load previous messages (paginated, newest first)
- [ ] Display messages in chat bubble format
- [ ] Implement infinite scroll to load older messages

**Chat Message Structure:**
```json
{
  "id": 1,
  "sender": { "id": 1, "email": "..." },
  "recipient": { "id": 2, "email": "..." },
  "message": "Hello!",
  "timestamp": "2024-01-15T10:30:00"
}
```

---

#### Task CHAT-4: Send Messages via WebSocket
**Tasks:**
- [ ] Implement message sending through WebSocket
- [ ] Add message to local state immediately (optimistic)
- [ ] Handle send failures
- [ ] Show delivered/read status (if backend supports)

---

#### Task CHAT-5: Real-time Message Reception
**Tasks:**
- [ ] Listen to WebSocket stream
- [ ] Parse incoming messages
- [ ] Add to appropriate conversation
- [ ] Show notification if chat not open

---

### 11. Notifications Feature

#### Task NOTIF-1: Create Notifications Screen
**Files to create:**
- `lib/views/notifications/presentation/pages/notifications_screen.dart`

**Tasks:**
- [ ] Add route `/notifications` in main.dart
- [ ] Create NotificationCubit
- [ ] Call `GET /api/notifications?page=0&size=20`
- [ ] Display notification list with:
  - Message
  - Timestamp
  - Read/unread indicator
- [ ] Implement pagination
- [ ] Pull-to-refresh

---

#### Task NOTIF-2: Mark Notification as Read
**Tasks:**
- [ ] On notification tap, call `PUT /api/notifications/{id}/read`
- [ ] Update local state
- [ ] Navigate to relevant screen based on notification type

---

#### Task NOTIF-3: Add Notification Badge
**Tasks:**
- [ ] Add notification icon to app bar on home screens
- [ ] Fetch unread count
- [ ] Show badge with count

---

### 12. Saved Jobs Feature

#### Task SAVED-1: Create Saved Jobs Screen
**Files to create:**
- `lib/views/jobs/presentation/pages/saved_jobs_screen.dart`

**Tasks:**
- [ ] Add route `/saved-jobs` in main.dart
- [ ] Create SavedJobCubit
- [ ] Call `GET /api/job-seekers/me/saved-jobs?page=0&size=10`
- [ ] Display saved jobs list
- [ ] Allow unsaving from this screen
- [ ] Navigate to job details on tap

---

#### Task SAVED-2: Integrate Save Action Throughout App
**Tasks:**
- [ ] Add bookmark icon to job cards on home screen
- [ ] Add bookmark icon on job details screen
- [ ] Implement toggle save/unsave
- [ ] Sync state with SavedJobCubit

---

### 13. Reviews & Reports Feature

#### Task REVIEW-1: Leave Review Flow
**Tasks:**
- [ ] Add "Leave Review" button on completed applications
- [ ] Show star rating widget (1-5)
- [ ] Optional comment text field
- [ ] Call `POST /api/reviews`
- [ ] Show success feedback

---

#### Task REPORT-1: Report User/Job Flow
**Tasks:**
- [ ] Add "Report" option in relevant screens (job details, user profile)
- [ ] Show report dialog with reason options
- [ ] Call `POST /api/reports`
- [ ] Show confirmation

---

### 14. Admin Dashboard

#### Task ADMIN-1: Load Dashboard Stats
**Screen:** `lib/views/admin/presentation/pages/admin_dashboard_screen.dart`

**Tasks:**
- [ ] Call `GET /api/admin/dashboard`
- [ ] Display stats cards:
  - Total users
  - Total jobs
  - Active jobs
  - Pending applications
  - etc. (based on response)

---

#### Task ADMIN-2: User Management
**Tasks:**
- [ ] Call `GET /api/admin/users?page=0&size=20`
- [ ] Display users list with:
  - Email, Role, Status
  - Created date
- [ ] Action buttons:
  - Block/Unblock: `PUT /api/admin/users/{id}/status`
  - Change role: `PUT /api/admin/users/{id}/role`
  - Delete: `DELETE /api/admin/users/{id}`

---

#### Task ADMIN-3: Reports Management
**Tasks:**
- [ ] Call `GET /api/admin/reports?page=0&size=20`
- [ ] Display reports with:
  - Reporter info
  - Target (Job/User)
  - Reason
  - Status (PENDING, UNDER_REVIEW, RESOLVED)
- [ ] Update status: `PUT /api/admin/reports/{id}/status`

---

#### Task ADMIN-4: Activity Log
**Tasks:**
- [ ] Call `GET /api/admin/activities?page=0&size=20`
- [ ] Display activity timeline
- [ ] Show type, message, timestamp

---

## New Features to Implement

### Feature: Token Refresh
- Implement interceptor to catch 401 errors
- Call refresh token endpoint (if exists)
- Retry failed request with new token
- If refresh fails, logout user

### Feature: Offline Support
- Cache jobs list in Hive
- Show cached data when offline
- Queue actions (save, apply) for sync when online

### Feature: Push Notifications
- Integrate Firebase Cloud Messaging
- Handle notification tap to navigate

### Feature: Deep Linking
- Handle links like `masroufi://jobs/123`
- Navigate to job details

---

## API Endpoints Reference

### Authentication
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/auth/login` | User login |
| POST | `/api/auth/register/job-seeker` | Register job seeker |
| POST | `/api/auth/register/recruiter` | Register recruiter |

### User Profile
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/users/me` | Get current user profile |
| PUT | `/api/users/me/job-seeker-profile` | Update job seeker profile |
| PUT | `/api/users/me/recruiter-profile` | Update recruiter profile |

### Jobs
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/jobs` | List jobs (paginated, filterable) |
| POST | `/api/jobs` | Create job (recruiter) |
| GET | `/api/jobs/{id}` | Get job details |
| PUT | `/api/jobs/{id}` | Update job (recruiter) |
| DELETE | `/api/jobs/{id}` | Delete job (recruiter) |
| GET | `/api/jobs/search` | Search jobs |
| GET | `/api/jobs/recruiters/me/jobs` | Get my jobs (recruiter) |

### Categories
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/categories` | List categories |

### Applications
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/jobs/{jobId}/apply` | Apply to job |
| GET | `/api/job-seekers/me/applications` | My applications |
| GET | `/api/jobs/{jobId}/applications` | Applications for job (recruiter) |
| PUT | `/api/applications/{id}/status` | Update application status |

### Saved Jobs
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/jobs/{jobId}/save` | Save job |
| DELETE | `/api/jobs/{jobId}/save` | Unsave job |
| GET | `/api/job-seekers/me/saved-jobs` | Get saved jobs |

### Quiz
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/quizzes` | Create quiz (recruiter) |
| GET | `/api/jobs/{jobId}/quiz` | Get quiz for job |
| POST | `/api/quizzes/{quizId}/submit` | Submit quiz answers |
| GET | `/api/quizzes/{quizId}/attempts` | Get quiz attempts |

### Notifications
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/notifications` | Get notifications |
| PUT | `/api/notifications/{id}/read` | Mark as read |

### Chat
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/chat/conversations` | Get conversations |
| GET | `/api/chat/history/{userId}` | Get chat history |
| WS | `ws://.../ws/chat` | Real-time messaging |

### Reviews & Reports
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/reviews` | Create review |
| POST | `/api/reports` | Create report |

### File Upload
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/files/upload` | Upload file |

### Admin
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/admin/dashboard` | Dashboard stats |
| GET | `/api/admin/users` | List users |
| PUT | `/api/admin/users/{id}/status` | Update user status |
| PUT | `/api/admin/users/{id}/role` | Update user role |
| DELETE | `/api/admin/users/{id}` | Delete user |
| GET | `/api/admin/reports` | List reports |
| PUT | `/api/admin/reports/{id}/status` | Update report status |
| GET | `/api/admin/activities` | List activities |

---

## Implementation Priority (Suggested Order)

### Phase 1: Core Auth & Profile (Foundation)
1. I-1: User Repository & Cubit
2. AUTH-1: Complete Login
3. AUTH-4: Splash Screen User Check
4. AUTH-2: Job Seeker Registration
5. AUTH-3: Recruiter Registration

### Phase 2: Job Seeker Features
6. JS-HOME-1 to JS-HOME-4: Home Screen
7. JOB-DETAIL-1 to JOB-DETAIL-3: Job Details
8. MY-APP-1 to MY-APP-2: My Applications
9. PROFILE-JS-1 to PROFILE-JS-3: Profile Edit
10. I-2: File Upload Service
11. I-4: Saved Jobs Feature

### Phase 3: Recruiter Features
12. REC-HOME-1 to REC-HOME-2: Recruiter Home
13. CREATE-JOB-1 to CREATE-JOB-2: Create Job
14. EDIT-JOB-1: Edit Job
15. APP-MGT-1 to APP-MGT-4: Application Management
16. PROFILE-REC-1: Recruiter Profile

### Phase 4: Quiz System
17. I-5: Quiz Repository & Cubit
18. QUIZ-1 to QUIZ-3: Quiz Screen
19. CREATE-JOB-3: Create Quiz for Job

### Phase 5: Communication
20. I-3: Notification Feature
21. NOTIF-1 to NOTIF-3: Notifications Screen
22. I-8: Chat Integration
23. CHAT-1 to CHAT-5: Chat Feature

### Phase 6: Reviews, Reports & Admin
24. I-6: Review & Report Repositories
25. REVIEW-1, REPORT-1: Reviews & Reports
26. I-7: Admin Repository
27. ADMIN-1 to ADMIN-4: Admin Dashboard

---

*Document generated on: 2024*
*Total Tasks: ~60 integration tasks*
