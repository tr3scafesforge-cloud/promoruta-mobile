import 'package:flutter/material.dart';
import 'package:promoruta/shared/shared.dart';

class AdvertiserLivePage extends StatefulWidget {
  const AdvertiserLivePage({super.key});

  @override
  State<AdvertiserLivePage> createState() => _AdvertiserLivePageState();
}

class _AdvertiserLivePageState extends State<AdvertiserLivePage> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F7),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MultiSwitch(
                options: [
                  'Promotores Activos', // "Promotores Activos"
                  'Live Map',
                  'Alertas',
                ],
                initialIndex: _selectedTab,
                onChanged: (index) => setState(() => _selectedTab = index),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _buildTabContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTab) {
      case 0:
        return _ActivePromotersTab();
      case 1:
        return _LiveMapTab();
      case 2:
        return _AlertsTab();
      default:
        return _ActivePromotersTab();
    }
  }
}

class _LiveCard extends StatelessWidget {
  const _LiveCard({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(12);
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: borderRadius),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Row(
              children: [
                const Icon(Icons.place_outlined,
                    size: 18, color: Colors.black87),
                const SizedBox(width: 6),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Map placeholder (swap with GoogleMap later)
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: const Color(0xFFF6F8FA),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: const _MapPlaceholder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapPlaceholder extends StatelessWidget {
  const _MapPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.location_on_outlined,
              size: 44, color: Colors.black54),
          const SizedBox(height: 8),
          Text(
            'Map Location in real time',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }
}

class _ActivePromotersTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        _LiveCard(title: '👥 Promotores Activos'),
        const SizedBox(height: 16),
        // Add more content for active promoters
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Promotores en actividad',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Aquí se mostrarán los promotores que están actualmente activos en tus campañas.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.black54,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LiveMapTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        _LiveCard(title: '📍 Localización en tiempo real'),
        const SizedBox(height: 16),
        // Add more content for live map
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mapa en vivo',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Visualiza la ubicación en tiempo real de tus promotores en el mapa.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.black54,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AlertsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.notifications_outlined,
                      size: 18, color: Colors.black87),
                  const SizedBox(width: 6),
                  Text(
                    'Alertas y Notificaciones',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Aquí recibirás alertas importantes sobre tus campañas y promotores.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.black54,
                    ),
              ),
              const SizedBox(height: 16),
              // Sample alerts
              _AlertItem(
                icon: Icons.warning_amber_rounded,
                title: 'Promotor fuera de zona',
                message: 'Juan Pérez está fuera de la zona asignada',
                time: 'Hace 5 min',
                color: Colors.orange,
              ),
              const SizedBox(height: 12),
              _AlertItem(
                icon: Icons.check_circle,
                title: 'Campaña completada',
                message: 'La campaña "Promoción Cafetería" ha finalizado',
                time: 'Hace 1 hora',
                color: Colors.green,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AlertItem extends StatelessWidget {
  const _AlertItem({
    required this.icon,
    required this.title,
    required this.message,
    required this.time,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String message;
  final String time;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  message,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.black87,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.black54,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
