import 'package:flutter/material.dart';
import 'package:promoruta/core/constants/colors.dart';
import 'package:promoruta/shared/widgets/multi_switch.dart';

class PromoterNearbyPage extends StatefulWidget {
  const PromoterNearbyPage({super.key});

  @override
  State<PromoterNearbyPage> createState() => _PromoterNearbyPageState();
}

class _PromoterNearbyPageState extends State<PromoterNearbyPage> {
  int _selectedTabIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        // Header
        Text(
          'Campañas cercanas',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          'Descubrí campañas cerca tuyo',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
        ),
        const SizedBox(height: 20),

        // Search bar
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Buscar campañas',
            hintStyle: TextStyle(color: Colors.grey[500]),
            prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.activeCampaignColor, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
        const SizedBox(height: 20),

        // Tab switcher
        MultiSwitch(
          options: const ['Todas', 'Urgentes', 'Cercanas', 'Mejor pagadas'],
          initialIndex: _selectedTabIndex,
          onChanged: (index) {
            setState(() {
              _selectedTabIndex = index;
            });
          },
        ),
        const SizedBox(height: 20),

        // Map section
        const _MapSection(),
        const SizedBox(height: 24),

        // Campaign list header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Campañas disponibles (4)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Campaign cards
        const _CampaignCard(
          title: 'Apertura Tienda',
          description: 'Promocionar la apertura de la tienda',
          location: 'Nuevo Centro',
          distance: '2.4km',
          audioDuration: '45s',
          budget: '\$2000.00',
          urgencyMessage: 'Cierra en 2 h',
        ),
        const SizedBox(height: 12),
        const _CampaignCard(
          title: 'Promoción Restaurante',
          description: 'Promoción especial de almuerzo',
          location: 'Centro',
          distance: '1.8km',
          audioDuration: '30s',
          budget: '\$1500.00',
          urgencyMessage: null,
        ),
        const SizedBox(height: 12),
        const _CampaignCard(
          title: 'Cafetería Nueva',
          description: 'Apertura de nueva sucursal',
          location: 'Villa Morra',
          distance: '3.2km',
          audioDuration: '50s',
          budget: '\$1800.00',
          urgencyMessage: 'Cierra en 5 h',
        ),
        const SizedBox(height: 12),
        const _CampaignCard(
          title: 'Supermercado Ofertas',
          description: 'Ofertas de fin de semana',
          location: 'San Lorenzo',
          distance: '4.1km',
          audioDuration: '40s',
          budget: '\$2200.00',
          urgencyMessage: null,
        ),
      ],
    );
  }
}

class _MapSection extends StatelessWidget {
  const _MapSection();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_on_outlined,
                     color: AppColors.activeCampaignColor,
                     size: 20),
                const SizedBox(width: 8),
                Text(
                  'Ver en mapa',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              height: 180,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 60,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Map Location in real time',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CampaignCard extends StatelessWidget {
  final String title;
  final String description;
  final String location;
  final String distance;
  final String audioDuration;
  final String budget;
  final String? urgencyMessage;

  const _CampaignCard({
    required this.title,
    required this.description,
    required this.location,
    required this.distance,
    required this.audioDuration,
    required this.budget,
    this.urgencyMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and location
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 2),
                    Text(
                      location,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Campaign details
            Row(
              children: [
                Expanded(
                  child: _DetailItem(
                    value: distance,
                    label: 'Ruta',
                  ),
                ),
                Expanded(
                  child: _DetailItem(
                    value: audioDuration,
                    label: 'Audio',
                  ),
                ),
                Expanded(
                  child: _DetailItem(
                    value: budget,
                    label: 'Presupuesto',
                  ),
                ),
              ],
            ),

            // Urgency message
            if (urgencyMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                urgencyMessage!,
                style: TextStyle(
                  color: AppColors.deepOrange,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Action button
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.activeCampaignColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Aceptar campaña: $title (WIP)')),
                  );
                },
                child: const Text(
                  'Aceptar campaña',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  final String value;
  final String label;

  const _DetailItem({
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
