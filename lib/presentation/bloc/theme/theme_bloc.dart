import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme_event.dart';
import 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final SharedPreferences _prefs;

  ThemeBloc(this._prefs) : super(ThemeState(isDarkMode: false)) {
    on<ToggleTheme>(_onToggleTheme);
    on<LoadTheme>(_onLoadTheme);

    add(LoadTheme());
  }

  void _onToggleTheme(ToggleTheme event, Emitter<ThemeState> emit) async {
    final newTheme = !state.isDarkMode;
    await _prefs.setBool('isDarkMode', newTheme);
    emit(ThemeState(isDarkMode: newTheme));
  }

  void _onLoadTheme(LoadTheme event, Emitter<ThemeState> emit) {
    final isDarkMode = _prefs.getBool('isDarkMode') ?? false;
    emit(ThemeState(isDarkMode: isDarkMode));
  }
}