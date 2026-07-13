import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _loadSession();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
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
      if (mounted)
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
      if (mounted)
        setState(() {
          _error = error;
          _submitting = false;
        });
    }
  }

  void _continue() {
    final next = _answerResult?.nextTask;
    final currentId = _task?.id;
    setState(() {
      _task = next;
      _selectedAnswer = null;
      _answerResult = null;
      if (next?.id != currentId) _hintWasShown = false;
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Задание Growly')),
    body: SafeArea(child: _body()),
  );
  Widget _body() {
    if (_loading) return const LoadingState();
    if (_error != null)
      return ErrorState(message: _error.toString(), onRetry: _loadSession);
    final task = _task;
    if (task == null)
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🌟', style: TextStyle(fontSize: 58)),
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
    final feedback = _answerResult?.feedback;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 960),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(28, 14, 28, 24),
          children: [
            Row(
              children: [
                Text(
                  '${widget.child.name} · ${task.areaLabel}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                Chip(label: Text(task.skillTitle)),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              task.question,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w900,
                height: 1.15,
              ),
            ),
            const SizedBox(height: 24),
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
                        const SizedBox(height: 16),
                        AnimatedScale(
                          duration: const Duration(milliseconds: 180),
                          scale: 1,
                          child: GrowlyButton(
                            label: _answerResult?.nextTask == null
                                ? 'Завершить занятие'
                                : 'Продолжить',
                            icon: Icons.arrow_forward_rounded,
                            onPressed: _continue,
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
