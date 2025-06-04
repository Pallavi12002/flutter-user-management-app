import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/network/api_client.dart';
import '../data/repositories/user_repository.dart';
import '../data/services/api_service.dart';
import '../presentation/bloc/theme/theme_bloc.dart';
import '../presentation/bloc/user_detail/user_detail_bloc.dart';
import '../presentation/bloc/user_list/user_list_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Initialize external dependencies first
  await _initExternal();

  // Initialize core dependencies
  _initCore();

  // Initialize data layer
  _initData();

  // Initialize presentation layer
  _initPresentation();
}

/// Initialize external dependencies (async)
Future<void> _initExternal() async {
  try {
    final sharedPreferences = await SharedPreferences.getInstance();
    sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
  } catch (e) {
    // Handle SharedPreferences initialization error
    throw Exception('Failed to initialize SharedPreferences: $e');
  }
}

/// Initialize core dependencies
void _initCore() {
  // Register ApiClient as singleton
  sl.registerLazySingleton<ApiClient>(() => ApiClient());
}

/// Initialize data layer dependencies
void _initData() {
  // Register ApiService with explicit type and dependency
  sl.registerLazySingleton<ApiService>(
        () => ApiService(sl<ApiClient>()),
  );

  // Register UserRepository with explicit dependencies
  sl.registerLazySingleton<UserRepository>(
        () => UserRepository(
      sl<ApiService>(),
      sl<SharedPreferences>(),
    ),
  );
}

/// Initialize presentation layer dependencies
void _initPresentation() {
  // Register BLoCs as factories (new instance each time)
  sl.registerFactory<UserListBloc>(
        () => UserListBloc(sl<UserRepository>()),
  );

  sl.registerFactory<UserDetailBloc>(
        () => UserDetailBloc(sl<UserRepository>()),
  );

  sl.registerFactory<ThemeBloc>(
        () => ThemeBloc(sl<SharedPreferences>()),
  );
}

/// Optional: Method to reset all dependencies (useful for testing)
Future<void> reset() async {
  await sl.reset();
}

/// Optional: Check if dependencies are registered
bool get isInitialized => sl.isRegistered<SharedPreferences>();