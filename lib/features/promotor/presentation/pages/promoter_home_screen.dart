import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:promoruta/core/constants/colors.dart';
import 'package:promoruta/features/promotor/presentation/pages/promoter_earnings_page.dart';
import 'package:promoruta/presentation/promotor/pages/promoter_profile_page.dart';
import 'package:promoruta/presentation/promotor/pages/promoter_home_page.dart';
import 'package:promoruta/presentation/promotor/pages/promoter_nearby_page.dart';
import 'package:promoruta/presentation/promotor/pages/promoter_active_page.dart';
import 'package:promoruta/shared/widgets/promoter_app_bar.dart';
import 'package:promoruta/shared/providers/providers.dart';

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
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(context),
      body: SafeArea(
        top: false,
        child: _getPage(_currentIndex),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: _accent,
        onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Ir a ruta (WIP)')),
            );
        },
        child: const Icon(Icons.near_me_rounded),
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
              label: 'Inicio',
              onTap: () => setState(() => _currentIndex = 0),
              splashColor: _accent.withValues(alpha: .10),
            ),
            _BottomNavigationItem(
              isSelected: _currentIndex == 1,
              icon: Icons.place_rounded,
              label: 'En tu zona',
              onTap: () => setState(() => _currentIndex = 1),
              splashColor: _accent.withValues(alpha: .10),
            ),
            _BottomNavigationItem(
              isSelected: _currentIndex == 2,
              icon: Icons.play_circle_rounded,
              label: 'Activa',
              onTap: () => setState(() => _currentIndex = 2),
              splashColor: _accent.withValues(alpha: .10),
            ),
            _BottomNavigationItem(
              isSelected: _currentIndex == 3,
              icon: Icons.attach_money_rounded,
              label: 'Ganancias',
              onTap: () => setState(() => _currentIndex = 3),
              splashColor: _accent.withValues(alpha: .10),
            ),
            _BottomNavigationItem(
              isSelected: _currentIndex == 4,
              icon: Icons.person_rounded,
              label: 'Perfil',
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
          isDarkMode: Theme.of(context).brightness == Brightness.dark,
          onToggleDarkMode: (isDark) {
            ref.read(themeModeProvider.notifier).setThemeMode(
                  isDark ? ThemeMode.dark : ThemeMode.light,
                );
          },
        );
      default:
        return const PromoterHomePage();
    }
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    switch (_currentIndex) {
      case 0: // Home
        return PromoterAppBar(
          title: '¿Listo para sumar ingresos?',
          subtitle: 'Tomá campañas cercanas y empezá la promo.',
        );
      case 1: // Nearby
        return PromoterAppBar(title: 'En tu zona');
      case 2: // Active
        return PromoterAppBar(title: 'Activa');
      case 3: // Earnings
        return PromoterAppBar(title: 'Ganancias');
      case 4: // Profile
        return PromoterAppBar(title: 'Perfil');
      default:
        return PromoterAppBar(title: 'Inicio');
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

