import 'package:flutter/widgets.dart';

class WindowTitleBarBox extends StatelessWidget {
  final Widget child;
  const WindowTitleBarBox({required this.child, super.key});

  @override
  Widget build(BuildContext context) => child;
}

class MoveWindow extends StatelessWidget {
  final Widget child;
  const MoveWindow({required this.child, super.key});

  @override
  Widget build(BuildContext context) => child;
}

class MinimizeWindowButton extends StatelessWidget {
  const MinimizeWindowButton({super.key});
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

class MaximizeWindowButton extends StatelessWidget {
  const MaximizeWindowButton({super.key});
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

class CloseWindowButton extends StatelessWidget {
  const CloseWindowButton({super.key});
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
