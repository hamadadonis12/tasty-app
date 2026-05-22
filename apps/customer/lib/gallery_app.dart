import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';

import 'gallery/gallery_screen.dart';

/// Alternative entry point: a screen gallery showing every Stitch screen.
///
/// Run with:
///   flutter run -t lib/gallery_app.dart
///
/// The production app continues to boot from `lib/main.dart`.
void main() {
  runApp(const GalleryApp());
}

class GalleryApp extends StatelessWidget {
  const GalleryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TastyLife — Gallery',
      debugShowCheckedModeBanner: false,
      theme: TastyTheme.lightTheme,
      darkTheme: TastyTheme.darkTheme,
      home: const GalleryScreen(),
    );
  }
}
