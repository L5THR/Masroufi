# Backend API Fixes Required for MASROUFI Flutter App

**Date:** 2025-12-20
**Status:** CRITICAL - App cannot function without these fixes
**Backend URL:** http://51.91.111.185:8088

---

## 🚨 CRITICAL ISSUES (Breaking the App)

### Issue #1: All Paginated Endpoints Return 403 Forbidden

**Affected Endpoints:**
- `GET /api/categories`
- `GET /api/jobs/recruiters/me/jobs`
- `GET /api/jobs`
- `GET /api/jobs/search`
- `GET /api/job-seekers/me/saved-jobs`
- `GET /api/job-seekers/me/applications`
- `GET /api/jobs/{jobId}/applications`
- `GET /api/notifications`
- `GET /api/admin/*` (all admin endpoints)
- `GET /api/chat/*` (all chat endpoints)

**Problem:**
The API spec shows these endpoints require a `Pageable` parameter as a complex object, but the endpoints are returning **403 Forbidden** even with valid authentication tokens.

**Current API Spec (WRONG):**
```yaml
"/api/categories": {
  "get": {
    "parameters": [
      {
        "name": "arg0",                    # ❌ Generic parameter name
        "in": "query",
        "required": true,                  # ❌ Required!
        "schema": {
          "$ref": "#/components/schemas/Pageable"  # ❌ Complex object
        }
      }
    ]
  }
}
```

**Expected Behavior:**
```yaml
"/api/categories": {
  "get": {
    "parameters": [
      {
        "name": "page",
        "in": "query",
        "required": false,           # ✅ Optional
        "schema": {
          "type": "integer",
          "format": "int32",
          "default": 0
        }
      },
      {
        "name": "size",
        "in": "query",
        "required": false,           # ✅ Optional
        "schema": {
          "type": "integer",
          "format": "int32",
          "default": 20
        }
      },
      {
        "name": "sort",
        "in": "query",
        "required": false,           # ✅ Optional
        "schema": {
          "type": "array",
          "items": {
            "type": "string"
          }
        }
      }
    ]
  }
}
```

**Backend Fix Required:**
```java
// WRONG - This creates the complex Pageable parameter
@GetMapping("/api/categories")
public Page<Category> list(Pageable pageable) {
    return categoryService.findAll(pageable);
}

// CORRECT - Use @PageableDefault and @SortDefault
@GetMapping("/api/categories")
public Page<Category> list(
    @PageableDefault(size = 20, page = 0)
    @SortDefault.SortDefaults({
        @SortDefault(sort = "name", direction = Sort.Direction.ASC)
    })
    Pageable pageable
) {
    return categoryService.findAll(pageable);
}

// OR explicitly define parameters:
@GetMapping("/api/categories")
public Page<Category> list(
    @RequestParam(defaultValue = "0") int page,
    @RequestParam(defaultValue = "20") int size,
    @RequestParam(required = false) String[] sort
) {
    Pageable pageable = PageRequest.of(page, size,
        sort != null ? Sort.by(sort) : Sort.unsorted());
    return categoryService.findAll(pageable);
}
```

**Impact:** 🔴 **CRITICAL** - Cannot load categories, jobs, or any list data

---

### Issue #2: Categories Endpoint Should Be Public

**Endpoint:** `GET /api/categories`

**Problem:**
Categories should be accessible without authentication (public data), but the endpoint is returning 403 Forbidden even with a valid token.

**Backend Fix Required:**
```java
// In SecurityConfig.java
@Bean
public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
    return http
        .authorizeHttpRequests(auth -> auth
            // Public endpoints
            .requestMatchers("/api/auth/**").permitAll()
            .requestMatchers("/api/categories").permitAll()  // ✅ ADD THIS
            .requestMatchers("/api/jobs").permitAll()        // ✅ Jobs list should also be public
            .requestMatchers("/api/jobs/{id}").permitAll()   // ✅ Job details should be public

            // Authenticated endpoints
            .anyRequest().authenticated()
        )
        .build();
}
```

**Impact:** 🔴 **CRITICAL** - Cannot create jobs without categories

---

### Issue #3: My Jobs Endpoint Requires Recruiter Role

**Endpoint:** `GET /api/jobs/recruiters/me/jobs`

**Problem:**
Even though the user has `RECRUITER` role (visible in JWT token), the endpoint returns 403 Forbidden.

**Possible Causes:**
1. Security config doesn't allow RECRUITER role to access this endpoint
2. The endpoint implementation checks for a different role
3. Role checking is case-sensitive

**Backend Fix Required:**
```java
// In SecurityConfig or on the endpoint
@PreAuthorize("hasRole('RECRUITER')")  // Make sure role is correct
@GetMapping("/api/jobs/recruiters/me/jobs")
public Page<Job> myJobs(
    @PageableDefault(size = 20, page = 0) Pageable pageable,
    @AuthenticationPrincipal UserDetails user
) {
    // Make sure we're getting the current user correctly
    return jobService.findByRecruiterEmail(user.getUsername(), pageable);
}
```

