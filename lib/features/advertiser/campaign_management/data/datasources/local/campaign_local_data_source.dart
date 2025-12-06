import 'package:drift/drift.dart';
import 'package:promoruta/core/core.dart' as model;
import 'package:promoruta/shared/shared.dart';
import '../../../domain/repositories/campaign_repository.dart';


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
    zone: 'Norte',
    suggestedPrice: 150.0,
    bidDeadline: DateTime(2025, 1, 1, 8, 0),
    audioDuration: 30,
    distance: 10.5,
    routeCoordinates: [
      model.RouteCoordinate(lat: -12.0464, lng: -77.0428),
      model.RouteCoordinate(lat: -12.0500, lng: -77.0450),
    ],
    startTime: DateTime(2025, 1, 1, 10, 50),
    endTime: DateTime(2025, 1, 2, 10, 50),
  ),
  model.Campaign(
    id: '2',
    title: 'Promoción Agua II',
    description: 'Segunda campaña de promoción de agua mineral',
    advertiserId: 'advertiser_1',
    startDate: DateTime(2025, 1, 1, 14, 50),
    endDate: DateTime(2025, 1, 2, 14, 50),
    status: model.CampaignStatus.canceled,
    zone: 'Sur',
    suggestedPrice: 200.0,
    bidDeadline: DateTime(2025, 1, 1, 12, 0),
    audioDuration: 45,
    distance: 15.0,
    routeCoordinates: [
      model.RouteCoordinate(lat: -12.0600, lng: -77.0500),
      model.RouteCoordinate(lat: -12.0650, lng: -77.0550),
    ],
    startTime: DateTime(2025, 1, 1, 14, 50),
    endTime: DateTime(2025, 1, 2, 14, 50),
  ),
  model.Campaign(
    id: '3',
    title: 'Promoción Agua III',
    description: 'Tercera campaña de promoción de agua mineral',
    advertiserId: 'advertiser_1',
    startDate: DateTime(2025, 1, 1, 9, 50),
    endDate: DateTime(2025, 1, 2, 9, 50),
    status: model.CampaignStatus.expired,
    zone: 'Este',
    suggestedPrice: 100.0,
    bidDeadline: DateTime(2025, 1, 1, 7, 0),
    audioDuration: 20,
    distance: 8.0,
    routeCoordinates: [
      model.RouteCoordinate(lat: -12.0400, lng: -77.0300),
      model.RouteCoordinate(lat: -12.0420, lng: -77.0320),
    ],
    startTime: DateTime(2025, 1, 1, 9, 50),
    endTime: DateTime(2025, 1, 2, 9, 50),
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
        // Only save campaigns that have all required fields
        if (campaign.id == null ||
            campaign.advertiserId == null ||
            campaign.startDate == null ||
            campaign.endDate == null ||
            campaign.status == null) {
          continue;
        }

        batch.insert(
          db.campaignsEntity,
          CampaignsEntityCompanion(
            id: Value(campaign.id!),
            title: Value(campaign.title),
            description: Value(campaign.description ?? ''),
            advertiserId: Value(campaign.advertiserId!),
            startDate: Value(campaign.startDate!),
            endDate: Value(campaign.endDate!),
            status: Value(campaign.status!.name),
          ),
          onConflict: DoUpdate(
            (_) => CampaignsEntityCompanion(
              title: Value(campaign.title),
              description: Value(campaign.description ?? ''),
              advertiserId: Value(campaign.advertiserId!),
              startDate: Value(campaign.startDate!),
              endDate: Value(campaign.endDate!),
              status: Value(campaign.status!.name),
            ),
          ),
        );
      }
    });
  }

  @override
  Future<List<model.Campaign>> getCampaigns() async {
    final campaignRows = await db.select(db.campaignsEntity).get();

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
      // Use deprecated fields as fallback for required fields
      zone: 'Unknown',
      suggestedPrice: 0.0,
      bidDeadline: row.startDate,
      audioDuration: 30,
      distance: 0.0,
      routeCoordinates: [],
      startTime: row.startDate,
      endTime: row.endDate,
    )).toList();
  }

  @override
  Future<void> saveCampaign(model.Campaign campaign) async {
    // Only save campaigns that have all required fields
    if (campaign.id == null ||
        campaign.advertiserId == null ||
        campaign.startDate == null ||
        campaign.endDate == null ||
        campaign.status == null) {
      return;
    }

    await db.into(db.campaignsEntity).insertOnConflictUpdate(
      CampaignsEntityCompanion(
        id: Value(campaign.id!),
        title: Value(campaign.title),
        description: Value(campaign.description ?? ''),
        advertiserId: Value(campaign.advertiserId!),
        startDate: Value(campaign.startDate!),
        endDate: Value(campaign.endDate!),
        status: Value(campaign.status!.name),
      ),
    );
  }

  @override
  Future<model.Campaign?> getCampaign(String id) async {
    final campaignRow = await (db.select(db.campaignsEntity)
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
      // Use deprecated fields as fallback for required fields
      zone: 'Unknown',
      suggestedPrice: 0.0,
      bidDeadline: campaignRow.startDate,
      audioDuration: 30,
      distance: 0.0,
      routeCoordinates: [],
      startTime: campaignRow.startDate,
      endTime: campaignRow.endDate,
    );
  }

  @override
  Future<void> deleteCampaign(String id) async {
    await (db.delete(db.campaignsEntity)
      ..where((tbl) => tbl.id.equals(id)))
      .go();
  }

  @override
  Future<void> clearCampaigns() async {
    await db.delete(db.campaignsEntity).go();
  }
}