import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'di/injection_container.dart' as di;
import 'presentation/bloc/theme/theme_bloc.dart';
import 'presentation/bloc/user_list/user_list_bloc.dart';
import 'presentation/pages/user_list_page.dart';
import 'core/constants/app_constants.dart';
import 'package:flutter_assignment_task/presentation/bloc/theme/theme_state.dart';
import 'package:flutter_assignment_task/data/repositories/user_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for local storage
  await Hive.initFlutter();

  // Initialize dependencies
  await di.init();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (context) => di.sl<UserRepository>(),
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => di.sl<ThemeBloc>()),
          BlocProvider(create: (_) => di.sl<UserListBloc>()),
        ],
        child: BlocBuilder<ThemeBloc, ThemeState>(
          builder: (context, state) {
            return MaterialApp(
              title: 'User Management App',
              debugShowCheckedModeBanner: false,
              theme: AppConstants.lightTheme,
              darkTheme: AppConstants.darkTheme,
              themeMode: state.isDarkMode ? ThemeMode.dark : ThemeMode.light,
              home: UserListPage(),
            );
          },
        ),
      ),
    );
  }
}