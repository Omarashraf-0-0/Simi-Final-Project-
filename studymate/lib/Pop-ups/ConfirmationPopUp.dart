// ConfirmationPopUp.dart

import 'package:flutter/material.dart';

class ConfirmationPopUp extends StatelessWidget {
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const ConfirmationPopUp({
    super.key,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        "Submit Quiz",
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: const Text(
        "Are you sure you want to submit the quiz?",
        style: TextStyle(fontSize: 18),
      ),
      actions: [
        TextButton(
          onPressed: onCancel,
          child: const Text(
            "No",
            style: TextStyle(fontSize: 18),
          ),
        ),
        ElevatedButton(
          onPressed: onConfirm,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF165D96),
          ),
          child: const Text(
            "Yes",
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
      ],
    );
  }
}