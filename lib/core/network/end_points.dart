abstract class EndPoints {
  static const String baseUrl = 'https://egygo-backend-production.up.railway.app/api/';

  static const String register = 'auth/register';
  static const String login = 'auth/login';
  static const String verifyOtp = 'auth/verify-otp';
  static const String resendOtp = 'auth/resend-otp';
  static const String resetPassword = 'auth/reset-password';
  static const String forgetPassword = 'auth/forget-password';
  static const String getUserData =
      'guide/profile'; // Changed from 'auth/me' to 'guide/profile'
  static const String refreshToken = 'auth/refresh';
  static const String getGovernorates = 'provinces';
  static const String getPlaces = 'provinces/giza/places?type=archaeological';
  static const String createTrip = 'guide/trips';
  static const String getMyTrips = 'guide/trips';
  static const String applyAsGuide = 'guide/apply';
  static const String updateProfile =
      'guide/profile'; // Add update profile endpoint

  // FCM Token endpoints
  static const String registerFcmToken = 'auth/fcm-token';
  static const String removeFcmToken = 'auth/fcm-token';

  static String searchHome(String query) {
    return 'places/search?q=$query';
  }

  static String getPlacesByCategory(String category, String governorate) {
    return 'provinces/$governorate/places?type=$category';
  }

  static String getTripDetails(String tripId) {
    return 'guide/trips/$tripId';
  }

  static String cancelTrip(String tripId) {
    return 'guide/trips/$tripId/cancel';
  }

  // static String initiateCallTrip(String tripId) {
  //   return 'trips/$tripId/calls/initiate';
  // }

  static String joinCall(String callId) {
    return 'calls/$callId/join';
  }

  static String acceptTrip(String tripId) {
    return 'guide/trips/$tripId/accept';
  }

  static String rejectTrip(String tripId) {
    return 'guide/trips/$tripId/reject';
  }

  static String startTrip(String tripId) {
    return 'trips/$tripId/start';
  }

  static String endTrip(String tripId) {
    return 'trips/$tripId/end';
  }

  static String getChatHistory(String tripId) {
    return 'chat/$tripId/messages';
  }
}
