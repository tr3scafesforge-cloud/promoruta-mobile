import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:promoruta/app/routes/app_router.dart';
import 'package:promoruta/core/constants/colors.dart';
import 'package:promoruta/features/advertiser/presentation/pages/advertiser_home_page.dart';
import 'package:promoruta/gen/l10n/app_localizations.dart';
import 'package:promoruta/shared/widgets/bottom_navigation_item.dart';
import '../widgets/advertiser_app_bar.dart';
import 'package:promoruta/features/advertiser/campaign_management/presentation/pages/advertiser_campaigns_page.dart';
import 'package:promoruta/features/advertiser/campaign_management/presentation/pages/advertiser_live_map_page.dart';
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
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Check if we need to navigate to a specific tab
    final uri = GoRouterState.of(context).uri;
    final tab = uri.queryParameters['tab'];
    if (tab != null) {
      final tabIndex = _getTabIndex(tab);
      if (tabIndex != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(advertiserTabProvider.notifier).setTab(tabIndex);
        });
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
    final currentIndex = ref.watch(advertiserTabProvider);

    return Scaffold(
      appBar: _buildAppBar(context, l10n, currentIndex),
      body: SafeArea(
        top: false,
        child: _getPage(currentIndex),
      ),
      floatingActionButton: currentIndex == 4
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
              isSelected: currentIndex == 0,
              icon: Icons.home_rounded,
              label: l10n.home,
              onTap: () => ref.read(advertiserTabProvider.notifier).setTab(0),
              splashColor: AppColors.secondary.withValues(alpha: .10),
            ),
            BottomNavigationItem(
              isSelected: currentIndex == 1,
              icon: Icons.view_list_rounded,
              label: l10n.campaigns,
              onTap: () => ref.read(advertiserTabProvider.notifier).setTab(1),
              splashColor: AppColors.secondary.withValues(alpha: .10),
            ),
            BottomNavigationItem(
              isSelected: currentIndex == 2,
              icon: Icons.podcasts_rounded,
              label: l10n.live,
              onTap: () => ref.read(advertiserTabProvider.notifier).setTab(2),
              splashColor: AppColors.secondary.withValues(alpha: .10),
            ),
            BottomNavigationItem(
              isSelected: currentIndex == 3,
              icon: Icons.history_rounded,
              label: l10n.history,
              onTap: () => ref.read(advertiserTabProvider.notifier).setTab(3),
              splashColor: AppColors.secondary.withValues(alpha: .10),
            ),
            BottomNavigationItem(
              isSelected: currentIndex == 4,
              icon: Icons.person_rounded,
              label: l10n.profile,
              onTap: () => ref.read(advertiserTabProvider.notifier).setTab(4),
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
        return const AdvertiserLiveMapPage();
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
          onTapAccount: () => const UserProfileRoute().push(context),
        );
      default:
        return const AdvertiserHomePage();
    }
  }

  PreferredSizeWidget _buildAppBar(
      BuildContext context, AppLocalizations l10n, int currentIndex) {
    switch (currentIndex) {
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
      case 2: // Live - uses custom header in the page itself
        return const PreferredSize(
          preferredSize: Size.zero,
          child: SizedBox.shrink(),
        );
      case 3: // History
        return AdvertiserAppBar(title: l10n.history);
      case 4: // Profile
        return AdvertiserAppBar(title: l10n.profile);
      default:
        return AdvertiserAppBar(title: l10n.home);
    }
  }
}
