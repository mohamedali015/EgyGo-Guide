# 🔔 Firebase Push Notifications Setup Guide - EgyGo Guide

## Table of Contents
1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
3. [Android Configuration](#android-configuration)
4. [iOS Configuration](#ios-configuration)
5. [Backend Integration](#backend-integration)
6. [Testing Notifications](#testing-notifications)
7. [Troubleshooting](#troubleshooting)
8. [Common Issues](#common-issues)

---

## Overview

This guide explains how to set up and troubleshoot Firebase Cloud Messaging (FCM) for push notifications in the EgyGo Guide app. The notification system handles:

- **Guide Selection Notifications**: When a guide is selected for a trip
- **Trip Status Updates**: Trip confirmation, cancellation, etc.
- **Chat Messages**: New messages in trip chats
- **General Notifications**: System announcements

### Notification Flow
```
1. User logs in → FCM Token generated
2. App sends token to backend → Backend stores token
3. Backend event occurs → Backend sends notification via FCM
4. FCM delivers to device → App receives and displays notification
5. User taps notification → App navigates to relevant screen
```

---

## Prerequisites

### 1. Firebase Project Setup

**Required Files:**
- ✅ `google-services.json` (Android) - Located in `android/app/`
- ⚠️ `GoogleService-Info.plist` (iOS) - Should be in `ios/Runner/`

**Check if Firebase is configured:**
```bash
# Check Android
dir android\app\google-services.json

# Check iOS
dir ios\Runner\GoogleService-Info.plist
```

### 2. Dependencies (Already Installed ✅)
```yaml
firebase_core: ^3.8.1
firebase_messaging: ^15.1.5
flutter_local_notifications: ^18.0.1
```

---

## Android Configuration

### Step 1: Verify AndroidManifest.xml

**File:** `android/app/src/main/AndroidManifest.xml`

Required permissions (Already added ✅):
```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
<uses-permission android:name="android.permission.VIBRATE" />
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
<uses-permission android:name="android.permission.WAKE_LOCK" />
<uses-permission android:name="android.permission.INTERNET" />
```

### Step 2: Add Firebase Messaging Service (IMPORTANT! ⚠️)

**You may be missing this!** Add the following inside `<application>` tag in `AndroidManifest.xml`:

```xml
<application
    android:name="${applicationName}"
    android:icon="@mipmap/launcher_icon"
    android:label="EGYGoGuide">
    
    <!-- Existing activity code ... -->
    
    <!-- ADD THESE FOR NOTIFICATIONS TO WORK -->
    
    <!-- Firebase Cloud Messaging Service -->
    <service
        android:name="com.google.firebase.messaging.FirebaseMessagingService"
        android:exported="false"
        android:directBootAware="true">
        <intent-filter>
            <action android:name="com.google.firebase.messaging.MESSAGING_EVENT" />
        </intent-filter>
    </service>

    <!-- Firebase Messaging Receiver -->
    <receiver
        android:name="com.google.firebase.messaging.FirebaseMessagingReceiver"
        android:exported="true"
        android:permission="com.google.android.c2dm.permission.SEND">
        <intent-filter>
            <action android:name="com.google.android.c2dm.intent.RECEIVE" />
            <category android:name="${applicationId}" />
        </intent-filter>
    </receiver>

    <!-- Default Notification Channel -->
    <meta-data
        android:name="com.google.firebase.messaging.default_notification_channel_id"
        android:value="egygo_guide_channel" />
        
    <!-- Notification Icon (white/transparent PNG) -->
    <meta-data
        android:name="com.google.firebase.messaging.default_notification_icon"
        android:resource="@mipmap/ic_launcher" />
        
    <!-- Notification Color -->
    <meta-data
        android:name="com.google.firebase.messaging.default_notification_color"
        android:resource="@android:color/white" />
</application>
```

### Step 3: Verify build.gradle Files

**File:** `android/build.gradle`
```gradle
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.4.0'  // Must be 4.3.0 or higher
    }
}
```

**File:** `android/app/build.gradle`
```gradle
plugins {
    id "com.android.application"
    id "kotlin-android"
    id "dev.flutter.flutter-gradle-plugin"
}

// At the BOTTOM of the file
apply plugin: 'com.google.gms.google-services'
```

### Step 4: Runtime Permission Request (Android 13+)

For **Android 13 (API 33)** and above, you MUST request notification permission at runtime.

**Add this to your login flow or home screen:**

```dart
import 'package:permission_handler/permission_handler.dart';

Future<void> requestNotificationPermission() async {
  if (Platform.isAndroid) {
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    
    // Android 13+ requires runtime permission
    if (androidInfo.version.sdkInt >= 33) {
      final status = await Permission.notification.request();
      
      if (status.isGranted) {
        print('✅ Notification permission granted');
      } else if (status.isDenied) {
        print('❌ Notification permission denied');
      } else if (status.isPermanentlyDenied) {
        print('⚠️ Notification permission permanently denied');
        // Show dialog to open app settings
        await openAppSettings();
      }
    }
  }
}
```

---

## iOS Configuration

### Step 1: Add GoogleService-Info.plist

1. Download `GoogleService-Info.plist` from Firebase Console
2. Add to `ios/Runner/` directory in Xcode
3. Ensure it's added to the Runner target

### Step 2: Update Info.plist

**File:** `ios/Runner/Info.plist`

```xml
<dict>
    <!-- Existing keys ... -->
    
    <!-- Firebase Push Notifications -->
    <key>FirebaseMessagingAutoInitEnabled</key>
    <true/>
    
    <key>UIBackgroundModes</key>
    <array>
        <string>fetch</string>
        <string>remote-notification</string>
    </array>
</dict>
```

### Step 3: Enable Push Notifications Capability

1. Open `ios/Runner.xcworkspace` in Xcode
2. Select Runner target → **Signing & Capabilities**
3. Click **+ Capability**
4. Add **Push Notifications**
5. Add **Background Modes** → Check **Remote notifications**

### Step 4: APNs Authentication Key

1. Go to [Apple Developer Console](https://developer.apple.com/account/resources/authkeys/list)
2. Create an APNs Authentication Key
3. Upload to Firebase Console → Project Settings → Cloud Messaging → iOS

---

## Backend Integration

### Notification Payload Format

Your backend should send notifications in this format:

#### For FCM (Firebase)
```json
{
  "to": "USER_FCM_TOKEN",
  "notification": {
    "title": "Guide Selected",
    "body": "Ahmed has been selected as your guide for Cairo Trip"
  },
  "data": {
    "type": "guide_selected",
    "notificationId": "TRIP_ID_HERE",
    "click_action": "FLUTTER_NOTIFICATION_CLICK"
  },
  "priority": "high",
  "android": {
    "priority": "high",
    "notification": {
      "channel_id": "egygo_guide_channel"
    }
  }
}
```

### Notification Types in Your App

| Type | Description | Navigation |
|------|-------------|------------|
| `guide_selected` | Guide selected for trip | Trips Screen (Bottom Nav) |
| `trip_pending_confirmation` | Trip awaiting confirmation | Trip Details Screen |
| `NEW_MESSAGE` | New chat message | Trip Chat Screen |

### Backend Endpoints

Your app expects these endpoints:

```
POST /api/register-fcm-token
Body: { "token": "FCM_TOKEN" }
Headers: { "Authorization": "Bearer ACCESS_TOKEN" }

DELETE /api/remove-fcm-token
Body: { "token": "FCM_TOKEN" }
Headers: { "Authorization": "Bearer ACCESS_TOKEN" }
```

**Check your backend API implementation!**

---

## Testing Notifications

### Method 1: Firebase Console (Quick Test)

1. Go to Firebase Console → **Cloud Messaging**
2. Click **Send your first message**
3. Enter notification title and text
4. Click **Send test message**
5. Enter your FCM token (printed in console)
6. Click **Test**

### Method 2: Get FCM Token from App

Run your app and check the console:

```
[NotificationService] 🔑 FCM Token: eXaMpLe1234567890...
```

Copy this token for testing.

### Method 3: Test with curl (Backend Simulation)

```bash
curl -X POST https://fcm.googleapis.com/fcm/send \
  -H "Authorization: key=YOUR_SERVER_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "to": "USER_FCM_TOKEN",
    "notification": {
      "title": "Test Notification",
      "body": "This is a test"
    },
    "data": {
      "type": "guide_selected"
    }
  }'
```

Get your Server Key from Firebase Console → Project Settings → Cloud Messaging → Server key

---

## Troubleshooting

### Issue 1: "FCM Token is null"

**Symptoms:**
```
[NotificationService] ❌ FCM token not available after waiting
```

**Solutions:**
1. Check if `google-services.json` exists in `android/app/`
2. Verify Firebase initialization in `main.dart`
3. Check internet connection
4. Clear app data and reinstall

```bash
flutter clean
flutter pub get
flutter run
```

### Issue 2: "Notifications not appearing"

**Check these in order:**

1. **Permissions:**
```dart
// Check if notification permission is granted
final status = await Permission.notification.status;
print('Notification permission: $status');
```

2. **Token Registration:**
```dart
// Check if token is registered with backend
final registered = await NotificationService().registerToken();
print('Token registered: $registered');
```

3. **Android Notification Channel:**
   - Settings → Apps → EgyGo Guide → Notifications
   - Ensure "EgyGo Guide Notifications" channel is enabled

4. **Battery Optimization:**
   - Settings → Battery → Battery Optimization
   - Find your app and select "Don't optimize"

### Issue 3: "Token registration fails"

**Symptoms:**
```
[NotificationService] ❌ Failed to register token
```

**Debug Steps:**

1. Check if user is logged in:
```dart
final token = CacheHelper.getData(key: CacheKeys.accessToken);
print('Auth token: $token');
```

2. Check backend endpoint:
   - Verify endpoint exists: `POST /api/register-fcm-token`
   - Check if it requires authentication
   - Test with Postman

3. Check API helper configuration:
```dart
// In notification_service.dart, add more logging:
print('API Base URL: ${apiHelper.baseUrl}');
print('Request headers: ${apiHelper.headers}');
```

### Issue 4: "Background/Terminated notifications don't work"

**Required:** Background message handler must be a top-level function.

**In main.dart (Already implemented ✅):**
```dart
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('[Firebase Background] Message received: ${message.messageId}');
}

void main() async {
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(MyApp());
}
```

### Issue 5: "User Application Notifications Don't Work"

**This might be your issue!** If guide application notifications work but user notifications don't:

1. **Check User Role in Backend:**
   - Verify backend sends notifications to users with `role: "user"`
   - Check if backend has correct FCM tokens for users

2. **Check Token Registration on User Login:**
```dart
// In your login flow (auth/manager/login_cubit.dart)
// After successful login:
if (result.success) {
  final registered = await NotificationService().registerToken();
  if (!registered) {
    print('⚠️ Failed to register FCM token for user');
  }
}
```

3. **Check Backend User Endpoint:**
   - Verify user endpoint accepts FCM token registration
   - Test: `POST /api/register-fcm-token` with user auth token

4. **Check Notification Payload:**
   - Ensure backend sends correct `type` field
   - User notifications should have same format as guide notifications

---

## Common Issues

### 1. "No notification permission" on Android 13+

**Solution:** Request runtime permission before initializing notifications.

```dart
// Call this in your app startup or login screen
await Permission.notification.request();
```

### 2. "Duplicate meta-data" error

**Solution:** Remove duplicate entries in `AndroidManifest.xml`

### 3. "Token refresh not working"

**Solution:** Add token refresh listener:

```dart
FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
  print('Token refreshed: $newToken');
  await NotificationService().registerToken();
});
```

### 4. "Notification icon is black square"

**Solution:** Use a white/transparent PNG for notification icon:
- Create `ic_notification.png` (white icon on transparent background)
- Put in `android/app/src/main/res/drawable/`
- Update `AndroidManifest.xml`:
```xml
<meta-data
    android:name="com.google.firebase.messaging.default_notification_icon"
    android:resource="@drawable/ic_notification" />
```

---

## Implementation Checklist

Use this checklist to verify your setup:

### Firebase Configuration
- [ ] Firebase project created
- [ ] `google-services.json` added to `android/app/`
- [ ] `GoogleService-Info.plist` added to `ios/Runner/` (if iOS)
- [ ] Firebase dependencies added to `pubspec.yaml`
- [ ] Google Services plugin added to `android/app/build.gradle`

### Android Configuration
- [ ] Permissions added to `AndroidManifest.xml`
- [ ] Firebase Messaging Service declared in `AndroidManifest.xml` ⚠️ **CHECK THIS!**
- [ ] Notification channel metadata added
- [ ] Runtime permission requested (Android 13+)

### iOS Configuration (if applicable)
- [ ] Push Notifications capability enabled
- [ ] Background Modes enabled (remote notifications)
- [ ] APNs key uploaded to Firebase

### App Code
- [ ] `NotificationService` initialized in `main.dart`
- [ ] Background handler registered
- [ ] Token registration called after login
- [ ] Token removal called on logout
- [ ] Message handlers set up (foreground, background)

### Backend
- [ ] `/api/register-fcm-token` endpoint implemented
- [ ] `/api/remove-fcm-token` endpoint implemented
- [ ] Backend sends correct notification payload format
- [ ] Backend stores FCM tokens for both users and guides
- [ ] Backend sends notifications to correct user role

### Testing
- [ ] FCM token printed in console
- [ ] Token successfully registered with backend
- [ ] Foreground notifications appear
- [ ] Background notifications appear
- [ ] Terminated state notifications appear
- [ ] Notification tap navigation works
- [ ] Both user and guide receive notifications

---

## Debug Mode

Enable maximum logging to troubleshoot:

```dart
// In NotificationService initialization
void initialize() async {
  print('=== NOTIFICATION SERVICE DEBUG ===');
  print('Platform: ${Platform.operatingSystem}');
  print('Is Initialized: $_isInitialized');
  
  // ... rest of initialization
  
  print('FCM Token: $_fcmToken');
  print('Auth Token exists: ${CacheHelper.getData(key: CacheKeys.accessToken) != null}');
  print('=== END DEBUG ===');
}
```

Run your app and share the console output for further debugging.

---

## Need More Help?

1. **Check Console Logs:** Look for `[NotificationService]` messages
2. **Test with Firebase Console:** Send test notification directly
3. **Verify Backend:** Test endpoints with Postman
4. **Check Network:** Ensure device has internet connection
5. **Review Backend Logs:** Check if notifications are being sent

**Key Files to Review:**
- `lib/core/services/notification_service.dart` (Already implemented ✅)
- `lib/main.dart` (Firebase initialization)
- `android/app/src/main/AndroidManifest.xml` (Android permissions & services)
- Backend notification sending logic

---

## Summary

Your notification system is mostly set up correctly! The most likely issues are:

1. ⚠️ **Missing Firebase Messaging Service in AndroidManifest.xml**
2. ⚠️ **Android 13+ runtime permission not requested**
3. ⚠️ **Backend not sending notifications to users (only guides)**
4. ⚠️ **User FCM token not registered with backend**

Follow this guide step by step, and your notifications should work for both guides and users! 🎉

