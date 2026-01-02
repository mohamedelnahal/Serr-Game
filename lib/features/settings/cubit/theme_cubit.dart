import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.light) {
    _loadTheme();
  }

  void _loadTheme() {
    final box = Hive.box(
        'settings'); // Assuming a settings box exists or we'll create one
    final isDark = box.get('isDark', defaultValue: false);
    emit(isDark ? ThemeMode.dark : ThemeMode.light);
  }

  void toggleTheme() {
    final newMode = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    final box = Hive.box('settings');
    box.put('isDark', newMode == ThemeMode.dark);
    emit(newMode);
  }
}
