import 'package:flutter/material.dart';

class BackgroundContainer extends StatelessWidget {
  final bool withImage;
  final Widget child;

  const BackgroundContainer({
    super.key,
    required this.child,
    this.withImage = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: withImage
            ? DecorationImage(
                image: AssetImage(
                    Theme.of(context).brightness == Brightness.dark
                        ? 'assets/dark_background.png'
                        : 'assets/background.png'),
                fit: BoxFit.cover,
              )
            : null,
        gradient: withImage
            ? null
            : LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: Theme.of(context).brightness == Brightness.dark
                    ? [
                        const Color(0xFF2C2C2C), // Dark Gray Top
                        const Color(0xFF121212), // Darker Gray Bottom
                      ]
                    : [
                        const Color(0xFFF0D5A8), // Light Wood
                        const Color(0xFFD4AF83), // Medium Wood
                      ],
              ),
      ),
      child: child,
    );
  }
}
