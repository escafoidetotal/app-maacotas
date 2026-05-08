import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'services/hive_service.dart';
import 'core/utils/notification_service.dart';
import 'services/admob_service.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await HiveService.initialize();

  // Initialize notifications
  await NotificationService().initialize();

  // Initialize AdMob
  await AdmobService().initialize();

  runApp(
    const ProviderScope(
      child: MaaCotasApp(),
    ),
  );
}
