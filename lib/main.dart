import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'services/notification_service.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/task_viewmodel.dart';
import 'views/splash/splash_page.dart';
import 'views/tasks/task_detail_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Background FCM handler
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Local notifications initialize
  await NotificationService().initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => TaskViewModel()),
      ],
      child: MaterialApp(
        title: 'Firebase Task Manager',
        debugShowCheckedModeBanner: false,
        navigatorKey: navigatorKey,
        theme: ThemeData(
          useMaterial3: true,
          fontFamily: 'Inter',
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4F46E5)),
        ),
        home: const SplashPage(),
        onGenerateRoute: (settings) {
          if (settings.name == '/task_detail') {
            final taskId = settings.arguments as String;
            return MaterialPageRoute(
              builder: (_) => TaskDetailPage(taskId: taskId),
            );
          }
          return null;
        },
      ),
    );
  }
}