**Also check:**
```java
// JWT Token validation - ensure roles are extracted correctly
// The JWT shows: "role":"RECRUITER"
// Spring Security expects: "ROLE_RECRUITER" in authorities

// In JwtAuthenticationFilter or similar:
private List<GrantedAuthority> getAuthorities(String role) {
    // Make sure this adds "ROLE_" prefix
    return List.of(new SimpleGrantedAuthority("ROLE_" + role));
}
```

**Impact:** 🔴 **CRITICAL** - Recruiters cannot see their posted jobs

---

## ⚠️ HIGH PRIORITY ISSUES

### Issue #4: File Upload Content-Type

**Endpoint:** `POST /api/files/upload`

**Current API Spec:**
```yaml
"requestBody": {
  "content": {
    "application/json": {          # ❌ WRONG for file upload
      "schema": {
        "properties": {
          "file": {
            "type": "string",
            "format": "binary"
          }
        }
      }
    }
  }
}
```

**Expected:**
```yaml
"requestBody": {
  "content": {
    "multipart/form-data": {      # ✅ CORRECT for file upload
      "schema": {
        "type": "object",
        "properties": {
          "file": {
            "type": "string",
            "format": "binary"
          }
        }
      }
    }
  }
}
```

**Backend Fix Required:**
```java
@PostMapping("/api/files/upload")
public UploadResponse upload(
    @RequestParam("file") MultipartFile file  // Make sure parameter name matches
) throws IOException {
    String url = fileUploadService.uploadFile(file);
    return new UploadResponse(url);
}
```

**Impact:** 🟠 **HIGH** - Cannot upload job images or user profile pictures

---

### Issue #5: Missing Path Parameters in API Spec

**Affected Endpoints:**
- `GET /api/jobs/{id}` - missing `id` parameter definition
- `PUT /api/jobs/{id}` - missing `id` parameter definition
- `DELETE /api/jobs/{id}` - missing `id` parameter definition
- `POST /api/jobs/{jobId}/save` - missing `jobId` parameter
- `DELETE /api/jobs/{jobId}/save` - missing `jobId` parameter
- `POST /api/jobs/{jobId}/apply` - missing `jobId` parameter
- `GET /api/jobs/{jobId}/applications` - missing `jobId` parameter
- `GET /api/jobs/{jobId}/quiz` - missing `jobId` parameter
- And many more...

**Problem:**
All these endpoints show `"parameters": []` in the spec, but they clearly need path parameters.

**Backend Fix Required:**
```java
// Make sure to document path variables
@GetMapping("/api/jobs/{id}")
@Operation(summary = "Get job by ID")  // Add Swagger annotations
public Job get(
    @PathVariable @Parameter(description = "Job ID") Long id  // ✅ Document parameter
) {
    return jobService.findById(id);
}
```

**Impact:** 🟠 **HIGH** - Poor API documentation, but doesn't break functionality

---

## 📋 MEDIUM PRIORITY ISSUES

### Issue #6: CORS Configuration

**Problem:**
If the Flutter app runs in a web browser, CORS needs to be properly configured.

**Backend Fix Required:**
```java
@Configuration
public class CorsConfig {
    @Bean
    public WebMvcConfigurer corsConfigurer() {
        return new WebMvcConfigurer() {
            @Override
            public void addCorsMappings(CorsRegistry registry) {
                registry.addMapping("/api/**")
                    .allowedOrigins("*")  // Or specific origins
                    .allowedMethods("GET", "POST", "PUT", "DELETE", "OPTIONS")
                    .allowedHeaders("*")
                    .exposedHeaders("Authorization")
                    .allowCredentials(false);
            }
        };
    }
}
```

**Impact:** 🟡 **MEDIUM** - Only affects web deployment

---

### Issue #7: Missing Default Values

**Problem:**
Many optional fields don't have default values, causing parsing issues.

**Recommendations:**
```java
// In entity classes, use defaults:
@Column(columnDefinition = "boolean default false")
private Boolean requiresQuiz = false;

@Column(columnDefinition = "varchar(255) default 'OPEN'")
@Enumerated(EnumType.STRING)
private JobStatus status = JobStatus.OPEN;
```

**Impact:** 🟡 **MEDIUM** - Can cause null pointer exceptions

---

## 🔧 RECOMMENDED IMPROVEMENTS

### Improvement #1: Add Health Check Endpoint

```java
@RestController
@RequestMapping("/api")
public class HealthController {
    @GetMapping("/health")
    public Map<String, String> health() {
        return Map.of(
            "status", "UP",
            "timestamp", LocalDateTime.now().toString()
        );
    }
}
```

### Improvement #2: Add API Version

