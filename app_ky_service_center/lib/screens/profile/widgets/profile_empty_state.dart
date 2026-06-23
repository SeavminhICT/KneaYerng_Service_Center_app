import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../widgets/empty_state_view.dart';
import 'profile_colors.dart';

/// Card shown when no profile data is available, prompting the user to
/// log in or register.
class ProfileEmptyState extends StatelessWidget {
  const ProfileEmptyState({super.key, required this.onGoToLogin});

  final VoidCallback onGoToLogin;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: profileSurface(context),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x120F172A),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: EmptyStateView(
        icon: HugeIcons.strokeRoundedUser,
        title: 'No profile data found',
        subtitle: 'Please login or register to view your profile information.',
        actionLabel: 'Go to Login',
        onAction: onGoToLogin,
      ),
    );
  }
}
