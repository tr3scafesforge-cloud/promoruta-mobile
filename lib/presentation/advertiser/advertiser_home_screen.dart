import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:promoruta/app/routes/app_router.dart';
import 'package:promoruta/core/constants/colors.dart';
import 'package:promoruta/gen/l10n/app_localizations.dart';
import 'package:promoruta/shared/widgets/bottom_navigation_item.dart';
import 'package:promoruta/shared/widgets/advertiser_app_bar.dart';
import 'package:promoruta/presentation/advertiser/pages/advertiser_home_page.dart';
import 'package:promoruta/presentation/advertiser/pages/advertiser_campaigns_page.dart';
import 'package:promoruta/presentation/advertiser/pages/advertiser_live_page.dart';
import 'package:promoruta/presentation/advertiser/pages/advertiser_history_page.dart';
import 'package:promoruta/presentation/advertiser/pages/advertiser_profile_page.dart';
import 'package:promoruta/shared/providers/providers.dart';

class AdvertiserHomeScreen extends ConsumerStatefulWidget {
  const AdvertiserHomeScreen({super.key});

  @override
  ConsumerState<AdvertiserHomeScreen> createState() =>
      _AdvertiserHomeScreenState();
}

class _AdvertiserHomeScreenState extends ConsumerState<AdvertiserHomeScreen> {
  int _currentIndex = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Check if we need to navigate to a specific tab
    final uri = GoRouterState.of(context).uri;
    final tab = uri.queryParameters['tab'];
    if (tab != null) {
      final tabIndex = _getTabIndex(tab);
      if (tabIndex != null) {
        setState(() => _currentIndex = tabIndex);
      }
    }
  }

  int? _getTabIndex(String tabName) {
    switch (tabName) {
      case 'home':
        return 0;
      case 'campaigns':
        return 1;
      case 'live':
        return 2;
      case 'history':
        return 3;
      case 'profile':
        return 4;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: _buildAppBar(context, l10n),
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
              backgroundColor: AppColors.secondary,
              onPressed: () {
                const CreateCampaignRoute().push(context);
              },
              child: const Icon(
                Icons.add_rounded,
                color: Colors.white,
                size: 38,
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
            BottomNavigationItem(
              isSelected: _currentIndex == 0,
              icon: Icons.home_rounded,
              label: l10n.home,
              onTap: () => setState(() => _currentIndex = 0),
              splashColor: AppColors.secondary.withValues(alpha: .10),
            ),
            BottomNavigationItem(
              isSelected: _currentIndex == 1,
              icon: Icons.view_list_rounded,
              label: l10n.campaigns,
              onTap: () => setState(() => _currentIndex = 1),
              splashColor: AppColors.secondary.withValues(alpha: .10),
            ),
            BottomNavigationItem(
              isSelected: _currentIndex == 2,
              icon: Icons.podcasts_rounded,
              label: l10n.live,
              onTap: () => setState(() => _currentIndex = 2),
              splashColor: AppColors.secondary.withValues(alpha: .10),
            ),
            BottomNavigationItem(
              isSelected: _currentIndex == 3,
              icon: Icons.history_rounded,
              label: l10n.history,
              onTap: () => setState(() => _currentIndex = 3),
              splashColor: AppColors.secondary.withValues(alpha: .10),
            ),
            BottomNavigationItem(
              isSelected: _currentIndex == 4,
              icon: Icons.person_rounded,
              label: l10n.profile,
              onTap: () => setState(() => _currentIndex = 4),
              splashColor: AppColors.secondary.withValues(alpha: .10),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return const AdvertiserHomePage();
      case 1:
        return const AdvertiserCampaignsPage();
      case 2:
        return const AdvertiserLivePage();
      case 3:
        return const AdvertiserHistoryPage();
      case 4:
        return AdvertiserProfilePage(
          isDarkMode: Theme.of(context).brightness == Brightness.dark,
          onToggleDarkMode: (isDark) {
            ref.read(themeModeProvider.notifier).setThemeMode(
                  isDark ? ThemeMode.dark : ThemeMode.light,
                );
          },
          onTapSecurity: () =>
              const AdvertiserSecuritySettingsRoute().push(context),
          onTapLanguage: () => const LanguageSettingsRoute().push(context),
          onTapAccount: () => const UserProfileRoute().push(context),
        );
      default:
        return const AdvertiserHomePage();
    }
  }

  PreferredSizeWidget _buildAppBar(
      BuildContext context, AppLocalizations l10n) {
    switch (_currentIndex) {
      case 0: // Home
        return AdvertiserAppBar(
          title: l10n.goodMorning,
          subtitle: l10n.readyToCreateNextCampaign,
        );
      case 1: // Campaigns
        return AdvertiserAppBar(
          title: l10n.campaigns,
          actions: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
              child: FilledButton.icon(
                onPressed: () {
                  const CreateCampaignRoute().push(context);
                },
                icon: const Icon(Icons.add),
                label: Text(l10n.newCampaign),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF11A192),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  textStyle: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        );
      case 2: // Live
        return AdvertiserAppBar(title: l10n.live);
      case 3: // History
        return AdvertiserAppBar(title: l10n.history);
      case 4: // Profile
        return AdvertiserAppBar(title: l10n.profile);
      default:
        return AdvertiserAppBar(title: l10n.home);
    }
  }
}
