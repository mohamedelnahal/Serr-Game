import 'package:flutter/material.dart';
import 'package:serr/features/game/game_setup_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:serr/main.dart';
import 'package:serr/core/widgets/background_container.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Add this
import 'package:serr/features/settings/cubit/theme_cubit.dart'; // Add this

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BackgroundContainer(
      withImage: true,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
              color: Theme.of(context).iconTheme.color, // Color from theme
              size: 35,
            ),
            onPressed: () {
              context.read<ThemeCubit>().toggleTheme();
            },
          ),
          actions: [
            PopupMenuButton<Locale>(
              icon: Icon(Icons.language,
                  color: Theme.of(context).iconTheme.color, // Color from theme
                  size: 40),
              onSelected: (Locale locale) {
                SerrApp.setLocale(context, locale);
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                    value: const Locale('ar'),
                    child: Text("🇪🇬 ${l10n.egyptianArabic}")),
                PopupMenuItem(
                    value: const Locale('en'),
                    child: Text("🇺🇸 ${l10n.english}")),
              ],
            ),
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo / Title
              // Logo / Title
              Stack(
                children: [
                  // Black Border (Stroke)
                  Text(
                    l10n.appTitle,
                    style: GoogleFonts.luckiestGuy(
                      fontSize: 80,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4,
                      foreground: Paint()
                        ..style = PaintingStyle.stroke
                        ..strokeWidth = 8
                        ..color =
                            Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : Colors.black,
                    ),
                  ),
                  // Filled Text
                  Text(
                    l10n.appTitle,
                    style: GoogleFonts.luckiestGuy(
                      fontSize: 80,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                      letterSpacing: 4,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 60),

              // Start Button
              SizedBox(
                width: 200,
                height: 60,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor, // Purple
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    elevation: 10,
                    shadowColor:
                        Theme.of(context).primaryColor.withOpacity(0.6),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const GameSetupScreen()),
                    );
                  },
                  child: Text(
                    l10n.newGame, // "Start Game" or "New Game"
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
