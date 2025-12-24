import 'package:promoruta/core/models/promoter_kpi_stats.dart';
import 'package:promoruta/core/utils/logger.dart';
import 'package:promoruta/shared/shared.dart';
import '../../domain/repositories/promoter_repository.dart';
import '../datasources/remote/promoter_remote_data_source.dart';

class PromoterRepositoryImpl implements PromoterRepository {
  final PromoterRemoteDataSource _remoteDataSource;
  final ConnectivityService _connectivityService;

  PromoterRepositoryImpl(
    this._remoteDataSource,
    this._connectivityService,
  );

  @override
  Future<PromoterKpiStats> getKpiStats() async {
    final isConnected = await _connectivityService.isConnected;

    if (isConnected) {
      try {
        final kpiStats = await _remoteDataSource.getKpiStats();
        return kpiStats;
      } catch (e) {
        AppLogger.auth.e('Failed to fetch promoter KPI stats: $e');
        rethrow;
      }
    } else {
      throw Exception('No internet connection. KPI stats require online access.');
    }
  }
}
