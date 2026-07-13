import 'package:flutter/material.dart';

import '../api/growly_api_client.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, required this.apiClient, this.onResetRole});

  final GrowlyApiClient apiClient;
  final Future<void> Function()? onResetRole;

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
      if (!mounted) return;
      setState(() {
        _healthy = false;
        _message = error.toString();
        _checking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Подключение')),
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Текущий API',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 10),
                  SelectableText(
                    widget.apiClient.baseUrl,
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: _checking ? null : _check,
                    icon: const Icon(Icons.health_and_safety_rounded),
                    label: Text(_checking ? 'Проверяем…' : 'Проверить backend'),
                  ),
                  if (_message != null) ...[
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                  ],
                ],
              ),
            ),
          ),
          if (widget.onResetRole != null) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () async {
                await widget.onResetRole!();
                if (context.mounted)
                  Navigator.of(context).popUntil((route) => route.isFirst);
              },
              icon: const Icon(Icons.restart_alt_rounded),
              label: const Text('Сбросить роль устройства'),
            ),
          ],
          const SizedBox(height: 18),
          const _HelpCard(
            title: 'Android Emulator',
            address: 'http://10.0.2.2:4000',
            note: '10.0.2.2 ведёт с эмулятора на компьютер разработчика.',
          ),
          const SizedBox(height: 12),
          const _HelpCard(
            title: 'Windows desktop',
            address: 'http://localhost:4000',
            note: 'Требуется Visual Studio с Desktop development with C++.',
          ),
          const SizedBox(height: 12),
          const _HelpCard(
            title: 'Настоящий Android-телефон',
            address: 'http://YOUR_PC_LAN_IP:4000',
            note:
                'Телефон и компьютер должны находиться в одной локальной сети.',
          ),
          const SizedBox(height: 16),
          const Text(
            'HTTP разрешён только в debug-сборке. Производственная версия должна использовать HTTPS.',
          ),
        ],
      ),
    ),
  );
}

class _HelpCard extends StatelessWidget {
  const _HelpCard({
    required this.title,
    required this.address,
    required this.note,
  });

  final String title;
  final String address;
  final String note;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          SelectableText(address),
          const SizedBox(height: 6),
          Text(note),
        ],
      ),
    ),
  );
}
