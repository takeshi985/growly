import 'package:flutter/material.dart';

import '../api/growly_api_client.dart';
import '../models/demo_bootstrap.dart';
import '../widgets/error_state.dart';
import '../widgets/growly_button.dart';
import '../widgets/loading_state.dart';
import 'child_task_screen.dart';
import 'curriculum_screen.dart';
import 'parent_progress_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.apiClient});

  final GrowlyApiClient apiClient;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<DemoBootstrap> _bootstrap;

  @override
  void initState() {
    super.initState();
    _bootstrap = widget.apiClient.demoBootstrap();
  }

  void _retry() => setState(() {
    _bootstrap = widget.apiClient.demoBootstrap();
  });

  void _open(Widget screen) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: FutureBuilder<DemoBootstrap>(
        future: _bootstrap,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const LoadingState(message: 'Знакомимся с Growly…');
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return ErrorState(
              message:
                  'Не получилось подключиться к backend. Проверь, что Phoenix '
                  'запущен на http://localhost:4000 или http://10.0.2.2:4000.\n\n'
                  '${snapshot.error ?? ''}',
              onRetry: _retry,
            );
          }
          final bootstrap = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.fromLTRB(22, 28, 22, 36),
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFDFF2D8), Color(0xFFF4E7B9)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('🌱', style: TextStyle(fontSize: 46)),
                    const SizedBox(height: 10),
                    Text(
                      'Growly',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF31583A),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Маленькие шаги к школе',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 8,
                  ),
                  leading: const CircleAvatar(child: Text('М')),
                  title: Text(bootstrap.child.name),
                  subtitle: Text(
                    '${bootstrap.child.age} лет · backend подключён',
                  ),
                  trailing: const Icon(Icons.cloud_done_rounded),
                ),
              ),
              const SizedBox(height: 24),
              GrowlyButton(
                label: 'Режим ребёнка',
                icon: Icons.play_circle_fill_rounded,
                onPressed: () => _open(
                  ChildTaskScreen(
                    apiClient: widget.apiClient,
                    child: bootstrap.child,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              GrowlyButton(
                label: 'Прогресс родителя',
                icon: Icons.insights_rounded,
                secondary: true,
                onPressed: () => _open(
                  ParentProgressScreen(
                    apiClient: widget.apiClient,
                    childId: bootstrap.child.id,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              GrowlyButton(
                label: 'Карта обучения',
                icon: Icons.map_rounded,
                secondary: true,
                onPressed: () => _open(
                  CurriculumScreen(
                    apiClient: widget.apiClient,
                    childId: bootstrap.child.id,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              GrowlyButton(
                label: 'Настройки подключения',
                icon: Icons.settings_ethernet_rounded,
                secondary: true,
                onPressed: () =>
                    _open(SettingsScreen(apiClient: widget.apiClient)),
              ),
            ],
          );
        },
      ),
    ),
  );
}
