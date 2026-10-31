import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({Key? key, required this.child}) : super(key: key);

  static const BoxDecoration tealGradientDecoration = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFF00382E),
        Color(0xFF004D40),
        Color(0xFF00695C),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider?>(context);
    final scaffoldBg = Theme.of(context).scaffoldBackgroundColor;
    final isTealTheme = (themeProvider?.isTealTheme ?? false) ||
        scaffoldBg == Colors.teal ||
        scaffoldBg == const Color(0xFF00695C);

    if (!isTealTheme) return child;

    return Container(
      decoration: tealGradientDecoration,
      child: child,
    );
  }
}
