import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/currency_formatter.dart';
import '../../domain/models/fund_state.dart';

/// The main dashboard card showing Spendable, Principal, and Locked amounts.
/// Features an animated gradient background and a visual partition bar.
class BalanceCard extends StatefulWidget {
  const BalanceCard({super.key, required this.fundState});
  final FundState fundState;

  @override
  State<BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<BalanceCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnim = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.fundState;
    final isOverspent = state.isOverspent;

    return FadeTransition(
      opacity: _fadeAnim,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isOverspent
                  ? AppColors.dangerGradient
                  : AppColors.accentGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: (isOverspent ? AppColors.error : AppColors.accent)
                    .withOpacity(0.35),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Decorative circles
              Positioned(
                right: -40,
                top: -40,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.07),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                right: 20,
                top: 40,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          isOverspent ? 'Over Budget' : 'Safe to Spend',
                          style: AppTextStyles.labelMedium(context).copyWith(
                            color: Colors.white.withOpacity(0.8),
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(width: 6),
                        if (isOverspent)
                          const Icon(Icons.warning_amber_rounded,
                              color: Colors.white, size: 16),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Main spendable amount
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      transitionBuilder: (child, anim) => FadeTransition(
                        opacity: anim,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.1),
                            end: Offset.zero,
                          ).animate(anim),
                          child: child,
                        ),
                      ),
                      child: Text(
                        CurrencyFormatter.format(state.spendableAmount),
                        key: ValueKey(state.spendableAmount),
                        style: AppTextStyles.displayLarge(context).copyWith(
                          color: Colors.white,
                          fontSize: 44,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Partition bar
                    _buildPartitionBar(context, state),
                    const SizedBox(height: 20),
                    // Principal and Locked tiles
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoTile(
                            context,
                            label: 'Principal',
                            value: CurrencyFormatter.formatCompact(
                                state.principalAmount),
                            icon: Icons.account_balance_rounded,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildInfoTile(
                            context,
                            label: 'Locked',
                            value: CurrencyFormatter.formatCompact(
                                state.lockedAmount),
                            icon: Icons.lock_rounded,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPartitionBar(BuildContext context, FundState state) {
    final principal = state.principalAmount;
    if (principal <= 0) return const SizedBox();

    final spendableRatio =
        (state.spendableAmount / principal).clamp(0.0, 1.0);
    final lockedRatio = (state.lockedAmount / principal).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${(spendableRatio * 100).toStringAsFixed(0)}% spendable',
          style: AppTextStyles.labelSmall(context).copyWith(
            color: Colors.white.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Container(
            height: 6,
            color: Colors.white.withOpacity(0.2),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: spendableRatio,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoTile(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.labelSmall(context)
                      .copyWith(color: Colors.white60, fontSize: 10),
                ),
                Text(
                  value,
                  style: AppTextStyles.labelLarge(context)
                      .copyWith(color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
