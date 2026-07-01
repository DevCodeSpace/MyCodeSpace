import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';

class BrandHeader extends StatelessWidget {
  const BrandHeader({
    super.key,
    this.leading,
    this.showSearch = false,
    this.showBell = false,
  });

  final Widget? leading;
  final bool showSearch;
  final bool showBell;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 18),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border(
          bottom: BorderSide(color: AppTheme.gold.withValues(alpha: 0.14)),
        ),
      ),
      child: Row(
        children: [
          if (leading != null) ...[leading!, const SizedBox(width: 16)],
          const _CodexLogo(),
          const SizedBox(width: 14),
          const Expanded(
            child: Text(
              'CODEXSHARE',
              style: TextStyle(
                color: AppTheme.gold,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
                fontSize: 18,
              ),
            ),
          ),
          // if (showSearch)
          //   const Padding(
          //     padding: EdgeInsets.only(right: 10),
          //     child: Icon(Icons.search_rounded, color: AppTheme.textMuted),
          //   ),
          // if (showBell)
          //   const Padding(
          //     padding: EdgeInsets.only(right: 12),
          //     child: Icon(
          //       Icons.notifications_none_rounded,
          //       color: AppTheme.textMuted,
          //     ),
          //   ),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.panelBlue,
              border: Border.all(color: AppTheme.gold.withValues(alpha: 0.35)),
            ),
            child: const Icon(
              Icons.account_circle_rounded,
              color: AppTheme.gold,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }
}

class _CodexLogo extends StatelessWidget {
  const _CodexLogo();

  @override
  Widget build(BuildContext context) {
    return Image.asset('assets/images/app_logo.png', width: 32, height: 32);
  }
}
