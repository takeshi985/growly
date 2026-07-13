import 'package:flutter/material.dart';

import 'api/growly_api_client.dart';
import 'screens/home_screen.dart';

class GrowlyApp extends StatefulWidget {
  const GrowlyApp({super.key, this.apiClient});

  final GrowlyApiClient? apiClient;

  @override
  State<GrowlyApp> createState() => _GrowlyAppState();
}

class _GrowlyAppState extends State<GrowlyApp> {
  late final GrowlyApiClient _apiClient;

  @override
  void initState() {
    super.initState();
    _apiClient = widget.apiClient ?? GrowlyApiClient();
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
    home: HomeScreen(apiClient: _apiClient),
  );
}
