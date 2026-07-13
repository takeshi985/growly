import 'package:flutter/material.dart';

import 'api/growly_api_client.dart';
import 'screens/child_home_screen.dart';
import 'screens/parent_home_screen.dart';
import 'screens/role_selection_screen.dart';
import 'storage/device_preferences.dart';

class GrowlyApp extends StatefulWidget {
  const GrowlyApp({super.key, this.apiClient});

  final GrowlyApiClient? apiClient;

  @override
  State<GrowlyApp> createState() => _GrowlyAppState();
}

class _GrowlyAppState extends State<GrowlyApp> {
  late final GrowlyApiClient _apiClient;
  final DevicePreferences _preferences = DevicePreferences();
  DeviceSetup? _setup;

  @override
  void initState() {
    super.initState();
    _apiClient = widget.apiClient ?? GrowlyApiClient();
    _loadSetup();
  }

  Future<void> _loadSetup() async {
    final setup = await _preferences.load();
    if (mounted) setState(() => _setup = setup);
  }

  Future<void> _selectRole(DeviceRole role) async {
    await _preferences.saveRole(role);
    await _loadSetup();
  }

  Future<void> _resetRole() async {
    await _preferences.clear();
    await _loadSetup();
  }

  @override
  void dispose() {
    if (widget.apiClient == null) _apiClient.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Growly',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF4B7B55),
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: const Color(0xFFF6F8F2),
      cardTheme: const CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(22)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    ),
    home: _setup == null
        ? const Scaffold(body: Center(child: CircularProgressIndicator()))
        : _setup!.role == null
        ? RoleSelectionScreen(onSelected: _selectRole)
        : _setup!.role == DeviceRole.child
        ? ChildHomeScreen(
            apiClient: _apiClient,
            preferences: _preferences,
            onResetRole: _resetRole,
          )
        : ParentHomeScreen(
            apiClient: _apiClient,
            preferences: _preferences,
            setup: _setup!,
            onSetupChanged: _loadSetup,
            onResetRole: _resetRole,
          ),
  );
}
