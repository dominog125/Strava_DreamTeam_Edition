import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'features/activity/data/models/activity_model.dart';
import 'features/auth/data/models/auth_tokens_model.dart';

import 'core/di/injector.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  // AUTH TOKENS (Hive cache)
  Hive.registerAdapter(AuthTokensModelAdapter());
  await Hive.openBox<AuthTokensModel>('auth_tokens');

  // ACTIVITIES (Hive)
  Hive.registerAdapter(ActivityModelAdapter());
  await Hive.openBox<ActivityModel>('activities');

  final prefs = await SharedPreferences.getInstance();
  setupInjector(prefs);

  runApp(const MiniStravaApp());
}

