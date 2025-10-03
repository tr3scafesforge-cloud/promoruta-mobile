import 'package:drift/drift.dart';
import 'package:promoruta/core/core.dart' as model;
import 'package:promoruta/shared/shared.dart';


// Mock data for offline scenarios
final _mockCampaigns = <model.Campaign>[
  model.Campaign(
    id: '1',
    title: 'Promoción Agua',
    description: 'Campaña de promoción de agua mineral',
    advertiserId: 'advertiser_1',
    startDate: DateTime(2025, 1, 1, 10, 50),
    endDate: DateTime(2025, 1, 2, 10, 50),
    status: model.CampaignStatus.completed,
  ),
  model.Campaign(
    id: '2',
    title: 'Promoción Agua II',
    description: 'Segunda campaña de promoción de agua mineral',
    advertiserId: 'advertiser_1',
    startDate: DateTime(2025, 1, 1, 14, 50),
    endDate: DateTime(2025, 1, 2, 14, 50),
    status: model.CampaignStatus.canceled,
  ),
  model.Campaign(
    id: '3',
    title: 'Promoción Agua III',
    description: 'Tercera campaña de promoción de agua mineral',
    advertiserId: 'advertiser_1',
    startDate: DateTime(2025, 1, 1, 9, 50),
    endDate: DateTime(2025, 1, 2, 9, 50),
    status: model.CampaignStatus.expired,
  ),
];

class CampaignLocalDataSourceImpl implements CampaignLocalDataSource {
  final AppDatabase db;

  CampaignLocalDataSourceImpl(this.db);

  model.CampaignStatus _parseStatus(String statusString) {
    switch (statusString) {
      case 'active':
        return model.CampaignStatus.active;
      case 'pending':
        return model.CampaignStatus.pending;
      case 'completed':
        return model.CampaignStatus.completed;
      case 'canceled':
        return model.CampaignStatus.canceled;
      case 'expired':
        return model.CampaignStatus.expired;
      default:
        return model.CampaignStatus.active;
    }
  }

  @override
  Future<void> saveCampaigns(List<model.Campaign> campaigns) async {
    await db.batch((batch) {
      for (final campaign in campaigns) {
        batch.insert(
          db.campaigns,
          CampaignsCompanion(
            id: Value(campaign.id),
            title: Value(campaign.title),
            description: Value(campaign.description),
            advertiserId: Value(campaign.advertiserId),
            startDate: Value(campaign.startDate),
            endDate: Value(campaign.endDate),
            status: Value(campaign.status.name),
          ),
          onConflict: DoUpdate(
            (_) => CampaignsCompanion(
              title: Value(campaign.title),
              description: Value(campaign.description),
              advertiserId: Value(campaign.advertiserId),
              startDate: Value(campaign.startDate),
              endDate: Value(campaign.endDate),
              status: Value(campaign.status.name),
            ),
          ),
        );
      }
    });
  }

  @override
  Future<List<model.Campaign>> getCampaigns() async {
    final campaignRows = await db.select(db.campaigns).get();

    // If no data in database, return mock data for offline scenarios
    if (campaignRows.isEmpty) {
      // Save mock data to database for future use
      await saveCampaigns(_mockCampaigns);
      return _mockCampaigns;
    }

    return campaignRows.map((row) => model.Campaign(
      id: row.id,
      title: row.title,
      description: row.description,
      advertiserId: row.advertiserId,
      startDate: row.startDate,
      endDate: row.endDate,
      status: _parseStatus(row.status),
    )).toList();
  }

  @override
  Future<void> saveCampaign(model.Campaign campaign) async {
    await db.into(db.campaigns).insertOnConflictUpdate(
      CampaignsCompanion(
        id: Value(campaign.id),
        title: Value(campaign.title),
        description: Value(campaign.description),
        advertiserId: Value(campaign.advertiserId),
        startDate: Value(campaign.startDate),
        endDate: Value(campaign.endDate),
        status: Value(campaign.status.name),
      ),
    );
  }

  @override
  Future<model.Campaign?> getCampaign(String id) async {
    final campaignRow = await (db.select(db.campaigns)
      ..where((tbl) => tbl.id.equals(id)))
      .getSingleOrNull();

    if (campaignRow == null) return null;

    return model.Campaign(
      id: campaignRow.id,
      title: campaignRow.title,
      description: campaignRow.description,
      advertiserId: campaignRow.advertiserId,
      startDate: campaignRow.startDate,
      endDate: campaignRow.endDate,
      status: _parseStatus(campaignRow.status),
    );
  }

  @override
  Future<void> deleteCampaign(String id) async {
    await (db.delete(db.campaigns)
      ..where((tbl) => tbl.id.equals(id)))
      .go();
  }
}