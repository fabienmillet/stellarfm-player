import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:bitsdojo_window/bitsdojo_window.dart';

import 'views/now_playing/now_playing_page.dart';

void main() {
  runApp(const StellarFMApp());

  if (!kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux)) {
    doWhenWindowReady(() {
      const initialSize = Size(400, 700);
      appWindow.minSize = initialSize;
      appWindow.size = initialSize;
      appWindow.alignment = Alignment.center;
      appWindow.show();
    });
  }
}

class StellarFMApp extends StatelessWidget {
  const StellarFMApp({super.key});

  @override
  Widget build(BuildContext context) {
    if (kIsWeb || Platform.isAndroid || Platform.isLinux) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'StellarFM',
        theme: ThemeData.dark(),
        home: const NowPlayingPage(platform: 'material'),
      );
    } else if (Platform.isIOS || Platform.isMacOS) {
      return CupertinoApp(
        debugShowCheckedModeBanner: false,
        title: 'StellarFM',
        theme: const CupertinoThemeData(brightness: Brightness.dark),
        home: const NowPlayingPage(platform: 'cupertino'),
      );
    } else if (Platform.isWindows) {
      return fluent.FluentApp(
        debugShowCheckedModeBanner: false,
        title: 'StellarFM',
        theme: fluent.FluentThemeData(brightness: fluent.Brightness.dark),
        home: const NowPlayingPage(platform: 'fluent'),
      );
    } else {
      return MaterialApp(
        home: Scaffold(
          body: Center(child: Text("Unsupported platform")),
        ),
      );
    }
  }
}
