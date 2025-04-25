// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class AIDescriptionDialog extends StatelessWidget {
  final List<String> suggestions;
  final Color primaryColor;
  final Color accentColor;

  // ignore: use_key_in_widget_constructors
  const AIDescriptionDialog({
    required this.suggestions,
    required this.primaryColor,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        'AI-Generated Descriptions',
        style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: suggestions.map((description) {
            return ListTile(
              title: Text(description),
              onTap: () => Navigator.pop(context, description),
              contentPadding: const EdgeInsets.symmetric(horizontal: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              tileColor: Colors.grey.shade50,
              hoverColor: accentColor.withOpacity(0.1),
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel', style: TextStyle(color: primaryColor)),
        ),
      ],
    );
  }
}