import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'features/activity/data/models/activity_model.dart'; // ⬅️ WAŻNE
import 'core/di/injector.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(ActivityModelAdapter()); // ⬅️ teraz istnieje
  await Hive.openBox<ActivityModel>('activities');

  final prefs = await SharedPreferences.getInstance();
  setupInjector(prefs);

  runApp(const MiniStravaApp());
}
