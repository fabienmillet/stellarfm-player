// widgets/now_playing_title_bar.dart
import 'dart:io';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';

class NowPlayingTitleBar extends StatelessWidget {
  const NowPlayingTitleBar({super.key});

  @override
  Widget build(BuildContext context) {
  if (!Platform.isWindows && !Platform.isMacOS && !Platform.isLinux) {
  return const SizedBox.shrink(); // Pas de titre sur mobile
  }
    return WindowTitleBarBox(
      child: Container(
        height: 40,
        color: Colors.black.withAlpha((0.85 * 255).toInt()),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: [
            Expanded(
              child: MoveWindow(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "StellarFM",
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                ),
              ),
            ),
            MinimizeWindowButton(),
            MaximizeWindowButton(),
            CloseWindowButton(),
          ],
        ),
      ),
    );
  }
}
