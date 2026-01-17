import 'package:flutter/material.dart';

class ActOgrHistoryScreen extends StatelessWidget {
  const ActOgrHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historia aktywności'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: const Center(
        child: Text(
          'Historia aktywności\n(w trakcie budowy)',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
