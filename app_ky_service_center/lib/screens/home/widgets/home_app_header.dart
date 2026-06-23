import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../l10n/app_localizations.dart';
import '../../../services/cart_service.dart';
import '../../../theme/app_fonts.dart';
import 'home_colors.dart';

/// Top app header: greeting text plus the notification and cart icon
/// buttons used on the home screen.
class HomeAppHeader extends StatelessWidget {
  const HomeAppHeader({
    super.key,
    required this.title,
    required this.welcomeName,
    required this.onNotificationTap,
    required this.onCartTap,
  });

  final String title;
  final String welcomeName;
  final VoidCallback onNotificationTap;
  final VoidCallback onCartTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final greeting = welcomeName == 'User'
        ? 'Buy. Repair. Trust.'
        : '${l.helloUser}, $welcomeName';
    final firstLetter = title.isNotEmpty ? title[0] : '';
    final remainingTitle = title.length > 1 ? title.substring(1) : '';

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: firstLetter,
                      style: kFont(context,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: homePrimary,
                      ),
                    ),
                    TextSpan(
                      text: remainingTitle,
                      style: kFont(context,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: homeTextPrimary(context),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                greeting,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: kmFont(context, GoogleFonts.manrope(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: homeTextMuted(context),
                )),
              ),
            ],
          ),
        ),
        HomeIconCircleButton(
          icon: HugeIcons.strokeRoundedNotification01,
          onTap: onNotificationTap,
          badgeCount: 1,
        ),
        const SizedBox(width: 6),
        HomeCartIconButton(onTap: onCartTap),
      ],
    );
  }
}

class HomeIconCircleButton extends StatelessWidget {
  const HomeIconCircleButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.badgeCount,
  });

  final IconData icon;
  final VoidCallback onTap;
  final int? badgeCount;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Container(
            height: 46,
            width: 46,
            decoration: BoxDecoration(
              color: homeSurface(context),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: homeCardBorder(context)),
              boxShadow: const [
                BoxShadow(color: homeShadow, blurRadius: 12, offset: Offset(0, 6)),
              ],
            ),
            child: Icon(icon, size: 20, color: homeTextPrimary(context)),
          ),
        ),
        if ((badgeCount ?? 0) > 0)
          Positioned(
            top: -2,
            right: -2,
            child: Container(
              constraints: const BoxConstraints(minWidth: 19, minHeight: 19),
              padding: const EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                color: homePrimary,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Colors.white, width: 2),
              ),
              alignment: Alignment.center,
              child: Text(
                '$badgeCount',
                style: kmFont(context, GoogleFonts.manrope(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                )),
              ),
            ),
          ),
      ],
    );
  }
}

class HomeCartIconButton extends StatelessWidget {
  const HomeCartIconButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: CartService.instance,
      builder: (context, _) {
        final count = CartService.instance.totalItems;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            HomeIconCircleButton(icon: HugeIcons.strokeRoundedShoppingCart01, onTap: onTap),
            if (count > 0)
              Positioned(
                top: -2,
                right: -2,
                child: Container(
                  constraints: const BoxConstraints(
                    minWidth: 19,
                    minHeight: 19,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    color: homePrimary,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$count',
                    style: kmFont(context, GoogleFonts.manrope(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                    )),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
