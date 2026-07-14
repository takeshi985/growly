import 'package:flutter/material.dart';

import '../api/growly_api_client.dart';
import '../models/pairing.dart';
import '../storage/device_preferences.dart';
import '../widgets/growly_button.dart';
import '../widgets/growly_card.dart';
import '../widgets/growly_mascot.dart';
import '../theme/growly_tokens.dart';
import 'curriculum_screen.dart';
import 'parent_pairing_screen.dart';
import 'parent_progress_screen.dart';
import 'settings_screen.dart';

class ParentHomeScreen extends StatefulWidget {
  const ParentHomeScreen({
    super.key,
    required this.apiClient,
    required this.preferences,
    required this.setup,
    required this.onSetupChanged,
    required this.onResetRole,
  });
  final GrowlyApiClient apiClient;
  final DevicePreferences preferences;
  final DeviceSetup setup;
  final VoidCallback onSetupChanged;
  final Future<void> Function() onResetRole;
  @override
  State<ParentHomeScreen> createState() => _ParentHomeScreenState();
}

class _ParentHomeScreenState extends State<ParentHomeScreen> {
  Future<void> _paired(PairingClaim claim) async {
    await widget.preferences.savePairedChildId(claim.child.id);
    widget.onSetupChanged();
  }

  Widget _pairing() => ParentPairingScreen(
    apiClient: widget.apiClient,
    onPaired: _paired,
    onChangeRole: widget.onResetRole,
  );
  @override
  Widget build(BuildContext context) {
    final childId = widget.setup.pairedChildId;
    if (childId == null) return _pairing();
    return Scaffold(
      appBar: AppBar(title: const Text('Growly для родителя')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: ListView(
              padding: const EdgeInsets.all(26),
              children: [
                const Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Родительский режим',
                            style: TextStyle(
                              fontSize: 27,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text('Спокойный обзор обучения ребёнка.'),
                        ],
                      ),
                    ),
                    GrowlyMascot(size: 78, mood: GrowlyMood.ready),
                  ],
                ),
                const SizedBox(height: 22),
                const GrowlyCard(
                  color: GrowlyColors.brandSoft,
                  child: Row(
                    children: [
                      Icon(
                        Icons.shield_rounded,
                        color: GrowlyColors.brand,
                        size: 34,
                      ),
                      SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          'Задания, покупки и внешние действия недоступны в детском режиме.',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                GrowlyButton(
                  label: 'Прогресс ребёнка',
                  icon: Icons.insights_rounded,
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => ParentProgressScreen(
                        apiClient: widget.apiClient,
                        childId: childId,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                GrowlyButton(
                  label: 'Карта обучения',
                  icon: Icons.map_rounded,
                  secondary: true,
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => CurriculumScreen(
                        apiClient: widget.apiClient,
                        childId: childId,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                GrowlyButton(
                  label: 'Настройки',
                  icon: Icons.settings_rounded,
                  secondary: true,
                  onPressed: () => _openSettings(childId),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openSettings(int childId) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SettingsScreen(
          apiClient: widget.apiClient,
          role: DeviceRole.parent,
          pairedChildId: childId,
          onResetRole: widget.onResetRole,
          onOpenParentPairing: () => Navigator.of(
            context,
          ).push(MaterialPageRoute<void>(builder: (_) => _pairing())),
        ),
      ),
    );
  }
}
