import 'package:flutter/material.dart';
import 'package:mini_strava/core/widgets/offline_placeholder.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: OfflinePlaceholder(),
    );
  }
}