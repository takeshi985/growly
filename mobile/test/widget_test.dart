import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/screens/role_selection_screen.dart';
import 'package:mobile/storage/device_preferences.dart';

void main() {
  testWidgets('role selection renders child and parent choices', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: RoleSelectionScreen(onSelected: (_) async {})),
    );
    expect(find.text('Growly'), findsOneWidget);
    expect(find.text('Я ребёнок'), findsOneWidget);
    expect(find.text('Я родитель'), findsOneWidget);
  });

  testWidgets('child role action is available', (tester) async {
    DeviceRole? selected;
    await tester.pumpWidget(
      MaterialApp(
        home: RoleSelectionScreen(onSelected: (role) async => selected = role),
      ),
    );
    await tester.tap(find.text('Я ребёнок'));
    await tester.pump();
    expect(selected, DeviceRole.child);
  });
}
