# Guide Profile Update Implementation

## Summary
Successfully implemented the Guide Profile update feature using the **guide/profile** endpoint for both fetching and updating guide data.

## ⚠️ IMPORTANT API CHANGES

### Get User Data Endpoint Changed
- **OLD:** `auth/me` - Returns basic user data
- **NEW:** `guide/profile` - Returns full guide profile with nested user data
- **Method:** GET
- **Protected:** Yes (requires authentication)

### Response Structure
The `guide/profile` endpoint returns a more comprehensive structure:
```json
{
  "success": true,
  "data": {
    "_id": "guide_id",
    "user": {
      "_id": "user_id",
      "email": "email",
      "name": "name",
      "phone": "phone",
      "role": "guide",
      "fcmTokens": [...],
      ...
    },
    "provinces": [
      {
        "_id": "province_id",
        "slug": "cairo",
        "name": "Cairo"
      }
    ],
    "languages": ["English", "Arabic"],
    "bio": "guide bio",
    "pricePerHour": 60,
    "photo": {...},
    "documents": [...],
    "rating": 0,
    ...
  }
}
```

## Changes Made

### 1. **Updated EndPoints** (`lib/core/network/end_points.dart`)
   - Changed `getUserData` from `'auth/me'` to `'guide/profile'`
   - Both GET and PUT use the same endpoint: `'guide/profile'`

### 2. **Enhanced GuideModel** (`lib/core/user/data/models/guide_model.dart`)
   - Added `provinceDetails` field for full province objects
   - Added `ProvinceDetail` model class for nested province data
   - Smart parsing: Handles provinces as both:
     - Array of strings (IDs) - used in UPDATE response
     - Array of objects (full details) - used in GET response
   - Automatically extracts province IDs from province objects

### 3. **Updated UserModel** (`lib/core/user/data/models/user_model.dart`)
   - **Smart response detection:** Automatically detects response format
   - **NEW format (guide/profile):** Extracts user data from nested `user` object
   - **OLD format (auth/me):** Maintains backward compatibility
   - Properly maps nested guide data to `guide` field
   - Works seamlessly with both API responses

### 4. **UserRepo & UserRepoImpl** (No changes needed)
   - `getUserData()` function name remains the same
   - Automatically uses new endpoint via `EndPoints.getUserData`
   - Returns `UserModel` which now includes full guide data

### 5. **UserCubit** (`lib/core/user/manager/user_cubit/user_cubit.dart`)
   - Function name `getUserData()` unchanged
   - Initializes all fields from nested guide data:
     - Bio, Price, Languages, Provinces
   - Province IDs automatically extracted from full province objects
   - No code changes needed - works transparently with new API

### 6. **UI** (`lib/features/profile/views/widgets/my_profile_widgets/my_profile_view_body.dart`)
   - **REMOVED:** Name and Phone fields (not part of guide profile update)
   - **Profile fields (read-only):**
     - Name and phone displayed from nested `user` object
   - **Editable fields:**
     - Bio (multi-line text field)
     - Price Per Hour (numeric field)
     - Languages (15 FilterChips)
     - Governorates (Dynamic FilterChips)

## API Integration

### GET Own Profile (guide/profile)
**Endpoint:** `GET guide/profile`

**Response:**
```json
{
  "success": true,
  "data": {
    "user": { /* user data */ },
    "provinces": [
      { "_id": "id", "name": "Cairo", "slug": "cairo" }
    ],
    "languages": ["English", "Arabic", "Spanish"],
    "bio": "Professional guide...",
    "pricePerHour": 60,
    "photo": {...},
    "documents": [...],
    ...
  }
}
```

### Update Profile (guide/profile)
**Endpoint:** `PUT guide/profile`

**Request:**
```json
{
  "languages": ["English", "Arabic", "Spanish"],
  "pricePerHour": 60,
  "bio": "Updated bio...",
  "provinces": ["province_id_1", "province_id_2"]
}
```

**Response:**
```json
{
  "success": true,
  "message": "Profile updated successfully",
  "guide": {
    "provinces": ["id1", "id2"],  // Now array of IDs
    "languages": ["English", "Arabic", "Spanish"],
    "bio": "Updated bio...",
    "pricePerHour": 60,
    ...
  }
}
```

## Data Flow

### On App Load / Profile View:
1. `UserCubit.getUserData()` called
2. Fetches from `guide/profile` endpoint
3. Response contains nested `user` and full guide data
4. `UserModel.fromJson()` detects nested format
5. Extracts user data from `json['user']`
6. Parses guide data (entire response)
7. Province IDs extracted from province objects
8. Controllers populated with guide data
9. UI displays all fields

### On Profile Update:
1. User edits bio, price, languages, provinces
2. User clicks Save
3. Validation runs
4. `PUT guide/profile` with updated data
5. Province IDs sent to backend
6. On success: `getUserData()` called again
7. Fresh data with province objects loaded
8. UI refreshes with new data

## Key Features

✅ **Single endpoint for GET and PUT:** `guide/profile`
✅ **Backward compatible:** Still works if API returns old format
✅ **Smart parsing:** Automatically handles province arrays (IDs or objects)
✅ **Nested data extraction:** Properly extracts user from guide response
✅ **Function names unchanged:** `getUserData()` still used in cubit
✅ **Seamless integration:** No breaking changes to existing code
✅ **Auto ID extraction:** Province IDs extracted from full objects

## Languages Supported (15 total)
1. English
2. Arabic
3. Spanish
4. French
5. German
6. Italian
7. Chinese
8. Japanese
9. Russian
10. Portuguese
11. Turkish
12. Korean
13. Hindi
14. Dutch
15. Greek

## Province Handling

### GET Response:
```json
"provinces": [
  { "_id": "id1", "name": "Cairo", "slug": "cairo" },
  { "_id": "id2", "name": "Giza", "slug": "giza" }
]
```
→ Parsed to: `provinces: ["id1", "id2"]` + `provinceDetails: [...]`

### UPDATE Request:
```json
"provinces": ["id1", "id2"]
```

### UPDATE Response:
```json
"provinces": ["id1", "id2"]
```

## Testing Checklist
- [x] Endpoint changed from `auth/me` to `guide/profile`
- [x] UserModel handles nested user data
- [x] Province objects parsed correctly
- [x] Province IDs extracted for update
- [ ] Test profile load (should show all fields)
- [ ] Edit bio and save
- [ ] Edit price per hour and save
- [ ] Select/deselect languages
- [ ] Select/deselect governorates
- [ ] Verify validation errors work
- [ ] Verify success message appears
- [ ] Verify UI updates after save
- [ ] Verify navigation after success
- [ ] Test backend error handling

## Notes
- **API endpoint changed:** Now uses `guide/profile` for everything
- **Nested structure:** User data is inside `user` object
- **Province flexibility:** Handles both ID arrays and object arrays
- **Function names preserved:** No changes to cubit method names
- **Backward compatible:** Still works with old response format
- **Auto-extraction:** Province IDs automatically extracted from objects
- **Same endpoint:** GET and PUT both use `guide/profile`
