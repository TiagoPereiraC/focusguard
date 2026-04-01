import 'package:flutter/material.dart';

import 'model/stats_repository.dart';
import 'viewmodel/focus_viewmodel.dart';
import 'views/pages/home_page.dart';

void main() {
  runApp(const FocusGuardApp());
}

class FocusGuardApp extends StatefulWidget {
  const FocusGuardApp({super.key});

  @override
  State<FocusGuardApp> createState() => _FocusGuardAppState();
}

class _FocusGuardAppState extends State<FocusGuardApp> {
  late final FocusViewModel _focusViewModel;

  @override
  void initState() {
    super.initState();
    _focusViewModel = FocusViewModel(repository: StatsRepository());
  }

  @override
  void dispose() {
    _focusViewModel.dispose();
    super.dispose();
  }

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
      home: HomePage(viewModel: _focusViewModel),
    );
  }
}
