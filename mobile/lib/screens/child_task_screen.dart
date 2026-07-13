import 'package:flutter/material.dart';

import '../api/growly_api_client.dart';
import '../models/child_profile.dart';
import '../models/child_session.dart';
import '../models/task.dart';
import '../widgets/error_state.dart';
import '../widgets/feedback_card.dart';
import '../widgets/growly_button.dart';
import '../widgets/loading_state.dart';
import '../widgets/task_option_card.dart';
import 'parent_progress_screen.dart';

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
      if (!mounted) return;
      setState(() {
        _error = error;
        _loading = false;
      });
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
        _hintWasShown = result.feedback.hint != null;
        _submitting = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error;
        _submitting = false;
      });
    }
  }

  void _continue() {
    final next = _answerResult?.nextTask;
    final currentTaskId = _task?.id;
    setState(() {
      _task = next;
      _selectedAnswer = null;
      _answerResult = null;
      if (next?.id != currentTaskId) _hintWasShown = false;
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Задание Growly')),
    body: SafeArea(child: _body()),
  );

  Widget _body() {
    if (_loading) return const LoadingState();
    if (_error != null) {
      return ErrorState(message: _error.toString(), onRetry: _loadSession);
    }
    final task = _task;
    if (task == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🌟', style: TextStyle(fontSize: 58)),
              const SizedBox(height: 14),
              Text(
                'На сегодня всё! Можно отдохнуть.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              if (_session?.message.isNotEmpty ?? false) ...[
                const SizedBox(height: 10),
                Text(_session!.message, textAlign: TextAlign.center),
              ],
              const SizedBox(height: 22),
              FilledButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => ParentProgressScreen(
                      apiClient: widget.apiClient,
                      childId: widget.child.id,
                    ),
                  ),
                ),
                icon: const Icon(Icons.insights_rounded),
                label: const Text('Посмотреть прогресс'),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Вернуться на главную'),
              ),
            ],
          ),
        ),
      );
    }

    final feedback = _answerResult?.feedback;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      children: [
        Text(
          '${widget.child.name}, ${widget.child.age} лет',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          children: [
            Chip(label: Text(task.areaLabel)),
            Chip(label: Text('Сложность ${task.difficulty}')),
          ],
        ),
        const SizedBox(height: 12),
        Text(task.skillTitle, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Text(
          task.question,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 18),
        for (final option in task.options.entries) ...[
          TaskOptionCard(
            value: option.key,
            label: option.value,
            selected: _selectedAnswer == option.key,
            enabled: !_submitting && feedback == null,
            onTap: () => setState(() => _selectedAnswer = option.key),
          ),
          const SizedBox(height: 10),
        ],
        if (feedback != null) ...[
          const SizedBox(height: 6),
          FeedbackCard(feedback: feedback),
          const SizedBox(height: 16),
          GrowlyButton(
            label: _answerResult?.nextTask == null
                ? 'Завершить занятие'
                : 'Продолжить',
            icon: Icons.arrow_forward_rounded,
            onPressed: _continue,
          ),
        ] else ...[
          const SizedBox(height: 8),
          GrowlyButton(
            label: _submitting ? 'Проверяем…' : 'Ответить',
            icon: Icons.check_rounded,
            onPressed: _selectedAnswer == null || _submitting ? null : _submit,
          ),
        ],
      ],
    );
  }
}
