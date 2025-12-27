import 'package:flutter/material.dart';

import '../../features/auth/views/get_started_view.dart';
import '../../features/auth/views/login_view.dart';
import '../../features/auth/views/register_view.dart';
import '../../features/auth/views/widgets/reset_password_widgets/forget_password_flow.dart';
import '../../features/governorates/views/governorates_category_view.dart';
import '../../features/governorates/views/governorates_view.dart';
import '../../features/guide_application/presentation/views/apply_guide_screen.dart';
import '../../features/home/views/app_home_view.dart';
import '../../features/home_search/view/home_search_view.dart';
import '../../features/places/views/places_view.dart';
import '../../features/splash_and_onboarding/views/on_boarding_view.dart';
import '../../features/splash_and_onboarding/views/splash_view.dart';
import '../../features/trip/views/trip_chat_screen.dart';

Route<dynamic> onGenerateRoutes(RouteSettings settings) {
  switch (settings.name) {
    case SplashView.routeName:
      return MaterialPageRoute(
        builder: (_) => const SplashView(),
        settings: settings,
      );

    case OnBoardingView.routeName:
      return MaterialPageRoute(
        builder: (_) => const OnBoardingView(),
        settings: settings,
      );

    case GetStartedView.routeName:
      return MaterialPageRoute(
        builder: (_) => const GetStartedView(),
        settings: settings,
      );

    case LoginView.routeName:
      return MaterialPageRoute(
        builder: (_) => const LoginView(),
        settings: settings,
      );

    case ForgetPasswordFlow.routeName:
      return MaterialPageRoute(
        builder: (_) => ForgetPasswordFlow(),
        settings: settings,
      );

    case RegisterView.routeName:
      return MaterialPageRoute(
        builder: (_) => const RegisterView(),
        settings: settings,
      );

    case ApplyGuideScreen.routeName:
      return MaterialPageRoute(
        builder: (_) => const ApplyGuideScreen(),
        settings: settings,
      );

    case AppHomeView.routeName:
      return MaterialPageRoute(
        builder: (_) => const AppHomeView(),
        settings: settings,
      );

    case HomeSearchView.routeName:
      return MaterialPageRoute(
        builder: (_) => const HomeSearchView(),
        settings: settings,
      );

    // case CreateTripImageView.routeName:
    //   return MaterialPageRoute(
    //     builder: (_) => const CreateTripImageView(),
    //     settings: settings,
    //   );
    //
    // case CreateTripFormView.routeName:
    //   return MaterialPageRoute(
    //     builder: (_) => const CreateTripFormView(),
    //     settings: settings,
    //   );
    //
    case GovernoratesView.routeName:
      return MaterialPageRoute(
        builder: (_) => const GovernoratesView(),
        settings: settings,
      );

    case GovernoratesCategoryView.routeName:
      return MaterialPageRoute(
        builder: (_) => const GovernoratesCategoryView(),
        settings: settings,
      );

    case PlacesView.routeName:
      return MaterialPageRoute(
        builder: (_) => const PlacesView(),
        settings: settings,
      );

    case TripChatScreen.routeName:
      final args = settings.arguments as Map<String, dynamic>;
      return MaterialPageRoute(
        builder: (_) => TripChatScreen(
          tripId: args['tripId'] as String,
          touristName: args['touristName'] as String,
        ),
        settings: settings,
      );
    //
    // case GuidesView.routeName:
    //   return MaterialPageRoute(
    //     builder: (_) => const GuidesView(),
    //     settings: settings,
    //   );
    //
    // case SelectGuideScreen.routeName:
    //   final tripId = settings.arguments as String;
    //   return MaterialPageRoute(
    //     builder: (_) => SelectGuideScreen(tripId: tripId),
    //     settings: settings,
    //   );
    //
    // case TripDetailsScreen.routeName:
    //   final tripId = settings.arguments as String;
    //   return MaterialPageRoute(
    //     builder: (_) => TripDetailsScreen(tripId: tripId),
    //     settings: settings,
    //   );
    //
    // case TripsScreen.routeName:
    //   return MaterialPageRoute(
    //     builder: (_) => const TripsScreen(),
    //     settings: settings,
    //   );
    //
    // case AgoraCallScreen.routeName:
    //   final args = settings.arguments as Map<String, dynamic>;
    //   return MaterialPageRoute(
    //     builder: (_) => AgoraCallScreen(
    //       appId: args['appId'] as String,
    //       channelName: args['channelName'] as String,
    //       token: args['token'] as String,
    //       uid: args['uid'] as int,
    //       callId: args['callId'] as String,
    //       tripId: args['tripId'] as String,
    //     ),
    //     settings: settings,
    //   );
    //
    // case EndCallFormScreen.routeName:
    //   final args = settings.arguments as Map<String, dynamic>;
    //   return MaterialPageRoute(
    //     builder: (_) => EndCallFormScreen(
    //       callId: args['callId'] as String,
    //       tripId: args['tripId'] as String,
    //     ),
    //     settings: settings,
    //   );

    default:
      return MaterialPageRoute(
        builder: (_) => const SplashView(),
        settings: settings,
      );
  }
}
