import 'package:flutter/material.dart';
import 'package:promoruta/shared/shared.dart';

class AdvertiserLivePage extends StatefulWidget {
  const AdvertiserLivePage({super.key});

  @override
  State<AdvertiserLivePage> createState() => _AdvertiserLivePageState();
}

class _AdvertiserLivePageState extends State<AdvertiserLivePage> {
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
                  'Promotores Activos', // “Promotores Activos”
                  'Live Map',
                  'Alertas',
                ],
                initialIndex: 0,
                onChanged: (index) => setState(() => {}),
              ),
              const SizedBox(height: 16),
              _LiveCard(title: '📍 Localización en tiempo real'),
            ],
          ),
        ),
      ),
    );
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
