import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mini_strava/features/auth/data/models/auth_tokens_model.dart';
import 'package:mini_strava/features/activity/data/models/activity_model.dart';
import 'package:mini_strava/features/activity_history/data/models/activity_history_hive_model.dart';

import 'package:mini_strava/core/di/injector.dart';
import 'package:mini_strava/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();


  Hive.registerAdapter(AuthTokensModelAdapter());
  await Hive.openBox<AuthTokensModel>('auth_tokens');


  Hive.registerAdapter(ActivityModelAdapter());
  await Hive.openBox<ActivityModel>('activities');


  Hive.registerAdapter(SyncStatusAdapter());
  Hive.registerAdapter(ActivityHistoryHiveModelAdapter());
  await Hive.openBox<ActivityHistoryHiveModel>('activity_history');

  final prefs = await SharedPreferences.getInstance();
  setupInjector(prefs);

  runApp(const MiniStravaApp());
}
