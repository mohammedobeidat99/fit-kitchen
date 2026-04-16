import 'package:flutter/material.dart';

class SnackbarHelper {
  static final GlobalKey<ScaffoldMessengerState> key = GlobalKey<ScaffoldMessengerState>();

  static void show(String message, {bool isError = true, SnackBarAction? action, Duration? duration}) {
    key.currentState?.hideCurrentSnackBar();
    key.currentState?.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
        behavior: SnackBarBehavior.floating,
        action: action,
        duration: duration ?? const Duration(seconds: 4),
      ),
    );
  }
}
