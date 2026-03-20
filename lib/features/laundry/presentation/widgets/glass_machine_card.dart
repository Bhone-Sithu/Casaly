import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../dorm/presentation/providers/dorm_providers.dart';
import '../../../dorm/domain/entities/dorm_member.dart';
import '../providers/laundry_providers.dart';
import '../widgets/start_timer_dialog.dart';
import '../widgets/edit_machine_dialog.dart';
import '../../domain/entities/laundry_machine.dart';

class GlassMachineCard extends ConsumerStatefulWidget {
  final LaundryMachine machine;
  final String dormId;
  final VoidCallback onMachineUpdated;

  const GlassMachineCard({
    super.key,
    required this.machine,
    required this.dormId,
    required this.onMachineUpdated,
  });

  @override
  ConsumerState<GlassMachineCard> createState() => _GlassMachineCardState();
}

class _GlassMachineCardState extends ConsumerState<GlassMachineCard>
    with TickerProviderStateMixin {
  Timer? _timer;
  int? _remainingMinutes;
  bool _isExpired = false;
  late AnimationController _rotationController;
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _rotationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _waveController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _checkAndUpdateMachine();
    _updateAnimations();
  }

  @override
  void didUpdateWidget(GlassMachineCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.machine.id != widget.machine.id ||
        oldWidget.machine.status != widget.machine.status ||
        oldWidget.machine.estimatedEndAt != widget.machine.estimatedEndAt) {
      _checkAndUpdateMachine();
      _updateAnimations();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _rotationController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  void _checkAndUpdateMachine() {
    _timer?.cancel();

    // Check if machine should have finished by now
    if (widget.machine.isInUse && widget.machine.estimatedEndAt != null) {
      final now = DateTime.now();
      final endTime = widget.machine.estimatedEndAt!;

      if (now.isAfter(endTime) && !_isExpired) {
        // Machine time has expired, but don't auto-finish - wait for user collection
        _isExpired = true;
        setState(() {
          _remainingMinutes = 0;
        });
        return;
      }

      _remainingMinutes = widget.machine.remainingMinutes;
      _isExpired = false;

      // Only start timer if we have positive remaining minutes
      if (_remainingMinutes != null && _remainingMinutes! > 0) {
        _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
          if (mounted) {
            final now = DateTime.now();
            final endTime = widget.machine.estimatedEndAt!;

            if (now.isAfter(endTime)) {
              // Time expired, but don't auto-finish - wait for user collection
              setState(() {
                _isExpired = true;
                _remainingMinutes = 0;
              });
              timer.cancel();
            } else {
              final newRemaining = widget.machine.remainingMinutes;
              if (_remainingMinutes != newRemaining) {
                setState(() {
                  _remainingMinutes = newRemaining;
                });
              }
            }
          } else {
            timer.cancel();
          }
        });
      }
    } else {
      _remainingMinutes = null;
      _isExpired = false;
    }
  }

  void _updateAnimations() {
    if (widget.machine.isInUse && !_isExpired) {
      // Start animations when machine is in use
      if (widget.machine.type == MachineType.washer) {
        _rotationController.repeat();
        _waveController.stop();
        _waveController.reset();
      } else {
        _waveController.repeat();
        _rotationController.stop();
        _rotationController.reset();
      }
    } else {
      // Stop animations when machine is not in use
      _rotationController.stop();
      _rotationController.reset();
      _waveController.stop();
      _waveController.reset();
    }
  }

  Widget _buildBackgroundIconAndAnimation() {
    return Positioned.fill(
      child: Center(
        child: widget.machine.type == MachineType.washer
            ? _buildWasherBackground()
            : _buildDryerBackground(),
      ),
    );
  }

  Widget _buildWasherBackground() {
    return Stack(
      children: [
        // Large background washer icon
        Positioned.fill(
          child: Transform.scale(
            scale: 2.0,
            child: Center(
              child: Icon(
                Icons.local_laundry_service,
                size: 100,
                color: AppColors.orange400.withOpacity(0.2),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDryerBackground() {
    return Stack(
      children: [
        // Large background dryer icon
        Positioned.fill(
          child: Transform.scale(
            scale: 2.0,
            child: Center(
              child: Icon(
                Icons.dry_cleaning,
                size: 100,
                color: AppColors.orange400.withOpacity(0.2),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateChangesProvider);
    final currentUser = authState.value;
    final isCurrentUserUsing = widget.machine.currentUserId == currentUser?.uid;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.orange400.withOpacity(0.15),
            AppColors.orange400.withOpacity(0.05),
            Colors.white.withOpacity(0.1),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
        border: Border.all(
          color: AppColors.orange400.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.orange400.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
                colors: [AppColors.orange100, Colors.white.withOpacity(0.05)],
              ),
            ),
            child: Stack(
              children: [
                // Background icon and animations
                _buildBackgroundIconAndAnimation(),

                // Main content
                InkWell(
                  onTap: () => _showMachineOptions(context, isCurrentUserUsing),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Machine name
                        Text(
                          widget.machine.name,
                          style: AppTypography.labelLg.copyWith(
                            color: AppColors.cream800,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: AppSpacing.xs),

                        // Status section
                        _buildStatusSection(isCurrentUserUsing),

                        // Center action icon
                        Expanded(
                          child: Center(
                            child: _buildCenterActionIcon(isCurrentUserUsing),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor() {
    if (_isExpired) return AppColors.berry400;

    switch (widget.machine.status) {
      case MachineStatus.available:
        return AppColors.green400;
      case MachineStatus.inUse:
        return AppColors.orange400;
      case MachineStatus.maintenance:
        return AppColors.cream600;
    }
  }

  Widget _buildStatusSection(bool isCurrentUserUsing) {
    if (widget.machine.isAvailable) {
      return Text(
        'Available',
        style: AppTypography.labelSm.copyWith(
          color: AppColors.green600,
          fontWeight: FontWeight.w500,
        ),
      );
    } else if (widget.machine.isInUse) {
      final displayMinutes =
          _remainingMinutes ?? widget.machine.remainingMinutes ?? 0;
      final isFinished = _isExpired || displayMinutes <= 0;

      if (isFinished) {
        return Text(
          'Finished - Click to collect',
          style: AppTypography.labelSm.copyWith(
            color: AppColors.berry600,
            fontWeight: FontWeight.w500,
          ),
        );
      } else {
        if (isCurrentUserUsing) {
          return Text(
            'You are using - ${_formatTime(displayMinutes)} left',
            style: AppTypography.labelSm.copyWith(
              color: AppColors.orange600,
              fontWeight: FontWeight.w500,
            ),
          );
        } else {
          // Show the actual user's name who is using the machine
          return _buildUserNameStatus(displayMinutes);
        }
      }
    } else {
      return Text(
        'Under maintenance',
        style: AppTypography.labelSm.copyWith(
          color: AppColors.cream600,
          fontWeight: FontWeight.w500,
        ),
      );
    }
  }

  Widget _buildUserNameStatus(int displayMinutes) {
    final membersAsync = ref.watch(dormMembersProvider(widget.dormId));
    
    return membersAsync.when(
      data: (members) {
        final user = members.firstWhere(
          (member) => member.userId == widget.machine.currentUserId,
          orElse: () => DormMember(
            id: '',
            userId: widget.machine.currentUserId ?? '',
            displayName: 'Unknown User',
            email: '',
            role: MemberRole.member,
            joinedAt: DateTime.now(),
          ),
        );
        
        return Text(
          '${user.displayName} is using - ${_formatTime(displayMinutes)} left',
          style: AppTypography.labelSm.copyWith(
            color: AppColors.orange600,
            fontWeight: FontWeight.w500,
          ),
        );
      },
      loading: () => Text(
        'In use - ${_formatTime(displayMinutes)} left',
        style: AppTypography.labelSm.copyWith(
          color: AppColors.orange600,
          fontWeight: FontWeight.w500,
        ),
      ),
      error: (_, __) => Text(
        'In use - ${_formatTime(displayMinutes)} left',
        style: AppTypography.labelSm.copyWith(
          color: AppColors.orange600,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildCenterActionIcon(bool isCurrentUserUsing) {
    if (widget.machine.isAvailable) {
      // Play/Start icon
      return IconButton(
        onPressed: () => _showStartDialog(),
        icon: Icon(Icons.play_arrow, size: 32, color: AppColors.green400),
        style: IconButton.styleFrom(
          backgroundColor: AppColors.green400.withOpacity(0.1),
          shape: const CircleBorder(),
          padding: const EdgeInsets.all(16),
        ),
      );
    } else if (widget.machine.isInUse) {
      final isFinished =
          _isExpired || (_remainingMinutes != null && _remainingMinutes! <= 0);

      if (isFinished) {
        // Basket/collect icon for finished machines
        return IconButton(
          onPressed: (isCurrentUserUsing || isFinished)
              ? _collectMachine
              : null,
          icon: AnimatedBuilder(
            animation: _rotationController,
            builder: (context, child) {
              return Transform.rotate(
                angle: _rotationController.value * 0.1, // Subtle bounce
                child: Icon(
                  Icons.shopping_basket,
                  size: 32,
                  color: AppColors.berry400,
                ),
              );
            },
          ),
          style: IconButton.styleFrom(
            backgroundColor: AppColors.berry400.withOpacity(0.1),
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(16),
          ),
        );
      } else {
        // Different animations for washers vs dryers
        if (widget.machine.type == MachineType.washer) {
          // Animated water drop for washers
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cyan400.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: AnimatedBuilder(
              animation: _rotationController,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _rotationController.value * 2 * 3.14159,
                  child: Icon(
                    Icons.water_drop_rounded,
                    size: 32,
                    color: AppColors.cyan400,
                  ),
                );
              },
            ),
          );
        } else {
          // Animated wind stripes for dryers
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: AnimatedBuilder(
              animation: _waveController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(
                    ((_waveController.value * 2 - 1) * 10), // Smaller movement
                    0,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 20,
                        height: 2,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 16,
                        height: 2,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 24,
                        height: 2,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        }
      }
    } else {
      // Maintenance icon
      return Icon(Icons.build, size: 32, color: AppColors.cream400);
    }
  }

  void _showStartDialog() {
    showDialog(
      context: context,
      builder: (context) => StartTimerDialog(
        machine: widget.machine,
        dormId: widget.dormId,
        onMachineUpdated: widget.onMachineUpdated,
      ),
    );
  }

  void _showMachineOptions(BuildContext context, bool isCurrentUserUsing) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white.withOpacity(0.9),
              Colors.white.withOpacity(0.95),
            ],
          ),
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppRadius.sheet),
          ),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.machine.name,
                  style: AppTypography.h3.copyWith(color: AppColors.cream800),
                ),
                const SizedBox(height: AppSpacing.md),

                ListTile(
                  leading: Icon(Icons.edit, color: AppColors.orange400),
                  title: const Text('Edit Machine'),
                  onTap: () {
                    Navigator.pop(context);
                    _showEditDialog();
                  },
                ),

                if (widget.machine.isInUse &&
                    (isCurrentUserUsing || _isExpired))
                  ListTile(
                    leading: Icon(
                      _isExpired
                          ? Icons.check_circle
                          : Icons.stop_circle_outlined,
                      color: _isExpired
                          ? AppColors.berry400
                          : AppColors.orange400,
                    ),
                    title: Text(
                      _isExpired ? 'Mark as Collected' : 'Stop Machine',
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _stopMachine();
                    },
                  ),

                ListTile(
                  leading: Icon(Icons.delete, color: AppColors.berry400),
                  title: Text(
                    'Delete Machine',
                    style: TextStyle(color: AppColors.berry400),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _deleteMachine();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEditDialog() {
    showDialog(
      context: context,
      builder: (context) => EditMachineDialog(
        machine: widget.machine,
        onMachineUpdated: widget.onMachineUpdated,
      ),
    );
  }

  Future<void> _stopMachine() async {
    try {
      await ref.read(
        stopMachineProvider((
          machineId: widget.machine.id,
          dormId: widget.dormId,
        )),
      );
      widget.onMachineUpdated();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.machine.name} stopped'),
            backgroundColor: AppColors.green400,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error stopping machine: $e'),
            backgroundColor: AppColors.berry400,
          ),
        );
      }
    }
  }

  Future<void> _collectMachine() async {
    try {
      await ref.read(
        stopMachineProvider((
          machineId: widget.machine.id,
          dormId: widget.dormId,
        )),
      );
      widget.onMachineUpdated();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${widget.machine.name} collected - Machine is now available',
            ),
            backgroundColor: AppColors.green400,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error collecting from machine: $e'),
            backgroundColor: AppColors.berry400,
          ),
        );
      }
    }
  }

  Future<void> _deleteMachine() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Machine'),
        content: Text(
          'Are you sure you want to delete ${widget.machine.name}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete', style: TextStyle(color: AppColors.berry400)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(
          deleteLaundryMachineProvider((
            machineId: widget.machine.id,
            dormId: widget.dormId,
          )),
        );
        widget.onMachineUpdated();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${widget.machine.name} deleted'),
              backgroundColor: AppColors.green400,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting machine: $e'),
              backgroundColor: AppColors.berry400,
            ),
          );
        }
      }
    }
  }

  Future<void> _markMachineFinished() async {
    try {
      await ref.read(
        markMachineFinishedProvider((
          machineId: widget.machine.id,
          dormId: widget.dormId,
        )),
      );
      widget.onMachineUpdated();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.machine.name} cycle finished!'),
            backgroundColor: AppColors.orange400,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error marking machine as finished: $e'),
            backgroundColor: AppColors.berry400,
          ),
        );
      }
    }
  }

  String _formatTime(int minutes) {
    if (minutes <= 0) return '0m';

    final hours = minutes ~/ 60;
    final mins = minutes % 60;

    if (hours > 0) {
      return '${hours}h ${mins}m';
    } else {
      return '${mins}m';
    }
  }
}
