import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../dorm/presentation/providers/dorm_providers.dart';
import '../../../dorm/domain/entities/dorm_member.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/entities/laundry_machine.dart';

class CompactMachineCard extends ConsumerStatefulWidget {
  final LaundryMachine machine;
  final String dormId;

  const CompactMachineCard({
    super.key,
    required this.machine,
    required this.dormId,
  });

  @override
  ConsumerState<CompactMachineCard> createState() => _CompactMachineCardState();
}

class _CompactMachineCardState extends ConsumerState<CompactMachineCard>
    with TickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    if (widget.machine.isInUse) {
      _animationController.repeat();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final remainingMinutes = widget.machine.remainingMinutes ?? 0;
    final isExpired = remainingMinutes <= 0;

    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: AppSpacing.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.md),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            widget.machine.type == MachineType.washer
                ? AppColors.cyan400.withOpacity(0.1)
                : Colors.grey.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
        ),
        border: Border.all(
          color: widget.machine.type == MachineType.washer
              ? AppColors.cyan400.withOpacity(0.2)
              : Colors.grey.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: widget.machine.type == MachineType.washer
                ? AppColors.cyan400.withOpacity(0.1)
                : Colors.grey.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.md),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.2),
                  Colors.white.withOpacity(0.05),
                ],
              ),
            ),
            child: Row(
              children: [
                // Machine icon with animation
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: widget.machine.type == MachineType.washer
                        ? AppColors.cyan400.withOpacity(0.15)
                        : Colors.grey.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: _buildAnimatedIcon(),
                  ),
                ),
                
                const SizedBox(width: AppSpacing.md),
                
                // Machine info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Machine name
                      Text(
                        widget.machine.name,
                        style: AppTypography.labelMd.copyWith(
                          color: AppColors.cream800,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      const SizedBox(height: 2),
                      
                      // Status
                      isExpired 
                        ? Text(
                            'Finished - Collect now',
                            style: AppTypography.labelSm.copyWith(
                              color: AppColors.berry600,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )
                        : _buildStatusText(remainingMinutes),
                    ],
                  ),
                ),
                
                // Status indicator
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isExpired ? AppColors.berry400 : AppColors.orange400,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedIcon() {
    if (widget.machine.type == MachineType.washer) {
      return AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.rotate(
            angle: _animationController.value * 2 * 3.14159,
            child: Icon(
              Icons.water_drop_rounded,
              size: 20,
              color: AppColors.cyan400,
            ),
          );
        },
      );
    } else {
      return AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(
              ((_animationController.value * 2 - 1) * 3),
              0,
            ),
            child: Icon(
              Icons.air,
              size: 20,
              color: Colors.grey.shade600,
            ),
          );
        },
      );
    }
  }

  Widget _buildStatusText(int remainingMinutes) {
    final authState = ref.watch(authStateChangesProvider);
    final currentUser = authState.value;
    final isCurrentUserUsing = widget.machine.currentUserId == currentUser?.uid;
    
    if (isCurrentUserUsing) {
      return Text(
        'You are using - ${_formatTime(remainingMinutes)} left',
        style: AppTypography.labelSm.copyWith(
          color: AppColors.orange600,
          fontWeight: FontWeight.w500,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }
    
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
          '${user.displayName} is using - ${_formatTime(remainingMinutes)} left',
          style: AppTypography.labelSm.copyWith(
            color: AppColors.orange600,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        );
      },
      loading: () => Text(
        'In use - ${_formatTime(remainingMinutes)} left',
        style: AppTypography.labelSm.copyWith(
          color: AppColors.orange600,
          fontWeight: FontWeight.w500,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      error: (_, __) => Text(
        'In use - ${_formatTime(remainingMinutes)} left',
        style: AppTypography.labelSm.copyWith(
          color: AppColors.orange600,
          fontWeight: FontWeight.w500,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
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