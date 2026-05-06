import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../models/run.dart';
import '../../providers/runs_provider.dart';

class LogRunScreen extends ConsumerStatefulWidget {
  const LogRunScreen({super.key});

  @override
  ConsumerState<LogRunScreen> createState() => _LogRunScreenState();
}

class _LogRunScreenState extends ConsumerState<LogRunScreen> {
  final _formKey = GlobalKey<FormState>();
  final _distanceCtrl = TextEditingController();
  final _hoursCtrl = TextEditingController(text: '0');
  final _minutesCtrl = TextEditingController();
  final _secondsCtrl = TextEditingController(text: '0');
  final _notesCtrl = TextEditingController();
  DateTime _date = DateTime.now();
  bool _saving = false;

  @override
  void dispose() {
    _distanceCtrl.dispose();
    _hoursCtrl.dispose();
    _minutesCtrl.dispose();
    _secondsCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final hours = int.tryParse(_hoursCtrl.text) ?? 0;
    final minutes = int.tryParse(_minutesCtrl.text) ?? 0;
    final seconds = int.tryParse(_secondsCtrl.text) ?? 0;
    final totalSeconds = hours * 3600 + minutes * 60 + seconds;

    final run = Run(
      id: const Uuid().v4(),
      date: _date,
      distanceKm: double.parse(_distanceCtrl.text),
      durationSeconds: totalSeconds,
      notes: _notesCtrl.text.isEmpty ? null : _notesCtrl.text,
    );

    await ref.read(runsProvider.notifier).addRun(run);
    if (mounted) context.pop();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _date = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Log Run')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Date'),
              subtitle: Text('${_date.year}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}'),
              trailing: const Icon(Icons.calendar_today),
              onTap: _pickDate,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _distanceCtrl,
              decoration: const InputDecoration(
                labelText: 'Distance (km)',
                suffixText: 'km',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Required';
                if (double.tryParse(v) == null) return 'Invalid number';
                return null;
              },
            ),
            const SizedBox(height: 16),
            const Text('Duration'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _hoursCtrl,
                    decoration: const InputDecoration(labelText: 'Hours'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _minutesCtrl,
                    decoration: const InputDecoration(labelText: 'Minutes'),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Required';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _secondsCtrl,
                    decoration: const InputDecoration(labelText: 'Seconds'),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesCtrl,
              decoration: const InputDecoration(labelText: 'Notes (optional)'),
              maxLines: 2,
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const CircularProgressIndicator()
                  : const Text('Save Run'),
            ),
          ],
        ),
      ),
    );
  }
}
