import 'package:egy_go_guide/core/user/data/repo/user_repo.dart';
import 'package:egy_go_guide/core/user/data/repo/user_repo_impl.dart';
import 'package:get_it/get_it.dart';

import '../../features/auth/data/repo/auth_repo.dart';
import '../../features/auth/data/repo/auth_repo_impl.dart';
import '../../features/governorates/data/repos/governorates_repo/governorates_repo.dart';
import '../../features/governorates/data/repos/governorates_repo/governorates_repo_impl.dart';
import '../../features/guide_application/data/repos/guide_application_repo.dart';
import '../../features/home_search/data/repo/home_search_repo.dart';
import '../../features/home_search/data/repo/home_search_repo_impl.dart';
import '../../features/places/data/repos/places_repo/places_repo.dart';
import '../../features/places/data/repos/places_repo/places_repo_impl.dart';
import '../../features/trip/data/repos/trip_repo.dart';
import '../../features/trip/data/repos/trip_repo_impl.dart';
import '../../features/trip/data/repos/chat_repo.dart';
import '../../features/trip/data/repos/chat_repo_impl.dart';
import '../network/api_helper.dart';

final getIt = GetIt.instance;

void setupGetIt() {
  getIt.registerSingleton<ApiHelper>(ApiHelper());

  getIt.registerSingleton<AuthRepo>(
    AuthRepoImpl(apiHelper: getIt<ApiHelper>()),
  );

  getIt.registerSingleton<GuideApplicationRepo>(
    GuideApplicationRepo(apiHelper: getIt<ApiHelper>()),
  );
  //
  getIt.registerSingleton<UserRepo>(
    UserRepoImpl(apiHelper: getIt<ApiHelper>()),
  );
  //
  getIt.registerSingleton<GovernoratesRepo>(
      GovernoratesRepoImpl(apiHelper: getIt<ApiHelper>()));

  getIt.registerSingleton<PlacesRepo>(
      PlacesRepoImpl(apiHelper: getIt<ApiHelper>()));

  getIt.registerSingleton<HomeSearchRepo>(
      HomeSearchRepoImpl(apiHelper: getIt<ApiHelper>()));

  getIt.registerSingleton<TripRepo>(
      TripRepoImpl(apiHelper: getIt<ApiHelper>()));

  getIt.registerSingleton<ChatRepo>(
      ChatRepoImpl(apiHelper: getIt<ApiHelper>()));
  //
  // getIt.registerSingleton<CreateTripFormRepo>(
  //     CreateTripFormRepoImpl(getIt<ApiHelper>()));
  //
  // getIt.registerSingleton<GuidesRepo>(
  //     GuidesRepoImpl(apiHelper: getIt<ApiHelper>()));
}
