import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/models/gamification.dart';
import 'package:mobile/screens/daily_goals_screen.dart';
import 'package:mobile/screens/lesson_result_screen.dart';
import 'package:mobile/screens/rewards_screen.dart';
import 'package:mobile/theme/growly_theme.dart';
import 'package:mobile/widgets/growly_button.dart';

void main() {
  const game = GamificationSnapshot(
    xp: 20,
    level: 1,
    levelProgress: .2,
    streakDays: 1,
    dailyCompleted: 2,
  );

  testWidgets('primary Growly button has a semantic action', (tester) async {
    var pressed = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: GrowlyTheme.build(),
        home: Scaffold(
          body: GrowlyButton(
            label: 'Продолжить',
            icon: Icons.arrow_forward_rounded,
            onPressed: () => pressed = true,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Продолжить'));
    expect(pressed, isTrue);
  });

  testWidgets('goals and rewards remain usable on a small phone', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        theme: GrowlyTheme.build(),
        home: const Scaffold(body: DailyGoalsScreen(gamification: game)),
      ),
    );
    expect(find.text('Цели на сегодня'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(
      MaterialApp(
        theme: GrowlyTheme.build(),
        home: const Scaffold(body: RewardsScreen(gamification: game)),
      ),
    );
    expect(find.text('Мои награды'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('lesson result exposes learning metrics', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: GrowlyTheme.build(),
        home: const LessonResultScreen(
          correctAnswers: 3,
          elapsed: Duration(seconds: 42),
          xp: 30,
        ),
      ),
    );

    expect(find.text('Маршрут пройден!'), findsOneWidget);
    expect(find.text('+30'), findsOneWidget);
    expect(find.text('Вернуться к маршруту'), findsOneWidget);
  });
}
