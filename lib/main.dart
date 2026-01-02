import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'core/models/player.dart';
import 'core/models/topic.dart';
import 'features/game/cubit/game_cubit.dart';

import 'features/settings/cubit/theme_cubit.dart';
import 'features/splash/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Hive Setup
  await Hive.initFlutter();
  Hive.registerAdapter(PlayerAdapter());
  Hive.registerAdapter(TopicAdapter());

  await Hive.openBox<Player>('players');
  await Hive.openBox<Topic>('topics');
  await Hive.openBox('settings');

  runApp(const SerrApp());
}

class SerrApp extends StatefulWidget {
  const SerrApp({super.key});

  static void setLocale(BuildContext context, Locale newLocale) {
    _SerrAppState? state = context.findAncestorStateOfType<_SerrAppState>();
    state?.setLocale(newLocale);
  }

  @override
  State<SerrApp> createState() => _SerrAppState();
}

class _SerrAppState extends State<SerrApp> {
  Locale _locale = const Locale('en'); // Default to English

  void setLocale(Locale newLocale) {
    setState(() {
      _locale = newLocale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => GameCubit()..loadPlayers()),
        BlocProvider(create: (context) => ThemeCubit()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp(
            title: 'Serr',
            debugShowCheckedModeBanner: false,
            themeMode: themeMode,
            theme: ThemeData(
              brightness: Brightness.light,
              scaffoldBackgroundColor: const Color(0xFFF5F5F5), // Light Gray
              primaryColor: const Color(0xFFFFC03D), // Light Purple
              colorScheme: const ColorScheme.light(
                primary: Color(0xFFFFC03D), // Light Purple
                secondary: Color(0xFFFFC03D), // Light Purple
                tertiary: Color(0xFF1D1E33), // Dark Blue Text Color
                surface: Color(0xFFF5F5F5), // Light Gray Card BG
                onSurface: Color(0xFF1D1E33), // Dark Blue Text Color
              ),
              textTheme:
                  GoogleFonts.cairoTextTheme(ThemeData.light().textTheme).apply(
                bodyColor: const Color(0xFF1D1E33), // Dark Blue
                displayColor: const Color(0xFF1D1E33), // Dark Blue
              ),
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.transparent,
                elevation: 0,
                centerTitle: true,
                titleTextStyle: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1D1E33)), // Dark Blue Title
                iconTheme:
                    IconThemeData(color: Color(0xFFFFC03D)), // Purple Icons
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFC03D), // Purple Buttons
                  foregroundColor: Colors.white, // White text on Purple
                  elevation: 4,
                  shadowColor: const Color(0xFFFFC03D).withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  textStyle: GoogleFonts.cairo(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: Colors.white.withOpacity(0.7),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Color(0xFFFFC03D)), // Purple
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                      color: const Color(0xFFFFC03D).withOpacity(0.5)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Color(0xFFFFC03D), width: 2),
                ),
                hintStyle:
                    TextStyle(color: const Color(0xFF1D1E33).withOpacity(0.6)),
              ),
              iconTheme: const IconThemeData(color: Color(0xFFFFC03D)),
              popupMenuTheme: const PopupMenuThemeData(
                color: Color(0xFFF5F5F5), // Light Gray
                textStyle: TextStyle(color: Color(0xFF1D1E33)),
              ),
              dialogBackgroundColor:
                  const Color(0xFFF5F5F5), // Light Gray for Dialogs
            ),
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              scaffoldBackgroundColor:
                  const Color(0xFF121212), // Dark Background
              primaryColor: const Color(0xFFFFC03D), // Gold
              colorScheme: const ColorScheme.dark(
                primary: Color(0xFFFFC03D), // Gold
                secondary: Color(0xFFFFC03D), // Gold
                tertiary: Colors.white, // White Text Color
                surface: Color(0xFF1E1E1E), // Dark Card BG
                onSurface: Colors.white, // White Text Color
              ),
              textTheme:
                  GoogleFonts.cairoTextTheme(ThemeData.dark().textTheme).apply(
                bodyColor: Colors.white,
                displayColor: Colors.white,
              ),
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.transparent,
                elevation: 0,
                centerTitle: true,
                titleTextStyle: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white), // White Title
                iconTheme:
                    IconThemeData(color: Color(0xFFFFC03D)), // Gold Icons
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFC03D), // Gold Buttons
                  foregroundColor: Colors.black, // Black text on Gold
                  elevation: 4,
                  shadowColor: const Color(0xFFFFC03D).withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  textStyle: GoogleFonts.cairo(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: const Color(0xFF2C2C2C).withOpacity(0.7),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Color(0xFFFFC03D)), // Gold
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                      color: const Color(0xFFFFC03D).withOpacity(0.5)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Color(0xFFFFC03D), width: 2),
                ),
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
              ),
              iconTheme: const IconThemeData(color: Color(0xFFFFC03D)),
              popupMenuTheme: const PopupMenuThemeData(
                color: Color(0xFF2C2C2C), // Dark Gray
                textStyle: TextStyle(color: Colors.white),
              ),
              dialogBackgroundColor:
                  const Color(0xFF2C2C2C), // Dark Gray for Dialogs
              switchTheme: SwitchThemeData(
                thumbColor: WidgetStateProperty.all(const Color(0xFFFFC03D)),
                trackColor: WidgetStateProperty.all(
                    const Color(0xFFFFC03D).withOpacity(0.5)),
              ),
              checkboxTheme: CheckboxThemeData(
                fillColor: WidgetStateProperty.all(const Color(0xFFFFC03D)),
                checkColor: WidgetStateProperty.all(Colors.black),
              ),
              sliderTheme: SliderThemeData(
                activeTrackColor: const Color(0xFFFFC03D),
                thumbColor: const Color(0xFFFFC03D),
                inactiveTrackColor: const Color(0xFFFFC03D).withOpacity(0.3),
              ),
            ),
            locale: _locale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en'),
              Locale('ar'),
            ],
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
