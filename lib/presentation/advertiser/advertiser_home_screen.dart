import 'package:flutter/material.dart';
import 'package:promoruta/core/constants/colors.dart';
import 'package:promoruta/gen/l10n/app_localizations.dart';
import 'package:promoruta/shared/widgets/bottom_navigation_item.dart';
import 'package:promoruta/presentation/advertiser/pages/advertiser_home_page.dart';
import 'package:promoruta/presentation/advertiser/pages/advertiser_campaigns_page.dart';
import 'package:promoruta/presentation/advertiser/pages/advertiser_live_page.dart';
import 'package:promoruta/presentation/advertiser/pages/advertiser_history_page.dart';
import 'package:promoruta/presentation/advertiser/pages/advertiser_profile_page.dart';

class AdvertiserHomeScreen extends StatefulWidget {
  const AdvertiserHomeScreen({super.key});

  @override
  State<AdvertiserHomeScreen> createState() => _AdvertiserHomeScreenState();
}

class _AdvertiserHomeScreenState extends State<AdvertiserHomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        elevation: 0,
        centerTitle: false,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.goodMorning,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    )),
            const SizedBox(height: 2),
            Text(
              l10n.readyToCreateNextCampaign,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
      body: _getPage(_currentIndex),
      floatingActionButton: FloatingActionButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
        backgroundColor: AppColors.secondary,
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.createCampaignWip)),
          );
        },
        child: const Icon(
          Icons.add_rounded,
          color: Colors.white,
          size: 38,
        ),
      ),
      bottomNavigationBar: Container(
        height: kBottomNavigationBarHeight,
        decoration: const BoxDecoration(
          color: Colors.white,
          border:
              Border(top: BorderSide(color: AppColors.grayStroke, width: 1)),
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
        return const AdvertiserProfilePage();
      default:
        return const AdvertiserHomePage();
    }
  }
}
