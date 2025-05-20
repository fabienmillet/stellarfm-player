import 'package:flutter/foundation.dart'; // 👈 pour kIsWeb
import 'package:flutter/material.dart';

/// Import conditionnel pour bitsdojo_window
import 'package:bitsdojo_window/bitsdojo_window.dart'
    if (dart.library.html) 'stub_bitsdojo.dart';

class NowPlayingTitleBar extends StatelessWidget {
  const NowPlayingTitleBar({super.key});

  @override
  Widget build(BuildContext context) {
    // ❌ Ne pas afficher sur Web ou mobile
    if (kIsWeb) return const SizedBox.shrink();

    final isDesktop = [
      TargetPlatform.windows,
      TargetPlatform.macOS,
      TargetPlatform.linux,
    ].contains(defaultTargetPlatform);

    if (!isDesktop) return const SizedBox.shrink();

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
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
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
