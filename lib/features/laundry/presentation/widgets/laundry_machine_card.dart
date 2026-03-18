
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myapp/features/laundry/domain/entities/laundry_machine.dart';
import 'package:myapp/features/laundry/domain/entities/laundry_machine_status.dart';
import 'package:myapp/features/laundry/presentation/providers/laundry_providers.dart';

class LaundryMachineCard extends ConsumerStatefulWidget {
  final LaundryMachine machine;

  const LaundryMachineCard({super.key, required this.machine});

  @override
  ConsumerState<LaundryMachineCard> createState() => _LaundryMachineCardState();
}

class _LaundryMachineCardState extends ConsumerState<LaundryMachineCard> {
  Timer? _timer;
  Duration? _remainingTime;

  @override
  void initState() {
    super.initState();
    _updateRemainingTime();
    _startTimer();
  }

  @override
  void didUpdateWidget(covariant LaundryMachineCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.machine.estimatedCompletionTime !=
        oldWidget.machine.estimatedCompletionTime) {
      _updateRemainingTime();
      _startTimer();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    if (widget.machine.status == LaundryMachineStatus.inUse &&
        widget.machine.estimatedCompletionTime != null) {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        _updateRemainingTime();
      });
    }
  }

  void _updateRemainingTime() {
    if (widget.machine.estimatedCompletionTime != null) {
      final now = DateTime.now();
      final difference = widget.machine.estimatedCompletionTime!.difference(now);
      if (difference.isNegative) {
        if (mounted) {
          setState(() {
            _remainingTime = Duration.zero;
          });
        }
        _timer?.cancel();
      } else {
        if (mounted) {
          setState(() {
            _remainingTime = difference;
          });
        }
      }
    } else {
      if (mounted) {
        setState(() {
          _remainingTime = null;
        });
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final laundryRepository = ref.watch(laundryRepositoryProvider);
    final isAvailable = widget.machine.status == LaundryMachineStatus.available;
    final isInUse = widget.machine.status == LaundryMachineStatus.inUse;
    final isFinished = widget.machine.status == LaundryMachineStatus.finished ||
        (isInUse && _remainingTime == Duration.zero);

    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.machine.name,
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8.0),
            Text('Type: ${widget.machine.type.toString().split('.').last}'),
            const SizedBox(height: 8.0),
            Text('Status: ${widget.machine.status.toString().split('.').last}'),
            if (isInUse && _remainingTime != null && _remainingTime! > Duration.zero)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Time remaining: ${_formatDuration(_remainingTime!)}',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.secondary),
                ),
              ),
            if (isFinished)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Cycle finished! Please collect your laundry.',
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(color: Colors.green),
                ),
              ),
            const SizedBox(height: 16.0),
            if (isAvailable)
              ElevatedButton(
                onPressed: () {
                  laundryRepository.startMachine(
                      widget.machine.id, const Duration(minutes: 45));
                },
                child: const Text('Start Wash (45 min)'),
              ),
            if (isInUse || isFinished)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary),
                onPressed: () {
                  laundryRepository.markAsCollected(widget.machine.id);
                },
                child: const Text('Mark as Collected'),
              ),
          ],
        ),
      ),
    );
  }
}
