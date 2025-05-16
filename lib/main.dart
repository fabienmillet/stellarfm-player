import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:window_manager/window_manager.dart';

import 'views/now_playing/now_playing_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Si on est sur desktop (Windows/macOS/Linux), configure la fenêtre
  if (!kIsWeb && (Platform.isMacOS || Platform.isWindows || Platform.isLinux)) {
    await windowManager.ensureInitialized();

    WindowOptions windowOptions = const WindowOptions(
      size: Size(400, 700),
      center: true,
      backgroundColor: Colors.transparent,
      titleBarStyle: TitleBarStyle.hidden, // ✅ enlève le bandeau moche
    );

    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  runApp(StellarFMApp());
}

class StellarFMApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Web, Android, Linux → Material Design
    if (kIsWeb || Platform.isAndroid || Platform.isLinux) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'StellarFM',
        theme: ThemeData.dark(),
        home: const NowPlayingPage(platform: 'material'),
      );

    // iOS, macOS → Cupertino
    } else if (Platform.isIOS || Platform.isMacOS) {
      return CupertinoApp(
        debugShowCheckedModeBanner: false,
        title: 'StellarFM',
        theme: const CupertinoThemeData(
          brightness: Brightness.dark,
        ),
        home: const NowPlayingPage(platform: 'cupertino'),
      );

    // Windows → Fluent UI
    } else if (Platform.isWindows) {
      return fluent.FluentApp(
        debugShowCheckedModeBanner: false,
        title: 'StellarFM',
        theme: fluent.FluentThemeData(
          brightness: fluent.Brightness.dark,
        ),
        home: const NowPlayingPage(platform: 'fluent'),
      );

    // Fallback
    } else {
      return MaterialApp(
        home: Scaffold(
          body: Center(child: Text("Unsupported platform")),
        ),
      );
    }
  }
}
