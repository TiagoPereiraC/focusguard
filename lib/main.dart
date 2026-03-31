import 'package:flutter/material.dart';
import 'views/pages/home_page.dart';

void main() {
  runApp(const FocusGuardApp());
}

class FocusGuardApp extends StatelessWidget {
  const FocusGuardApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FocusGuard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.blue,
        primaryColor: Colors.blue.shade600,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const HomePage(),
    );
  }
}
