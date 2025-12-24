import 'package:promoruta/core/models/promoter_kpi_stats.dart';

/// Abstract repository for promoter operations
abstract class PromoterRepository {
  Future<PromoterKpiStats> getKpiStats();
}
