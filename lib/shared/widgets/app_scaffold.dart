import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class AppScaffold extends StatelessWidget {
  final Widget body;
  final String? title;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final BottomNavigationBar? bottomNavigationBar;
  final Color? backgroundColor;
  final bool useSafeArea;

  const AppScaffold({
    super.key,
    required this.body,
    this.title,
    this.actions,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.backgroundColor,
    this.useSafeArea = true,
  });

  @override
  Widget build(BuildContext context) {
    final scaffold = Scaffold(
      backgroundColor: backgroundColor,
      appBar: title != null
          ? AppBar(
              title: Text(title!),
              actions: actions,
            )
          : null,
      body: useSafeArea ? SafeArea(child: body) : body,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
    );

    return scaffold;
  }
}
