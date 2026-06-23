import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

/// Type of notification campaign that can be composed in the admin panel.
enum AdminComposerType { announcement, promotion, alert, info, reminder }

extension AdminComposerTypeX on AdminComposerType {
  String get label {
    switch (this) {
      case AdminComposerType.announcement:
        return 'Announcement';
      case AdminComposerType.promotion:
        return 'Promotion';
      case AdminComposerType.alert:
        return 'Alert';
      case AdminComposerType.info:
        return 'Info';
      case AdminComposerType.reminder:
        return 'Reminder';
    }
  }

  IconData get icon {
    switch (this) {
      case AdminComposerType.announcement:
        return HugeIcons.strokeRoundedMegaphone01;
      case AdminComposerType.promotion:
        return HugeIcons.strokeRoundedDiscount01;
      case AdminComposerType.alert:
        return HugeIcons.strokeRoundedAlert02;
      case AdminComposerType.info:
        return HugeIcons.strokeRoundedInformationCircle;
      case AdminComposerType.reminder:
        return HugeIcons.strokeRoundedNotification03;
    }
  }

  Color get color {
    switch (this) {
      case AdminComposerType.announcement:
        return const Color(0xFF4A88F7);
      case AdminComposerType.promotion:
        return const Color(0xFF8B5CF6);
      case AdminComposerType.alert:
        return const Color(0xFFEF4444);
      case AdminComposerType.info:
        return const Color(0xFF06B6D4);
      case AdminComposerType.reminder:
        return const Color(0xFFF59E0B);
    }
  }

  String get starterTitle {
    switch (this) {
      case AdminComposerType.announcement:
        return 'New service center update';
      case AdminComposerType.promotion:
        return 'Limited-time repair promotion';
      case AdminComposerType.alert:
        return 'Important account alert';
      case AdminComposerType.info:
        return 'Useful info for your next visit';
      case AdminComposerType.reminder:
        return 'Friendly reminder from KY Service Center';
    }
  }

  String get starterBody {
    switch (this) {
      case AdminComposerType.announcement:
        return 'We have a new announcement for all customers. Open the app for details.';
      case AdminComposerType.promotion:
        return 'Get special pricing on selected repair services this week only.';
      case AdminComposerType.alert:
        return 'Please review this important update as soon as possible.';
      case AdminComposerType.info:
        return 'We added new support options to help you faster.';
      case AdminComposerType.reminder:
        return 'This is your reminder to check your latest service update.';
    }
  }
}
