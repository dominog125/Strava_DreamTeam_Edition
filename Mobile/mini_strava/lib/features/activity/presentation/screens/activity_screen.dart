import 'package:flutter/material.dart';
import '../controller/activity_controller.dart';
import '../../domain/entities/activity.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  late final ActivityController c;

  @override
  void initState() {
    super.initState();
    c = ActivityController()..addListener(_onChanged);
  }

  void _onChanged() => setState(() {});

  @override
  void dispose() {
    c.removeListener(_onChanged);
    c.dispose();
    super.dispose();
  }

  String _format(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    return '${two(h)}:${two(m)}:${two(s)}';
  }

  @override
  Widget build(BuildContext context) {
    final isIdle = c.state == ActivityState.idle;
    final isRunning = c.state == ActivityState.running;
    final isPaused = c.state == ActivityState.paused;

    return Scaffold(
      appBar: AppBar(title: const Text('Nowa aktywność')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<ActivityType>(
              initialValue: c.type,
              decoration: const InputDecoration(labelText: 'Typ aktywności'),
              items: const [
                DropdownMenuItem(value: ActivityType.run, child: Text('Bieg')),
                DropdownMenuItem(value: ActivityType.bike, child: Text('Rower')),
                DropdownMenuItem(value: ActivityType.walk, child: Text('Spacer')),
              ],
              onChanged: isIdle ? (v) => c.setType(v ?? ActivityType.run) : null,
            ),
            const SizedBox(height: 24),
            Text(
              _format(c.elapsed),
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: isIdle ? c.start : null,
                    child: const Text('Start'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: isRunning ? c.pause : (isPaused ? c.resume : null),
                    child: Text(isPaused ? 'Wznów' : 'Pauza'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: (isRunning || isPaused) ? () => c.finish(context) : null,
                child: const Text('Zakończ i zapisz'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
