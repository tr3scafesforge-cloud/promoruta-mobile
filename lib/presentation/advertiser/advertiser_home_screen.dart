import 'package:flutter/material.dart';
import 'package:promoruta/core/constants/colors.dart';

class AdvertiserHomeScreen extends StatefulWidget {
  const AdvertiserHomeScreen({super.key});

  @override
  State<AdvertiserHomeScreen> createState() => _AdvertiserHomeScreenState();
}

class _AdvertiserHomeScreenState extends State<AdvertiserHomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F7),
      appBar: AppBar(
        elevation: 0,
        centerTitle: false,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Buenos días',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    )),
            const SizedBox(height: 2),
            Text(
              'Listo para crear tu próxima campaña',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
      body: _currentIndex == 0 ? const _HomeContent() : _PlaceholderTab(index: _currentIndex),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Crear campaña (WIP)')),
          );
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey[600],
        type: BottomNavigationBarType.fixed,
        onTap: (i) {
          setState(() => _currentIndex = i);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.view_list_rounded), label: 'Campañas'),
          BottomNavigationBarItem(icon: Icon(Icons.podcasts_rounded), label: 'En vivo'),
          BottomNavigationBarItem(icon: Icon(Icons.history_rounded), label: 'Historial'),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Perfil'),
        ],
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      children: [
        // KPI cards
        Row(
          children: const [
            Expanded(
              child: _StatCard(
                icon: Icons.trending_up_rounded,
                value: '3',
                labelTop: 'Campañas',
                labelBottom: 'Activas',
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: Icons.place_rounded,
                value: '12',
                labelTop: 'Zonas recorridas',
                labelBottom: 'esta semana',
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: Icons.attach_money_rounded,
                value: '\$284',
                labelTop: 'Inversión',
                labelBottom: 'acumulada',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // First campaign card
        const _CreateFirstCampaignCard(),

        const SizedBox(height: 16),

        // Section header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Campañas activas',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    )),
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Ver todas (WIP)')),
                );
              },
              child: const Text('Ver todas'),
            ),
          ],
        ),

        // Campaign list
        const _CampaignCard(
          icon: Icons.play_circle_fill_rounded,
          iconColor: Colors.teal,
          title: 'Promoción Cafetería',
          statusChipLabel: 'En vivo',
          statusChipColor: Color(0xFFE6F4FF),
          rightAmount: '\$48.20',
          rightSubtitle: 'Hoy',
          metrics: [
            _CampaignMetric(value: '2.4km', label: 'Ruta'),
            _CampaignMetric(value: '45s', label: 'Audio'),
            _CampaignMetric(value: '68%', label: 'Completado'),
          ],
          subtitle: '2 Promotores activos',
        ),
        const SizedBox(height: 12),
        const _CampaignCard(
          icon: Icons.schedule_rounded,
          iconColor: Color(0xFFFFB74D),
          title: 'Apertura Tienda',
          statusChipLabel: 'Pendiente',
          statusChipColor: Color(0xFFFFF3E0),
          rightAmount: '\$0.00',
          rightSubtitle: 'Hoy',
          metrics: [
            _CampaignMetric(value: '1.8km', label: 'Ruta'),
            _CampaignMetric(value: '30s', label: 'Audio'),
            _CampaignMetric(value: '0%', label: 'Completado'),
          ],
          subtitle: 'Esperando promotores',
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String labelTop;
  final String labelBottom;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.labelTop,
    required this.labelBottom,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: const Color(0xFFF0F6F5),
              child: Icon(icon, color: AppColors.primary),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 2),
            Text(
              labelTop,
              textAlign: TextAlign.center,
              style:
                  Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.grey[700]),
            ),
            Text(
              labelBottom,
              textAlign: TextAlign.center,
              style:
                  Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateFirstCampaignCard extends StatelessWidget {
  const _CreateFirstCampaignCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5F1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.add, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Crea tu primera campaña',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          )),
                  const SizedBox(height: 4),
                  Text(
                    'Diseñá un aviso de audio, marcá tu recorrido y empezá a promocionar',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 40,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Iniciar campaña (WIP)')),
                        );
                      },
                      child: const Text('Iniciar campaña'),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CampaignCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String statusChipLabel;
  final Color statusChipColor;
  final String rightAmount;
  final String rightSubtitle;
  final List<_CampaignMetric> metrics;

  const _CampaignCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.statusChipLabel,
    required this.statusChipColor,
    required this.rightAmount,
    required this.rightSubtitle,
    required this.metrics,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            // Header row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: statusChipColor,
                  child: Icon(icon, color: iconColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              )),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: statusChipColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              statusChipLabel,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(color: Colors.grey[800]),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            subtitle,
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium
                                ?.copyWith(color: Colors.grey[700]),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      rightAmount,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    Text(rightSubtitle,
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(color: Colors.grey[700])),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Metrics row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: metrics
                  .map((m) => Expanded(
                        child: _MetricTile(value: m.value, label: m.label),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String value;
  final String label;

  const _MetricTile({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style:
                Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }
}

class _CampaignMetric {
  final String value;
  final String label;
  const _CampaignMetric({required this.value, required this.label});
}

class _PlaceholderTab extends StatelessWidget {
  final int index;
  const _PlaceholderTab({required this.index});

  String get _label => switch (index) {
        1 => 'Campañas',
        2 => 'En vivo',
        3 => 'Historial',
        4 => 'Perfil',
        _ => 'Inicio'
      };

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('$_label (pendiente)',
          style: Theme.of(context).textTheme.titleMedium),
    );
  }
}
