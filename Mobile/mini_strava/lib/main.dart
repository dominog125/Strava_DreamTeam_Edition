import 'package:flutter/material.dart';
import 'app.dart';
import 'core/di/injector.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupInjector();
  runApp(const MiniStravaApp());
}
//sprawdzam