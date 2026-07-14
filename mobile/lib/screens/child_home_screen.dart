import 'package:flutter/material.dart';

import '../api/growly_api_client.dart';
import '../models/child_session.dart';
import '../models/demo_bootstrap.dart';
import '../models/gamification.dart';
import '../storage/device_preferences.dart';
import '../theme/growly_tokens.dart';
import '../widgets/error_state.dart';
import '../widgets/growly_button.dart';
import '../widgets/growly_card.dart';
import '../widgets/growly_metric_chip.dart';
import '../widgets/growly_progress_bar.dart';
import '../widgets/loading_state.dart';
import 'child_pairing_screen.dart';
import 'child_profile_screen.dart';
import 'child_task_screen.dart';
import 'curriculum_screen.dart';
import 'daily_goals_screen.dart';
import 'rewards_screen.dart';
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
  late Future<_ChildHomeData> _data;
  bool _pairingOpened = false;
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    _data = _fetch();
  }

  Future<_ChildHomeData> _fetch() async {
    final demo = await widget.apiClient.demoBootstrap();
    await widget.preferences.saveChildId(demo.child.id);
    final session = await widget.apiClient.childSession(demo.child.id);
    return _ChildHomeData(demo: demo, session: session);
  }

  void _retry() => setState(() => _data = _fetch());

  Future<void> _openPairing(int childId) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            ChildPairingScreen(apiClient: widget.apiClient, childId: childId),
      ),
    );
    if (!mounted) return;
    setState(() => _data = _fetch());
    widget.onPairingOpened?.call();
  }

  void _maybeOpenPairing(DemoBootstrap demo) {
    if (!widget.openParentPairing || _pairingOpened) return;
    _pairingOpened = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) await _openPairing(demo.child.id);
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      bottom: false,
      child: FutureBuilder<_ChildHomeData>(
        future: _data,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const LoadingState(message: 'Готовим твоё приключение…');
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return ErrorState(message: '${snapshot.error}', onRetry: _retry);
          }

          final data = snapshot.data!;
          _maybeOpenPairing(data.demo);
          final game = data.session.gamification;
          final child = data.demo.child;
          final pages = <Widget>[
            _LearnHome(
              data: data,
              gamification: game,
              onContinue: () => _openTask(data.demo),
              onOpenMap: () => _openMap(data.demo),
            ),
            DailyGoalsScreen(gamification: game),
            RewardsScreen(gamification: game),
            ChildProfileScreen(
              child: child,
              gamification: game,
              onOpenPairing: () => _openPairing(child.id),
              onOpenSettings: () => _openSettings(data.demo),
            ),
          ];

          return IndexedStack(index: _tab, children: pages);
        },
      ),
    ),
    bottomNavigationBar: NavigationBar(
      selectedIndex: _tab,
      onDestinationSelected: (index) => setState(() => _tab = index),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.route_outlined),
          selectedIcon: Icon(Icons.route_rounded),
          label: 'Учиться',
        ),
        NavigationDestination(
          icon: Icon(Icons.checklist_rounded),
          selectedIcon: Icon(Icons.task_alt_rounded),
          label: 'Цели',
        ),
        NavigationDestination(
          icon: Icon(Icons.emoji_events_outlined),
          selectedIcon: Icon(Icons.emoji_events_rounded),
          label: 'Награды',
        ),
        NavigationDestination(
          icon: Icon(Icons.face_outlined),
          selectedIcon: Icon(Icons.face_rounded),
          label: 'Профиль',
        ),
      ],
    ),
  );

  Future<void> _openTask(DemoBootstrap demo) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            ChildTaskScreen(apiClient: widget.apiClient, child: demo.child),
      ),
    );
    if (mounted) setState(() => _data = _fetch());
  }

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

class _LearnHome extends StatelessWidget {
  const _LearnHome({
    required this.data,
    required this.gamification,
    required this.onContinue,
    required this.onOpenMap,
  });

  final _ChildHomeData data;
  final GamificationSnapshot gamification;
  final VoidCallback onContinue;
  final VoidCallback onOpenMap;

  @override
  Widget build(BuildContext context) {
    final child = data.demo.child;
    final nextTask = data.session.nextTask;
    return ListView(
      key: const PageStorageKey('learn-home'),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 120),
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Growly',
                    style: TextStyle(
                      color: GrowlyColors.brand,
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    'Привет, ${child.name}!',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const Text('Куда отправимся сегодня?'),
                ],
              ),
            ),
            SizedBox(
              width: 92,
              height: 92,
              child: Image.asset(
                'assets/images/dyno.png',
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
                semanticLabel: 'Динозаврик Growly',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: GrowlyMetricChip(
                icon: Icons.stars_rounded,
                value: '${gamification.xp}',
                label: 'XP',
                color: GrowlyColors.accent,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: GrowlyMetricChip(
                icon: Icons.local_fire_department_rounded,
                value: '${gamification.streakDays}',
                label: 'серия',
                color: GrowlyColors.accent,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: GrowlyMetricChip(
                icon: Icons.military_tech_rounded,
                value: '${gamification.level}',
                label: 'уровень',
                color: GrowlyColors.imagination,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        GrowlyCard(
          color: GrowlyColors.brandSoft,
          child: GrowlyProgressBar(
            value: gamification.dailyCompleted / gamification.dailyTarget,
            label:
                'Цель дня · ${gamification.dailyCompleted}/${gamification.dailyTarget}',
          ),
        ),
        const SizedBox(height: 22),
        Text('Продолжить путь', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 10),
        GrowlyCard(
          color: GrowlyColors.imaginationSoft,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    radius: 26,
                    backgroundColor: GrowlyColors.imagination,
                    child: Icon(Icons.calculate_rounded, color: Colors.white),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nextTask?.areaLabel ?? 'Маршрут завершён',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(
                          nextTask?.skillTitle ??
                              'Все доступные задания пройдены',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (nextTask != null) ...[
                const SizedBox(height: 18),
                GrowlyButton(
                  label: 'Продолжить занятие',
                  icon: Icons.play_arrow_rounded,
                  onPressed: onContinue,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        GrowlyCard(
          onTap: onOpenMap,
          child: Row(
            children: [
              const CircleAvatar(
                radius: 24,
                backgroundColor: GrowlyColors.rewardSoft,
                child: Icon(Icons.map_rounded, color: GrowlyColors.accent),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Карта приключения',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text('Посмотри пройденные и следующие вершины'),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_rounded),
            ],
          ),
        ),
        const SizedBox(height: 16),
        GrowlyCard(
          color: GrowlyColors.rewardSoft,
          child: Row(
            children: [
              const Icon(
                Icons.workspace_premium_rounded,
                color: GrowlyColors.accent,
                size: 42,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ближайшая награда',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    Text(
                      gamification.xp >= 30
                          ? 'Значок уже открыт!'
                          : 'Ещё ${30 - gamification.xp} XP до значка',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ChildHomeData {
  const _ChildHomeData({required this.demo, required this.session});
  final DemoBootstrap demo;
  final ChildSession session;
}
