import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../api/growly_api_client.dart';
import '../models/pairing.dart';

class ParentPairingScreen extends StatefulWidget {
  const ParentPairingScreen({
    super.key,
    required this.apiClient,
    required this.onPaired,
  });
  final GrowlyApiClient apiClient;
  final Future<void> Function(PairingClaim claim) onPaired;
  @override
  State<ParentPairingScreen> createState() => _ParentPairingScreenState();
}

class _ParentPairingScreenState extends State<ParentPairingScreen> {
  final _controller = TextEditingController();
  String? _error;
  bool _sending = false;
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final code = _controller.text.replaceAll(RegExp(r'\D'), '');
    if (code.length != 8) {
      setState(() => _error = 'Введите все 8 цифр кода.');
      return;
    }
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      final claim = await widget.apiClient.claimPairingByCode(code);
      await widget.onPaired(claim);
    } catch (_) {
      if (mounted)
        setState(
          () => _error =
              'Код не найден или уже истёк. Проверьте цифры и попробуйте ещё раз.',
        );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Подключение к ребёнку')),
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.all(26),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.link_rounded,
                  size: 56,
                  color: Color(0xFF31583A),
                ),
                const SizedBox(height: 16),
                Text(
                  'Введите код',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Откройте Growly на устройстве ребёнка и покажите QR-код или 8-значный код.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _controller,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(8),
                  ],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 30,
                    letterSpacing: 8,
                    fontWeight: FontWeight.w800,
                  ),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: '12345678',
                  ),
                ),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: _sending ? null : _submit,
                  icon: const Icon(Icons.check_rounded),
                  label: Text(_sending ? 'Подключаем…' : 'Подключиться'),
                ),
                const SizedBox(height: 22),
                const Divider(),
                const SizedBox(height: 12),
                const Text(
                  'Сканер QR будет добавлен позже. Сейчас можно ввести 8-значный код вручную.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
