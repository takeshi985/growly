import 'package:flutter/material.dart';

import '../api/growly_api_client.dart';
import '../storage/device_preferences.dart';
import '../theme/growly_theme.dart';
import '../widgets/growly_card.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    required this.apiClient,
    this.role,
    this.childId,
    this.pairedChildId,
    this.onResetRole,
    this.onOpenChildPairing,
    this.onOpenParentPairing,
  });
  final GrowlyApiClient apiClient;
  final DeviceRole? role;
  final int? childId;
  final int? pairedChildId;
  final Future<void> Function()? onResetRole;
  final VoidCallback? onOpenChildPairing;
  final VoidCallback? onOpenParentPairing;
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _checking = false;
  bool? _healthy;
  String? _message;
  Future<void> _check() async {
    setState(() {
      _checking = true;
      _message = null;
    });
    try {
      final healthy = await widget.apiClient.health();
      if (!mounted) return;
      setState(() {
        _healthy = healthy;
        _message = healthy
            ? 'Backend Growly отвечает.'
            : 'Backend вернул другой статус.';
        _checking = false;
      });
    } catch (error) {
      if (mounted)
        setState(() {
          _healthy = false;
          _message = error.toString();
          _checking = false;
        });
    }
  }

  Future<void> _changeRole() async {
    final approved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Сменить роль?'),
        content: const Text(
          'Данные на сервере не удалятся. Изменится только режим этого устройства.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Сменить'),
          ),
        ],
      ),
    );
    if (approved == true) {
      await widget.onResetRole?.call();
      if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isChild = widget.role == DeviceRole.child;
    final isParent = widget.role == DeviceRole.parent;
    final roleText = isChild
        ? 'ребёнок'
        : isParent
        ? 'родитель'
        : 'не выбран';
    return Scaffold(
      appBar: AppBar(title: const Text('Настройки')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            GrowlyCard(
              color: GrowlyTheme.softGreen,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Режим устройства: $roleText',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: widget.onResetRole == null ? null : _changeRole,
                    icon: const Icon(Icons.swap_horiz_rounded),
                    label: const Text('Сменить роль устройства'),
                  ),
                ],
              ),
            ),
            if (isChild) ...[
              const SizedBox(height: 12),
              GrowlyCard(
                color: GrowlyTheme.softYellow,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Родительский телефон',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Подключите его сейчас или создайте новый код позже.',
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: widget.onOpenChildPairing,
                      icon: const Icon(Icons.qr_code_rounded),
                      label: const Text('Подключить родителя'),
                    ),
                  ],
                ),
              ),
            ],
            if (isParent) ...[
              const SizedBox(height: 12),
              GrowlyCard(
                color: GrowlyTheme.softPurple,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.pairedChildId == null
                          ? 'Ребёнок ещё не подключён'
                          : 'Подключён профиль ребёнка №${widget.pairedChildId}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: widget.onOpenParentPairing,
                      icon: const Icon(Icons.link_rounded),
                      label: Text(
                        widget.pairedChildId == null
                            ? 'Ввести код ребёнка'
                            : 'Переподключиться к другому ребёнку',
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            GrowlyCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Подключение к backend',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SelectableText(
                    widget.apiClient.baseUrl,
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                  const SizedBox(height: 14),
                  FilledButton.icon(
                    onPressed: _checking ? null : _check,
                    icon: const Icon(Icons.health_and_safety_rounded),
                    label: Text(_checking ? 'Проверяем…' : 'Проверить backend'),
                  ),
                  if (_message != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Row(
                        children: [
                          Icon(
                            _healthy == true
                                ? Icons.check_circle
                                : Icons.info_rounded,
                          ),
                          const SizedBox(width: 8),
                          Expanded(child: Text(_message!)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
