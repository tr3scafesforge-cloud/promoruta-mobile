import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:promoruta/core/constants/colors.dart';
import 'package:promoruta/features/promotor/campaign_browsing/presentation/pages/promoter_nearby_page.dart';
import 'package:promoruta/features/promotor/presentation/pages/promoter_earnings_page.dart';
import 'package:promoruta/presentation/promotor/pages/promoter_profile_page.dart';
import 'package:promoruta/presentation/promotor/pages/promoter_home_page.dart';
import 'package:promoruta/features/promotor/presentation/pages/promoter_active_page.dart';
import 'package:promoruta/shared/widgets/promoter_app_bar.dart';
import 'package:promoruta/gen/l10n/app_localizations.dart';
import 'package:promoruta/app/routes/app_router.dart';

class PromoterHomeScreen extends ConsumerStatefulWidget {
  const PromoterHomeScreen({super.key});

  @override
  ConsumerState<PromoterHomeScreen> createState() => _PromoterHomeScreenState();
}

class _PromoterHomeScreenState extends ConsumerState<PromoterHomeScreen> {
  int _currentIndex = 0;

  // If your design uses a specific orange for promoter, set it here.
  // Swap this for a constant in your theme if you have one.
  static const Color _accent = AppColors.deepOrange;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(context),
      body: SafeArea(
        top: false,
        child: _getPage(_currentIndex),
      ),
      floatingActionButton: _currentIndex == 4
          ? null
          : FloatingActionButton(
              elevation: 0.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
              backgroundColor: _accent,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Ir a ruta (WIP)')),
                );
              },
              child: const Icon(
                Icons.near_me_rounded,
                color: Colors.white,
                size: 30,
              ),
            ),
      bottomNavigationBar: Container(
        height: kBottomNavigationBarHeight +
            MediaQuery.of(context).viewPadding.bottom,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border(
              top: BorderSide(
                  color: Theme.of(context).colorScheme.outline, width: 1)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _BottomNavigationItem(
              isSelected: _currentIndex == 0,
              icon: Icons.home_rounded,
              label: l10n.home,
              onTap: () => setState(() => _currentIndex = 0),
              splashColor: _accent.withValues(alpha: .10),
            ),
            _BottomNavigationItem(
              isSelected: _currentIndex == 1,
              icon: Icons.place_rounded,
              label: l10n.inYourArea,
              onTap: () => setState(() => _currentIndex = 1),
              splashColor: _accent.withValues(alpha: .10),
            ),
            _BottomNavigationItem(
              isSelected: _currentIndex == 2,
              icon: Icons.play_circle_rounded,
              label: l10n.activeSingular,
              onTap: () => setState(() => _currentIndex = 2),
              splashColor: _accent.withValues(alpha: .10),
            ),
            _BottomNavigationItem(
              isSelected: _currentIndex == 3,
              icon: Icons.attach_money_rounded,
              label: l10n.earnings,
              onTap: () => setState(() => _currentIndex = 3),
              splashColor: _accent.withValues(alpha: .10),
            ),
            _BottomNavigationItem(
              isSelected: _currentIndex == 4,
              icon: Icons.person_rounded,
              label: l10n.profile,
              onTap: () => setState(() => _currentIndex = 4),
              splashColor: _accent.withValues(alpha: .10),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return const PromoterHomePage();
      case 1:
        return const PromoterNearbyPage();
      case 2:
        return const PromoterActivePage();
      case 3:
        return const PromoterEarningsPage();
      case 4:
        return PromoterProfilePage(
          onTapSecurity: () =>
              const PromoterSecuritySettingsRoute().push(context),
        );
      default:
        return const PromoterHomePage();
    }
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    switch (_currentIndex) {
      case 0: // Home
        return PromoterAppBar(
          title: l10n.readyToEarnIncome,
          subtitle: l10n.takeCampaignsNearbyStartPromo,
        );
      case 1: // Nearby
        return PromoterAppBar(
          title: l10n.nearbyCampaignsTitle,
          subtitle: l10n.discoverNearbyCampaigns,
        );
      case 2: // Active
        return PromoterAppBar(
          title: l10n.activeJobs,
          subtitle: l10n.controlYourCampaigns,
        );
      case 3: // Earnings
        return PromoterAppBar(
          title: l10n.earningsPageTitle,
          subtitle: l10n.earningsPageSubtitle,
        );
      case 4: // Profile
        return PromoterAppBar(title: l10n.profile);
      default:
        return PromoterAppBar(title: l10n.home);
    }
  }
}

class _BottomNavigationItem extends StatelessWidget {
  final bool isSelected;
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? splashColor;

  const _BottomNavigationItem({
    required this.isSelected,
    required this.icon,
    required this.label,
    required this.onTap,
    this.splashColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedColor = const Color(0xFFFF7A1A);
    final unselectedColor = theme.brightness == Brightness.dark
        ? Colors.white.withValues(alpha: .7)
        : theme.colorScheme.onSurfaceVariant;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        splashColor: splashColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? selectedColor : unselectedColor,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: isSelected ? selectedColor : unselectedColor,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
