import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:promoruta/core/constants/colors.dart';
import 'package:promoruta/core/models/campaign.dart';
import 'package:promoruta/features/advertiser/campaign_management/domain/use_cases/campaign_use_cases.dart';
import 'package:promoruta/gen/l10n/app_localizations.dart';
import 'package:promoruta/shared/shared.dart';

// Provider for nearby campaigns (first 15)
final nearbyCampaignsProvider = FutureProvider.autoDispose<List<Campaign>>((ref) async {
  final getCampaignsUseCase = ref.watch(getCampaignsUseCaseProvider);
  return await getCampaignsUseCase(const GetCampaignsParams(perPage: 15));
});

class PromoterNearbyPage extends ConsumerStatefulWidget {
  const PromoterNearbyPage({super.key});

  @override
  ConsumerState<PromoterNearbyPage> createState() => _PromoterNearbyPageState();
}

class _PromoterNearbyPageState extends ConsumerState<PromoterNearbyPage> {
  int _selectedTabIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final campaignsAsync = ref.watch(nearbyCampaignsProvider);

    return campaignsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 60, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text(
                'Error loading campaigns: $error',
                style: TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
      data: (campaigns) {
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          children: [
            // Search bar
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: l10n.searchCampaigns,
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
              options: [
                l10n.campaignFilterAll,
                l10n.campaignFilterUrgent,
                l10n.campaignFilterNearby,
                l10n.campaignFilterBestPaid,
              ],
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
                  l10n.availableCampaignsCount(campaigns.length),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Campaign cards or empty state
            if (campaigns.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      Icon(Icons.campaign_outlined, size: 60, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        l10n.noCampaignsFound,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...campaigns.asMap().entries.map((entry) {
                final campaign = entry.value;
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: entry.key < campaigns.length - 1 ? 12 : 0,
                  ),
                  child: _CampaignCard(campaign: campaign),
                );
              }),
          ],
        );
      },
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
  final Campaign campaign;

  const _CampaignCard({
    required this.campaign,
  });

  @override
  Widget build(BuildContext context) {
    // Check if campaign is urgent (bid deadline is within 3 hours)
    final now = DateTime.now();
    final timeUntilDeadline = campaign.bidDeadline.difference(now);
    final isUrgent = timeUntilDeadline.inHours < 3 && timeUntilDeadline.inHours >= 0;
    final urgencyMessage = isUrgent
        ? 'Cierra en ${timeUntilDeadline.inHours} h'
        : null;

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
            Text(
              campaign.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              campaign.description ?? '',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(width: 8),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 2),
                Text(
                  campaign.zone,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Campaign details
            Row(
              children: [
                Expanded(
                  child: _DetailItem(
                    value: '${campaign.distance.toStringAsFixed(1)}km',
                    label: 'Ruta',
                  ),
                ),
                Expanded(
                  child: _DetailItem(
                    value: '${campaign.audioDuration}s',
                    label: 'Audio',
                  ),
                ),
                Expanded(
                  child: _DetailItem(
                    value: '\$${campaign.suggestedPrice.toStringAsFixed(2)}',
                    label: 'Presupuesto',
                  ),
                ),
              ],
            ),

            // Urgency message
            if (urgencyMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                urgencyMessage,
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
                    SnackBar(content: Text('Aceptar campaña: ${campaign.title} (WIP)')),
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
