import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'screens/home_page.dart';
import 'screens/loading_screen.dart'; // Наш экран загрузки
import 'utils/app_theme.dart';

final FlutterLocalNotificationsPlugin notificationsPlugin = FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
      
  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);
      
  await notificationsPlugin.initialize(initializationSettings);

  runApp(const NuvitApp());
}

class NuvitApp extends StatelessWidget {
  const NuvitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NUVIT',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme, // Глобальная тема NUVIT Cyberpunk
      home: LoadingScreen(), // 🔥 Запускаем экран загрузки без const
    );
  }
}