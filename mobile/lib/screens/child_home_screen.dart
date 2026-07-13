import 'package:flutter/material.dart';

import '../api/growly_api_client.dart';
import '../models/demo_bootstrap.dart';
import '../storage/device_preferences.dart';
import '../widgets/error_state.dart';
import '../widgets/growly_button.dart';
import '../widgets/loading_state.dart';
import 'child_pairing_screen.dart';
import 'child_task_screen.dart';
import 'curriculum_screen.dart';
import 'settings_screen.dart';

class ChildHomeScreen extends StatefulWidget {
  const ChildHomeScreen({
    super.key,
    required this.apiClient,
    required this.preferences,
    required this.onResetRole,
  });
  final GrowlyApiClient apiClient;
  final DevicePreferences preferences;
  final Future<void> Function() onResetRole;
  @override
  State<ChildHomeScreen> createState() => _ChildHomeScreenState();
}

class _ChildHomeScreenState extends State<ChildHomeScreen> {
  late Future<DemoBootstrap> _bootstrap;
  @override
  void initState() {
    super.initState();
    _bootstrap = widget.apiClient.demoBootstrap();
  }

  void _retry() =>
      setState(() => _bootstrap = widget.apiClient.demoBootstrap());
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: FutureBuilder<DemoBootstrap>(
        future: _bootstrap,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done)
            return const LoadingState(message: 'Готовим твоё занятие…');
          if (snapshot.hasError || !snapshot.hasData)
            return ErrorState(message: '${snapshot.error}', onRetry: _retry);
          final demo = snapshot.data!;
          widget.preferences.saveChildId(demo.child.id);
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: ListView(
                padding: const EdgeInsets.all(26),
                children: [
                  Text(
                    'Привет, ${demo.child.name}! 🌱',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text('Учимся маленькими шагами.'),
                  const SizedBox(height: 28),
                  GrowlyButton(
                    label: 'Продолжить обучение',
                    icon: Icons.play_circle_fill_rounded,
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => ChildTaskScreen(
                          apiClient: widget.apiClient,
                          child: demo.child,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  GrowlyButton(
                    label: 'Карта уровней',
                    icon: Icons.map_rounded,
                    secondary: true,
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => CurriculumScreen(
                          apiClient: widget.apiClient,
                          childId: demo.child.id,
                          childMode: true,
                          child: demo.child,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  GrowlyButton(
                    label: 'Показать код родителю',
                    icon: Icons.qr_code_rounded,
                    secondary: true,
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => ChildPairingScreen(
                          apiClient: widget.apiClient,
                          childId: demo.child.id,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  GrowlyButton(
                    label: 'Настройки',
                    icon: Icons.settings_rounded,
                    secondary: true,
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => SettingsScreen(
                          apiClient: widget.apiClient,
                          onResetRole: widget.onResetRole,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ),
  );
}
