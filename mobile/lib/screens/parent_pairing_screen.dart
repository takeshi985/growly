import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../api/growly_api_client.dart';
import '../models/pairing.dart';
import '../theme/growly_theme.dart';
import '../widgets/growly_card.dart';
import '../widgets/growly_mascot.dart';

class ParentPairingScreen extends StatefulWidget {
  const ParentPairingScreen({
    super.key,
    required this.apiClient,
    required this.onPaired,
    this.onChangeRole,
  });
  final GrowlyApiClient apiClient;
  final Future<void> Function(PairingClaim claim) onPaired;
  final Future<void> Function()? onChangeRole;
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
      await widget.onPaired(await widget.apiClient.claimPairingByCode(code));
    } catch (_) {
      if (mounted) {
        setState(
          () => _error =
              'Код не найден или истёк. Проверьте цифры и попробуйте снова.',
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Подключение к ребёнку')),
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 540),
            child: Padding(
              padding: const EdgeInsets.all(26),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const GrowlyMascot(size: 92, mood: GrowlyMood.ready),
                  const SizedBox(height: 12),
                  Text(
                    'Подключение к ребёнку',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Откройте Growly на устройстве ребёнка и покажите QR-код или 8-значный код.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 22),
                  GrowlyCard(
                    color: GrowlyTheme.softYellow,
                    child: TextField(
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
                        border: InputBorder.none,
                        hintText: '12345678',
                      ),
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
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: _sending ? null : _submit,
                    icon: const Icon(Icons.check_rounded),
                    label: Text(_sending ? 'Подключаем…' : 'Подключиться'),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Сканер QR будет добавлен позже. Сейчас можно ввести 8-значный код вручную.',
                    textAlign: TextAlign.center,
                  ),
                  if (widget.onChangeRole != null) ...[
                    const SizedBox(height: 12),
                    TextButton.icon(
                      onPressed: widget.onChangeRole,
                      icon: const Icon(Icons.swap_horiz_rounded),
                      label: const Text('Выбрать другую роль'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