```java
// Add version to all endpoints
@RequestMapping("/api/v1/jobs")  // Instead of /api/jobs
```

### Improvement #3: Standardize Error Responses

```java
@ControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(AccessDeniedException.class)
    public ResponseEntity<ErrorResponse> handleAccessDenied(
        AccessDeniedException ex
    ) {
        ErrorResponse error = new ErrorResponse(
            "ACCESS_DENIED",
            "You don't have permission to access this resource",
            HttpStatus.FORBIDDEN.value()
        );
        return new ResponseEntity<>(error, HttpStatus.FORBIDDEN);
    }

    // Add more handlers...
}

// ErrorResponse DTO
public class ErrorResponse {
    private String code;
    private String message;
    private int status;
    private LocalDateTime timestamp;

    // Constructor, getters, setters
}
```

### Improvement #4: Add Request/Response Logging

```java
@Configuration
public class LoggingConfig {
    @Bean
    public CommonsRequestLoggingFilter requestLoggingFilter() {
        CommonsRequestLoggingFilter filter = new CommonsRequestLoggingFilter();
        filter.setIncludeQueryString(true);
        filter.setIncludePayload(true);
        filter.setMaxPayloadLength(10000);
        filter.setIncludeHeaders(true);
        filter.setAfterMessagePrefix("REQUEST: ");
        return filter;
    }
}
```

---

## 🧪 TESTING CHECKLIST

Once fixes are deployed, test these endpoints:

### ✅ Authentication & Authorization
```bash
# 1. Register a recruiter
curl -X POST http://51.91.111.185:8088/api/auth/register/recruiter \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@recruiter.com",
    "password": "Test1234",
    "companyName": "Test Company"
  }'

# Expected: 201 Created with accessToken

# 2. Login
curl -X POST http://51.91.111.185:8088/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@recruiter.com",
    "password": "Test1234"
  }'

# Expected: 200 OK with accessToken and role: "RECRUITER"
```

### ✅ Categories (Public)
```bash
# 3. Get categories WITHOUT authentication
curl -X GET "http://51.91.111.185:8088/api/categories?page=0&size=20"

# Expected: 200 OK with categories list
```

### ✅ My Jobs (Recruiter)
```bash
# 4. Get recruiter's jobs WITH authentication
curl -X GET "http://51.91.111.185:8088/api/jobs/recruiters/me/jobs?page=0&size=20" \
  -H "Authorization: Bearer YOUR_TOKEN"

# Expected: 200 OK with paginated jobs
```

### ✅ Create Job
```bash
# 5. Create a job
curl -X POST http://51.91.111.185:8088/api/jobs \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Flutter Developer",
    "description": "Looking for a Flutter developer",
    "categoryId": 1,
    "requiresQuiz": false,
    "skills": ["Flutter", "Dart"]
  }'

# Expected: 201 Created with job object
```

### ✅ File Upload
```bash
# 6. Upload a file
curl -X POST http://51.91.111.185:8088/api/files/upload \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -F "file=@/path/to/image.jpg"

# Expected: 201 Created with {"url": "https://..."}
```

---

## 📊 PRIORITY MATRIX

| Issue | Priority | Effort | Impact |
|-------|----------|--------|--------|
| #1: Pageable parameters | 🔴 CRITICAL | Medium | Blocks all list screens |
| #2: Categories public | 🔴 CRITICAL | Low | Blocks job creation |
| #3: My Jobs 403 | 🔴 CRITICAL | Medium | Blocks recruiter dashboard |
| #4: File upload | 🟠 HIGH | Low | Blocks image uploads |
| #5: Missing params | 🟠 HIGH | Low | Poor documentation |
| #6: CORS | 🟡 MEDIUM | Low | Web deployment |
| #7: Default values | 🟡 MEDIUM | Medium | Better reliability |

---

## 🎯 IMMEDIATE ACTION PLAN

### Step 1: Fix Pageable Parameters (30 minutes)
1. Add `@PageableDefault` to all paginated endpoints
2. Make pagination parameters optional with defaults
3. Test with: `GET /api/categories?page=0&size=20`

### Step 2: Make Categories Public (5 minutes)
1. Update `SecurityConfig` to allow public access
2. Test without authentication token

### Step 3: Fix Recruiter Authorization (20 minutes)
1. Verify role checking in security config
2. Ensure JWT roles include "ROLE_" prefix
3. Test My Jobs endpoint

### Step 4: Test & Deploy (30 minutes)
1. Run all test cases from testing checklist
2. Verify with Flutter app
3. Deploy to production

**Total Estimated Time:** 1.5 - 2 hours

---

## 📞 CONTACT

If you need clarification on any of these issues, please contact:
- Frontend: jihedmrouki@yahoo.fr
- Backend: [Backend developer email]

**Next Steps:** Once these critical fixes are deployed, we can proceed with:
- Job application flow
- Chat integration
- Quiz functionality
- Admin dashboard
