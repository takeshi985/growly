import 'package:flutter/material.dart';

import '../api/growly_api_client.dart';
import '../models/child_profile.dart';
import '../models/child_session.dart';
import '../models/task.dart';
import '../widgets/drag_count_task.dart';
import '../widgets/error_state.dart';
import '../widgets/feedback_card.dart';
import '../widgets/growly_button.dart';
import '../widgets/loading_state.dart';
import '../widgets/task_option_card.dart';
import '../widgets/growly_mascot.dart';
import '../widgets/growly_progress_bar.dart';
import '../theme/growly_tokens.dart';
import 'lesson_result_screen.dart';

class ChildTaskScreen extends StatefulWidget {
  const ChildTaskScreen({
    super.key,
    required this.apiClient,
    required this.child,
  });
  final GrowlyApiClient apiClient;
  final ChildProfile child;
  @override
  State<ChildTaskScreen> createState() => _ChildTaskScreenState();
}

class _ChildTaskScreenState extends State<ChildTaskScreen> {
  ChildSession? _session;
  GrowlyTask? _task;
  TaskAnswerResult? _answerResult;
  String? _selectedAnswer;
  Object? _error;
  bool _loading = true;
  bool _submitting = false;
  bool _hintWasShown = false;
  int _correctAnswers = 0;
  final DateTime _startedAt = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadSession();
  }

  Future<void> _loadSession() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final session = await widget.apiClient.childSession(widget.child.id);
      if (!mounted) return;
      setState(() {
        _session = session;
        _task = session.nextTask;
        _answerResult = null;
        _selectedAnswer = null;
        _hintWasShown = false;
        _loading = false;
      });
    } catch (error) {
      if (mounted) {
        setState(() {
          _error = error;
          _loading = false;
        });
      }
    }
  }

  Future<void> _submit() async {
    final task = _task;
    final selectedAnswer = _selectedAnswer;
    if (task == null || selectedAnswer == null || _submitting) return;
    setState(() => _submitting = true);
    try {
      final result = await widget.apiClient.submitAnswer(
        childId: widget.child.id,
        taskId: task.id,
        selectedAnswer: selectedAnswer,
        hintUsed: _hintWasShown,
      );
      if (!mounted) return;
      setState(() {
        _answerResult = result;
        if (result.attempt.isCorrect) {
          _correctAnswers++;
        }
        _hintWasShown = result.feedback.hint != null;
        _submitting = false;
      });
    } catch (error) {
      if (mounted) {
        setState(() {
          _error = error;
          _submitting = false;
        });
      }
    }
  }

  void _continue() {
    final next = _answerResult?.nextTask;
    final currentId = _task?.id;
    if (next == null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => LessonResultScreen(
            correctAnswers: _correctAnswers,
            elapsed: DateTime.now().difference(_startedAt),
            xp: _correctAnswers * 10,
          ),
        ),
      );
      return;
    }
    setState(() {
      _task = next;
      _selectedAnswer = null;
      _answerResult = null;
      if (next.id != currentId) _hintWasShown = false;
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      leading: IconButton(
        tooltip: 'Закрыть занятие',
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(Icons.close_rounded),
      ),
      title: const Text('Короткое занятие'),
    ),
    body: SafeArea(child: _body()),
  );
  Widget _body() {
    if (_loading) {
      return const LoadingState();
    }
    if (_error != null) {
      return ErrorState(message: _error.toString(), onRetry: _loadSession);
    }
    final task = _task;
    if (task == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.stars_rounded,
              size: 58,
              color: GrowlyColors.accent,
            ),
            const SizedBox(height: 14),
            Text(
              'На сегодня всё!',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Text(_session?.message ?? '', textAlign: TextAlign.center),
            const SizedBox(height: 18),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Вернуться'),
            ),
          ],
        ),
      );
    }
    final feedback = _answerResult?.feedback;
    final progress =
        _answerResult?.progressSummary ?? _session!.progressSummary;
    final progressValue = progress.totalTasks == 0
        ? 0.0
        : progress.completedTasks / progress.totalTasks;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 960),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          children: [
            Row(
              children: [
                Expanded(
                  child: GrowlyProgressBar(
                    value: progressValue,
                    label:
                        '${progress.completedTasks} из ${progress.totalTasks}',
                  ),
                ),
                const SizedBox(width: 14),
                Chip(label: Text(task.skillTitle)),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GrowlyMascot(
                  size: 72,
                  mood: feedback == null
                      ? GrowlyMood.thinking
                      : feedback.result == 'correct'
                      ? GrowlyMood.happy
                      : GrowlyMood.ready,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              task.question,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w900,
                height: 1.15,
              ),
            ),
            const SizedBox(height: 20),
            if (task.type == 'drag_count_to_baskets')
              DragCountTask(
                options: task.options,
                enabled: !_submitting && feedback == null,
                onChanged: (answer) => setState(() => _selectedAnswer = answer),
              )
            else
              for (final option in task.options.entries) ...[
                TaskOptionCard(
                  value: option.key,
                  label: option.value.toString(),
                  selected: _selectedAnswer == option.key,
                  enabled: !_submitting && feedback == null,
                  onTap: () => setState(() => _selectedAnswer = option.key),
                ),
                const SizedBox(height: 10),
              ],
            const SizedBox(height: 12),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              child: feedback == null
                  ? GrowlyButton(
                      key: const ValueKey('submit'),
                      label: _submitting ? 'Проверяем…' : 'Ответить',
                      icon: Icons.check_rounded,
                      onPressed: _selectedAnswer == null || _submitting
                          ? null
                          : _submit,
                    )
                  : Column(
                      key: const ValueKey('feedback'),
                      children: [
                        FeedbackCard(feedback: feedback),
                        if (feedback.explanation != null) ...[
                          const SizedBox(height: 8),
                          TextButton.icon(
                            onPressed: () => showDialog<void>(
                              context: context,
                              builder: (context) => AlertDialog(
                                icon: const Icon(
                                  Icons.lightbulb_rounded,
                                  color: GrowlyColors.help,
                                ),
                                title: const Text('Разберём вместе'),
                                content: Text(feedback.explanation!),
                                actions: [
                                  FilledButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Понятно'),
                                  ),
                                ],
                              ),
                            ),
                            icon: const Icon(Icons.help_outline_rounded),
                            label: const Text('Почему так?'),
                          ),
                        ],
                        const SizedBox(height: 16),
                        GrowlyButton(
                          label: _answerResult?.nextTask == null
                              ? 'Посмотреть результат'
                              : 'Продолжить',
                          icon: Icons.arrow_forward_rounded,
                          onPressed: _continue,
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
