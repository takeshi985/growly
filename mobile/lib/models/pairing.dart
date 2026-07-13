import 'child_profile.dart';

class PairingSession {
  const PairingSession({
    required this.code,
    required this.token,
    required this.expiresAt,
    required this.qrPayload,
  });

  final String code;
  final String token;
  final DateTime? expiresAt;
  final String qrPayload;

  factory PairingSession.fromJson(Map<String, dynamic> json) => PairingSession(
    code: json['code'] as String? ?? '',
    token: json['token'] as String? ?? '',
    expiresAt: DateTime.tryParse(json['expires_at'] as String? ?? ''),
    qrPayload: json['qr_payload'] as String? ?? '',
  );
}

class PairingOffer {
  const PairingOffer({required this.child, required this.pairing});

  final ChildProfile child;
  final PairingSession pairing;

  factory PairingOffer.fromJson(Map<String, dynamic> json) => PairingOffer(
    child: ChildProfile.fromJson(_map(json['child'])),
    pairing: PairingSession.fromJson(_map(json['pairing'])),
  );
}

class PairingClaim {
  const PairingClaim({
    required this.child,
    required this.progressLink,
    required this.lessonMapLink,
  });

  final ChildProfile child;
  final String progressLink;
  final String lessonMapLink;

  factory PairingClaim.fromJson(Map<String, dynamic> json) {
    final links = _map(json['links']);
    return PairingClaim(
      child: ChildProfile.fromJson(_map(json['child'])),
      progressLink: links['progress'] as String? ?? '',
      lessonMapLink: links['lesson_map'] as String? ?? '',
    );
  }
}

Map<String, dynamic> _map(Object? value) =>
    value is Map<String, dynamic> ? value : <String, dynamic>{};
