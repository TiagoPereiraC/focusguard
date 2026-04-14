import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui';

import 'model/stats_repository.dart';
import 'services/notification_service.dart';
import 'theme/app_palette.dart';
import 'viewmodel/focus_viewmodel.dart';
import 'views/pages/home_page.dart';
import 'views/pages/tos_dialog.dart';

const String _themeModePrefKey = 'theme_mode';
const String _tosAcceptedPrefKey = 'tos_accepted';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await NotificationService().initialize();
  
  final Brightness systemBrightness =
      PlatformDispatcher.instance.platformBrightness;
  final ThemeMode initialThemeMode = systemBrightness == Brightness.dark
      ? ThemeMode.dark
      : ThemeMode.light;

  runApp(FocusGuardApp(
    initialThemeMode: initialThemeMode,
  ));
}

class FocusGuardApp extends StatefulWidget {
  final ThemeMode initialThemeMode;

  const FocusGuardApp({
    super.key,
    required this.initialThemeMode,
  });

  @override
  State<FocusGuardApp> createState() => _FocusGuardAppState();
}

class _FocusGuardAppState extends State<FocusGuardApp> {
  late final FocusViewModel _focusViewModel;
  late ThemeMode _themeMode;
  bool _prefsLoaded = false;
  late bool _tosAccepted;
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _focusViewModel = FocusViewModel(repository: StatsRepository());
    _themeMode = widget.initialThemeMode;
    _tosAccepted = true;
    _loadInitialPreferences();
  }

  Future<void> _loadInitialPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? storedTheme = prefs.getString(_themeModePrefKey);
    final bool tosAccepted = prefs.getBool(_tosAcceptedPrefKey) ?? false;

    ThemeMode resolvedThemeMode = _themeMode;
    if (storedTheme == ThemeMode.dark.name) {
      resolvedThemeMode = ThemeMode.dark;
    } else if (storedTheme == ThemeMode.light.name) {
      resolvedThemeMode = ThemeMode.light;
    } else {
      await prefs.setString(_themeModePrefKey, _themeMode.name);
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _themeMode = resolvedThemeMode;
      _tosAccepted = tosAccepted;
      _prefsLoaded = true;
    });

    if (!_tosAccepted) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _checkToS());
    }
  }

  Future<void> _checkToS() async {
    if (!_prefsLoaded) return;
    final BuildContext? ctx = _navigatorKey.currentContext;
    if (ctx == null || !mounted) return;

    final bool accepted =
        await showToSDialog(ctx, canDismiss: false, requireAcceptance: true) ?? false;

    if (accepted) {
      await _setTosAccepted(true);
    } else {
      SystemNavigator.pop();
    }
  }

  Future<void> _setTosAccepted(bool value) async {
    if (_tosAccepted == value) return;
    setState(() => _tosAccepted = value);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_tosAcceptedPrefKey, value);
  }

  @override
  void dispose() {
    _focusViewModel.dispose();
    super.dispose();
  }

  Future<void> _toggleTheme() async {
    final ThemeMode newThemeMode = _themeMode == ThemeMode.dark
        ? ThemeMode.light
        : ThemeMode.dark;

    setState(() {
      _themeMode = newThemeMode;
    });

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModePrefKey, newThemeMode.name);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: 'FocusGuard',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      themeAnimationDuration: const Duration(milliseconds: 180),
      themeAnimationCurve: Curves.linear,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: CPalette.c4,
          onPrimary: Colors.white,
          secondary: CPalette.c5,
          onSecondary: CPalette.c1,
          error: Color(0xFFB3261E),
          onError: Colors.white,
          surface: CPalette.c9,
          onSurface: CPalette.c1,
          primaryContainer: CPalette.c8,
          onPrimaryContainer: CPalette.c1,
          secondaryContainer: CPalette.c7,
          onSecondaryContainer: CPalette.c1,
          tertiary: CPalette.c3,
          onTertiary: Colors.white,
          tertiaryContainer: CPalette.c6,
          onTertiaryContainer: CPalette.c1,
          errorContainer: Color(0xFFF9DEDC),
          onErrorContainer: Color(0xFF410E0B),
          surfaceContainerLowest: Color(0xFFFFFFFF),
          surfaceContainerLow: Color(0xFFF7FBFD),
          surfaceContainer: Color(0xFFF2F8FB),
          surfaceContainerHigh: Color(0xFFECF4F8),
          surfaceContainerHighest: Color(0xFFE4EEF4),
          onSurfaceVariant: CPalette.c2,
          outline: CPalette.c4,
          outlineVariant: CPalette.c6,
          shadow: Colors.black,
          scrim: Colors.black,
          inverseSurface: CPalette.c1,
          onInverseSurface: CPalette.c9,
          inversePrimary: CPalette.c6,
          surfaceTint: CPalette.c4,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme(
          brightness: Brightness.dark,
          primary: CPalette.c6,
          onPrimary: CPalette.c1,
          secondary: CPalette.c5,
          onSecondary: CPalette.c0,
          error: Color(0xFFF2B8B5),
          onError: Color(0xFF601410),
          surface: Color(0xFF071119),
          onSurface: CPalette.c9,
          primaryContainer: CPalette.c2,
          onPrimaryContainer: CPalette.c9,
          secondaryContainer: CPalette.c3,
          onSecondaryContainer: CPalette.c9,
          tertiary: CPalette.c7,
          onTertiary: CPalette.c1,
          tertiaryContainer: CPalette.c2,
          onTertiaryContainer: CPalette.c9,
          errorContainer: Color(0xFF8C1D18),
          onErrorContainer: Color(0xFFF9DEDC),
          surfaceContainerLowest: Color(0xFF040B11),
          surfaceContainerLow: Color(0xFF0B1620),
          surfaceContainer: Color(0xFF101D28),
          surfaceContainerHigh: Color(0xFF162632),
          surfaceContainerHighest: Color(0xFF1C303D),
          onSurfaceVariant: CPalette.c7,
          outline: CPalette.c5,
          outlineVariant: CPalette.c3,
          shadow: Colors.black,
          scrim: Colors.black,
          inverseSurface: CPalette.c8,
          onInverseSurface: CPalette.c1,
          inversePrimary: CPalette.c3,
          surfaceTint: CPalette.c6,
        ),
      ),
      home: HomePage(
        viewModel: _focusViewModel,
        isDarkMode: _themeMode == ThemeMode.dark,
        onToggleTheme: _toggleTheme,
        tosAccepted: _tosAccepted,
        onSetTosAccepted: _setTosAccepted,
      ),
    );
  }
}
