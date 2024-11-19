import 'package:flutter/material.dart';

class ConstrainedScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? drawer;
  final Color? backgroundColor;

  const ConstrainedScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.drawer,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      drawer: drawer,
      backgroundColor: backgroundColor,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 430,
          ),
          child: body,
        ),
      ),
    );
  }
}
