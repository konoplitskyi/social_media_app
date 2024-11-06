import 'package:flutter/material.dart';

void showMessage(
  BuildContext context, {
  required String message,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Center(
        child: Text(message),
      ),
    ),
  );
}
