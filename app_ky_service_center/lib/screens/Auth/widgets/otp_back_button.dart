import 'package:flutter/material.dart';

/// Circular back button used at the top-left of every step of the flow.
class OtpBackBtn extends StatelessWidget {
  const OtpBackBtn({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: CircleBorder(
        side: BorderSide(color: const Color(0xFFE4ECF7), width: 1.1),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.maybePop(context),
        child: const SizedBox(
          width: 40,
          height: 40,
          child: Icon(
            Icons.chevron_left_rounded,
            color: Color(0xFF637083),
            size: 22,
          ),
        ),
      ),
    );
  }
}
