import 'package:drift/drift.dart';

import '../../../core/models/campaign.dart' as model;
import '../../repositories/campaign_repository.dart';
import 'db/database.dart';

class CampaignLocalDataSourceImpl implements CampaignLocalDataSource {
  final AppDatabase db;

  CampaignLocalDataSourceImpl(this.db);

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
            isActive: Value(campaign.isActive),
          ),
          onConflict: DoUpdate(
            (_) => CampaignsCompanion(
              title: Value(campaign.title),
              description: Value(campaign.description),
              advertiserId: Value(campaign.advertiserId),
              startDate: Value(campaign.startDate),
              endDate: Value(campaign.endDate),
              isActive: Value(campaign.isActive),
            ),
          ),
        );
      }
    });
  }

  @override
  Future<List<model.Campaign>> getCampaigns() async {
    final campaignRows = await db.select(db.campaigns).get();
    return campaignRows.map((row) => model.Campaign(
      id: row.id,
      title: row.title,
      description: row.description,
      advertiserId: row.advertiserId,
      startDate: row.startDate,
      endDate: row.endDate,
      isActive: row.isActive,
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
        isActive: Value(campaign.isActive),
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
      isActive: campaignRow.isActive,
    );
  }

  @override
  Future<void> deleteCampaign(String id) async {
    await (db.delete(db.campaigns)
      ..where((tbl) => tbl.id.equals(id)))
      .go();
  }
}