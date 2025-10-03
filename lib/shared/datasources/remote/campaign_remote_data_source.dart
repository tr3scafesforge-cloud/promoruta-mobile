import 'package:dio/dio.dart';

import '../../../core/models/campaign.dart';
import '../../repositories/campaign_repository.dart';

class CampaignRemoteDataSourceImpl implements CampaignRemoteDataSource {
  final Dio dio;
  final String baseUrl;

  CampaignRemoteDataSourceImpl({
    required this.dio,
    this.baseUrl = 'https://api.promoruta.com', // Replace with actual API URL
  });

  CampaignStatus _parseStatus(String statusString) {
    switch (statusString.toLowerCase()) {
      case 'active':
        return CampaignStatus.active;
      case 'pending':
        return CampaignStatus.pending;
      case 'completed':
        return CampaignStatus.completed;
      case 'canceled':
        return CampaignStatus.canceled;
      case 'expired':
        return CampaignStatus.expired;
      default:
        return CampaignStatus.active;
    }
  }

  @override
  Future<List<Campaign>> getCampaigns() async {
    try {
      final response = await dio.get('$baseUrl/campaigns');

      if (response.statusCode == 200) {
        final data = response.data as List;
        return data.map((json) => Campaign(
          id: json['id'],
          title: json['title'],
          description: json['description'],
          advertiserId: json['advertiserId'],
          startDate: DateTime.parse(json['startDate']),
          endDate: DateTime.parse(json['endDate']),
          status: _parseStatus(json['status'] ?? 'active'),
        )).toList();
      } else {
        throw Exception('Failed to fetch campaigns: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  @override
  Future<Campaign> getCampaign(String id) async {
    try {
      final response = await dio.get('$baseUrl/campaigns/$id');

      if (response.statusCode == 200) {
        final json = response.data;
        return Campaign(
          id: json['id'],
          title: json['title'],
          description: json['description'],
          advertiserId: json['advertiserId'],
          startDate: DateTime.parse(json['startDate']),
          endDate: DateTime.parse(json['endDate']),
          status: _parseStatus(json['status'] ?? 'active'),
        );
      } else {
        throw Exception('Failed to fetch campaign: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  @override
  Future<Campaign> createCampaign(Campaign campaign) async {
    try {
      final response = await dio.post(
        '$baseUrl/campaigns',
        data: {
          'title': campaign.title,
          'description': campaign.description,
          'advertiserId': campaign.advertiserId,
          'startDate': campaign.startDate.toIso8601String(),
          'endDate': campaign.endDate.toIso8601String(),
          'status': campaign.status.name,
        },
      );

      if (response.statusCode == 201) {
        final json = response.data;
        return Campaign(
          id: json['id'],
          title: json['title'],
          description: json['description'],
          advertiserId: json['advertiserId'],
          startDate: DateTime.parse(json['startDate']),
          endDate: DateTime.parse(json['endDate']),
          status: _parseStatus(json['status'] ?? 'active'),
        );
      } else {
        throw Exception('Failed to create campaign: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  @override
  Future<Campaign> updateCampaign(Campaign campaign) async {
    try {
      final response = await dio.put(
        '$baseUrl/campaigns/${campaign.id}',
        data: {
          'title': campaign.title,
          'description': campaign.description,
          'advertiserId': campaign.advertiserId,
          'startDate': campaign.startDate.toIso8601String(),
          'endDate': campaign.endDate.toIso8601String(),
          'status': campaign.status.name,
        },
      );

      if (response.statusCode == 200) {
        final json = response.data;
        return Campaign(
          id: json['id'],
          title: json['title'],
          description: json['description'],
          advertiserId: json['advertiserId'],
          startDate: DateTime.parse(json['startDate']),
          endDate: DateTime.parse(json['endDate']),
          status: _parseStatus(json['status'] ?? 'active'),
        );
      } else {
        throw Exception('Failed to update campaign: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  @override
  Future<void> deleteCampaign(String id) async {
    try {
      final response = await dio.delete('$baseUrl/campaigns/$id');

      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception('Failed to delete campaign: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }
}