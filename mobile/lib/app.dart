import 'package:flutter/material.dart';

import 'api/growly_api_client.dart';
import 'screens/child_home_screen.dart';
import 'screens/child_setup_screen.dart';
import 'screens/parent_home_screen.dart';
import 'screens/role_selection_screen.dart';
import 'storage/device_preferences.dart';
import 'theme/growly_theme.dart';

class GrowlyApp extends StatefulWidget {
  const GrowlyApp({super.key, this.apiClient, this.preferences});

  final GrowlyApiClient? apiClient;
  final DevicePreferences? preferences;

  @override
  State<GrowlyApp> createState() => _GrowlyAppState();
}

class _GrowlyAppState extends State<GrowlyApp> {
  late final GrowlyApiClient _apiClient;
  late final DevicePreferences _preferences;
  DeviceSetup? _setup;
  DeviceRole? _pendingRole;
  bool _openChildPairing = false;

  @override
  void initState() {
    super.initState();
    _apiClient = widget.apiClient ?? GrowlyApiClient();
    _preferences = widget.preferences ?? DevicePreferences();
    _loadSetup();
  }

  Future<void> _loadSetup() async {
    final setup = await _preferences.load();
    if (mounted) setState(() => _setup = setup);
  }

  Future<void> _completeChildSetup({required bool connectParent}) async {
    await _preferences.saveRole(DeviceRole.child);
    final setup = await _preferences.load();
    if (!mounted) return;

    setState(() {
      _setup = setup;
      _pendingRole = null;
      _openChildPairing = connectParent;
    });
  }

  Future<void> _completeParentSetup() async {
    await _preferences.saveRole(DeviceRole.parent);
    final setup = await _preferences.load();
    if (!mounted) return;

    setState(() {
      _setup = setup;
      _pendingRole = null;
    });
  }

  Future<void> _resetRole() async {
    await _preferences.clear();
    if (!mounted) return;
    setState(() {
      _setup = const DeviceSetup();
      _pendingRole = null;
      _openChildPairing = false;
    });
  }

  @override
  void dispose() {
    if (widget.apiClient == null) _apiClient.close();
    super.dispose();
  }

  Widget _home() {
    if (_pendingRole == DeviceRole.child) {
      return ChildSetupScreen(
        onBack: () => setState(() => _pendingRole = null),
        onComplete: _completeChildSetup,
      );
    }
    if (_pendingRole == DeviceRole.parent) {
      return _ParentConfirmation(
        onBack: () => setState(() => _pendingRole = null),
        onConfirm: _completeParentSetup,
      );
    }
    if (_setup!.role == null) {
      return RoleSelectionScreen(
        onSelected: (role) => setState(() => _pendingRole = role),
      );
    }
    if (_setup!.role == DeviceRole.child) {
      return ChildHomeScreen(
        apiClient: _apiClient,
        preferences: _preferences,
        openParentPairing: _openChildPairing,
        onPairingOpened: () => setState(() => _openChildPairing = false),
        onResetRole: _resetRole,
      );
    }
    return ParentHomeScreen(
      apiClient: _apiClient,
      preferences: _preferences,
      setup: _setup!,
      onSetupChanged: _loadSetup,
      onResetRole: _resetRole,
    );
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Growly',
    debugShowCheckedModeBanner: false,
    theme: GrowlyTheme.build(),
    home: _setup == null
        ? const Scaffold(body: Center(child: CircularProgressIndicator()))
        : _home(),
  );
}

class _ParentConfirmation extends StatelessWidget {
  const _ParentConfirmation({required this.onBack, required this.onConfirm});

  final VoidCallback onBack;
  final Future<void> Function() onConfirm;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      leading: IconButton(
        onPressed: onBack,
        icon: const Icon(Icons.arrow_back_rounded),
      ),
    ),
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('👨‍👩‍👧', style: TextStyle(fontSize: 60)),
                const SizedBox(height: 16),
                Text(
                  'Это устройство будет использовать родитель?',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'После этого нужно будет подключиться к профилю ребёнка. Роль можно изменить в любой момент.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),
                FilledButton(
                  onPressed: onConfirm,
                  child: const Text('Да, продолжить'),
                ),
                const SizedBox(height: 12),
                OutlinedButton(onPressed: onBack, child: const Text('Назад')),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
