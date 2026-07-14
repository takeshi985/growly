import 'package:flutter/material.dart';

import '../api/growly_api_client.dart';
import '../models/demo_bootstrap.dart';
import '../storage/device_preferences.dart';
import '../theme/growly_theme.dart';
import '../widgets/error_state.dart';
import '../widgets/growly_button.dart';
import '../widgets/growly_card.dart';
import '../widgets/growly_category_card.dart';
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
    this.openParentPairing = false,
    this.onPairingOpened,
  });
  final GrowlyApiClient apiClient;
  final DevicePreferences preferences;
  final Future<void> Function() onResetRole;
  final bool openParentPairing;
  final VoidCallback? onPairingOpened;
  @override
  State<ChildHomeScreen> createState() => _ChildHomeScreenState();
}

class _ChildHomeScreenState extends State<ChildHomeScreen> {
  late Future<DemoBootstrap> _bootstrap;
  bool _pairingOpened = false;
  @override
  void initState() {
    super.initState();
    _bootstrap = widget.apiClient.demoBootstrap();
  }

  void _retry() =>
      setState(() => _bootstrap = widget.apiClient.demoBootstrap());
  Future<void> _openPairing(int childId) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            ChildPairingScreen(apiClient: widget.apiClient, childId: childId),
      ),
    );

    if (!mounted) return;

    setState(() => _bootstrap = widget.apiClient.demoBootstrap());
    widget.onPairingOpened?.call();
  }

  void _maybeOpenPairing(DemoBootstrap demo) {
    if (!widget.openParentPairing || _pairingOpened) return;
    _pairingOpened = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await _openPairing(demo.child.id);
    });
  }

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
          _maybeOpenPairing(demo);
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: ListView(
                padding: const EdgeInsets.all(22),
                children: [
                  Row(
                    children: [
                      Text(
                        'Growly',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: GrowlyTheme.darkGreen,
                            ),
                      ),
                      const Spacer(),
                      const CircleAvatar(
                        backgroundColor: GrowlyTheme.softYellow,
                        child: Text('🦖'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Привет, ${demo.child.name}!',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const Text('Готов учиться и расти?'),
                  const SizedBox(height: 16),
                  GrowlyCard(
                    color: GrowlyTheme.softGreen,
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Твой прогресс',
                                style: TextStyle(fontWeight: FontWeight.w800),
                              ),
                              const SizedBox(height: 8),
                              const Text('Уровень 1'),
                              const SizedBox(height: 8),
                              const LinearProgressIndicator(
                                value: .2,
                                minHeight: 9,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(8),
                                ),
                              ),
                              const SizedBox(height: 7),
                              const Text('До следующего уровня: 80 XP'),
                            ],
                          ),
                        ),
                        const Text('🌱', style: TextStyle(fontSize: 58)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Продолжить обучение',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GrowlyCard(
                    color: GrowlyTheme.softPurple,
                    child: Row(
                      children: [
                        const Text('🏔️', style: TextStyle(fontSize: 48)),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Математика',
                                style: TextStyle(fontWeight: FontWeight.w800),
                              ),
                              Text('Короткое задание уже ждёт'),
                            ],
                          ),
                        ),
                        FilledButton(
                          onPressed: () => _openTask(demo),
                          child: const Text('Играть'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Категории',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  GridView.count(
                    crossAxisCount: MediaQuery.sizeOf(context).width > 620
                        ? 3
                        : 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.18,
                    children: [
                      GrowlyCategoryCard(
                        emoji: '1+2',
                        title: 'Математика',
                        subtitle: 'Задания',
                        onTap: () => _openTask(demo),
                      ),
                      GrowlyCategoryCard(
                        emoji: '📖',
                        title: 'Чтение',
                        subtitle: 'Задания',
                        color: GrowlyTheme.softYellow,
                        onTap: () => _openMap(demo),
                      ),
                      GrowlyCategoryCard(
                        emoji: '🧩',
                        title: 'Логика',
                        subtitle: 'Карта уровней',
                        color: GrowlyTheme.softPurple,
                        onTap: () => _openMap(demo),
                      ),
                      GrowlyCategoryCard(
                        emoji: '🎨',
                        title: 'Творчество',
                        subtitle: 'Скоро',
                        color: const Color(0xFFFFE9D0),
                        onTap: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  GrowlyButton(
                    label: 'Подключить телефон родителя',
                    icon: Icons.link_rounded,
                    secondary: true,
                    onPressed: () => _openPairing(demo.child.id),
                  ),
                  const SizedBox(height: 10),
                  GrowlyButton(
                    label: 'Настройки',
                    icon: Icons.settings_rounded,
                    secondary: true,
                    onPressed: () => _openSettings(demo),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ),
  );

  void _openTask(DemoBootstrap demo) => Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) =>
          ChildTaskScreen(apiClient: widget.apiClient, child: demo.child),
    ),
  );
  void _openMap(DemoBootstrap demo) => Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => CurriculumScreen(
        apiClient: widget.apiClient,
        childId: demo.child.id,
        childMode: true,
        child: demo.child,
      ),
    ),
  );
  void _openSettings(DemoBootstrap demo) => Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => SettingsScreen(
        apiClient: widget.apiClient,
        role: DeviceRole.child,
        childId: demo.child.id,
        onResetRole: widget.onResetRole,
        onOpenChildPairing: () => _openPairing(demo.child.id),
      ),
    ),
  );
}
