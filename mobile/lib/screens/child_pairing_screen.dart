import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../api/growly_api_client.dart';
import '../models/pairing.dart';
import '../widgets/error_state.dart';
import '../widgets/loading_state.dart';

class ChildPairingScreen extends StatefulWidget {
  const ChildPairingScreen({
    super.key,
    required this.apiClient,
    required this.childId,
  });
  final GrowlyApiClient apiClient;
  final int childId;
  @override
  State<ChildPairingScreen> createState() => _ChildPairingScreenState();
}

class _ChildPairingScreenState extends State<ChildPairingScreen> {
  late Future<PairingOffer> _offer;
  @override
  void initState() {
    super.initState();
    _offer = widget.apiClient.createPairingSession(widget.childId);
  }

  void _refresh() => setState(
    () => _offer = widget.apiClient.createPairingSession(widget.childId),
  );
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Код для родителя')),
    body: SafeArea(
      child: FutureBuilder<PairingOffer>(
        future: _offer,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done)
            return const LoadingState(message: 'Готовим код…');
          if (snapshot.hasError || !snapshot.hasData)
            return ErrorState(message: '${snapshot.error}', onRetry: _refresh);
          final pairing = snapshot.data!.pairing;
          return Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Покажи этот код родителю',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Родитель сможет видеть только твой прогресс.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Card(
                      color: const Color(0xFFFFFFFF),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: QrImageView(
                          data: pairing.qrPayload,
                          size: 190,
                          eyeStyle: const QrEyeStyle(
                            eyeShape: QrEyeShape.square,
                            color: Color(0xFF31583A),
                          ),
                          dataModuleStyle: const QrDataModuleStyle(
                            dataModuleShape: QrDataModuleShape.square,
                            color: Color(0xFF31583A),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Semantics(
                      label: '8-значный код ${pairing.code}',
                      child: Text(
                        pairing.code,
                        style: const TextStyle(
                          fontSize: 42,
                          letterSpacing: 7,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('Код действует 10 минут'),
                    const SizedBox(height: 20),
                    OutlinedButton.icon(
                      onPressed: _refresh,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Обновить код'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    ),
  );
}
