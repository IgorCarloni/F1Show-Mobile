import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'theme/app_theme.dart';
import 'router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const F1ShowApp());
}

class F1ShowApp extends StatelessWidget {
  const F1ShowApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp.router(
        title: 'F1 Show',
        theme: F1Theme.theme,
        routerConfig: router,
        debugShowCheckedModeBanner: false,
      );
}
