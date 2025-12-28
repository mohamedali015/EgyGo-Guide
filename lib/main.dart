import 'package:egy_go_guide/core/cache/cache_helper.dart';
import 'package:egy_go_guide/core/helper/custom_bloc_observer.dart';
import 'package:egy_go_guide/core/helper/get_it.dart';
import 'package:egy_go_guide/core/helper/one_generate_routes.dart';
import 'package:egy_go_guide/core/user/data/repo/user_repo.dart';
import 'package:egy_go_guide/core/user/manager/user_cubit/user_cubit.dart';
import 'package:egy_go_guide/core/utils/app_theme.dart';
import 'package:egy_go_guide/core/services/notification_service.dart';
import 'package:egy_go_guide/core/services/global_socket_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'features/governorates/data/repos/governorates_repo/governorates_repo.dart';
import 'features/governorates/manager/governorates_cubit/governorates_cubit.dart';
import 'features/places/data/repos/places_repo/places_repo.dart';
import 'features/places/manager/place_category_cubit/place_category_cubit.dart';
import 'features/places/manager/places_cubit/places_cubit.dart';
import 'features/splash_and_onboarding/views/splash_view.dart';

/// Background message handler - must be top-level function
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('[Firebase Background] Message received: ${message.messageId}');
  print('[Firebase Background] Data: ${message.data}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase (skip if not configured)
  try {
    await Firebase.initializeApp();
    print('[Firebase] ✅ Initialized successfully');

    // Set background message handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Initialize notification service
    final notificationService = NotificationService();
    await notificationService.initialize();
    notificationService.setupMessageHandlers();

    // Check for initial notification after app starts
    Future.delayed(const Duration(seconds: 2), () {
      notificationService.checkInitialNotification();
    });
  } catch (e) {
    print('[Firebase] ⚠️ Not configured yet. Using Socket.IO for real-time notifications.');
    print('[Firebase] Add google-services.json to enable background notifications.');
  }

  // Initialize Global Socket Service for real-time in-app notifications
  print('[App] 🌐 Initializing Global Socket Service...');
  Future.delayed(const Duration(seconds: 3), () async {
    try {
      final globalSocket = GlobalSocketService();
      await globalSocket.initialize();
      print('[App] ✅ Global Socket Service ready for notifications');
    } catch (e) {
      print('[App] ⚠️ Global Socket Service initialization failed: $e');
    }
  });

  Bloc.observer = CustomBlocObserver();
  await CacheHelper.init();
  setupGetIt();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(428, 926),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider<GovernoratesCubit>(
              create: (context) => GovernoratesCubit(getIt<GovernoratesRepo>())
                ..fetchGovernorates(),
            ),
            BlocProvider<PlacesCubit>(
              create: (context) =>
                  PlacesCubit(getIt<PlacesRepo>())..fetchPlaces(),
            ),
            BlocProvider<UserCubit>(
              create: (context) => UserCubit(getIt<UserRepo>()),
            ),
            BlocProvider<PlaceCategoryCubit>(
              create: (context) => PlaceCategoryCubit(getIt<PlacesRepo>()),
            ),
          ],
          child: GetMaterialApp(
            title: 'EgyGo',
            debugShowCheckedModeBanner: false,
            onGenerateRoute: onGenerateRoutes,
            initialRoute: SplashView.routeName,
            theme: AppTheme.lightTheme,
          ),
        );
      },
    );
  }
}
