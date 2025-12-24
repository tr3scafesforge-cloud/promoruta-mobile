import 'package:dio/dio.dart';
import 'package:promoruta/core/utils/logger.dart';
import 'package:promoruta/core/models/promoter_kpi_stats.dart';

abstract class PromoterRemoteDataSource {
  Future<PromoterKpiStats> getKpiStats();
}

class PromoterRemoteDataSourceImpl implements PromoterRemoteDataSource {
  final Dio dio;

  PromoterRemoteDataSourceImpl({
    required this.dio,
  });

  @override
  Future<PromoterKpiStats> getKpiStats() async {
    try {
      AppLogger.auth.i('Fetching promoter KPI stats');

      final response = await dio.get(
        '/promoter/kpi-stats',
        options: Options(
          headers: {
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final json = response.data;
        AppLogger.auth.i('Promoter KPI stats fetched successfully');
        return PromoterKpiStats.fromJson(json);
      } else {
        throw Exception('Failed to fetch KPI stats: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      AppLogger.auth.e('Fetch promoter KPI stats failed: ${e.response?.statusCode} - ${e.message}');

      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        switch (statusCode) {
          case 403:
            throw Exception('Access denied. Only promoters can view KPI stats.');
          case 404:
            throw Exception('KPI stats endpoint not found.');
          default:
            throw Exception('Failed to fetch KPI stats.');
        }
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      AppLogger.auth.e('Unexpected error fetching promoter KPI stats: $e');
      throw Exception('Failed to fetch KPI stats: $e');
    }
  }
}
