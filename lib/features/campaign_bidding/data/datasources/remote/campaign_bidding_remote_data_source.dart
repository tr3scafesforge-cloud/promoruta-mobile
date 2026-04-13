import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:promoruta/core/models/campaign.dart';
import 'package:promoruta/core/models/campaign_bid.dart';
import 'package:promoruta/core/models/payment_info.dart';
import 'package:promoruta/core/utils/logger.dart';
import 'package:promoruta/features/campaign_bidding/domain/repositories/campaign_bidding_repository.dart';

class CampaignBiddingRemoteDataSourceImpl
    implements CampaignBiddingRemoteDataSource {
  final Dio dio;

  CampaignBiddingRemoteDataSourceImpl({required this.dio});

  @override
  Future<CampaignBidsSummary> getCampaignBids(String campaignId) async {
    try {
      final response = await dio.get(
        '/campaigns/$campaignId/bids',
        options: Options(headers: {'Accept': 'application/json'}),
      );

      if (response.statusCode == 200) {
        final data = _normalizeMap(response.data);
        return CampaignBidsSummary.fromJson(data);
      }
      throw Exception('Failed to fetch bids: ${response.statusMessage}');
    } catch (e) {
      AppLogger.auth.e('Error fetching bids: $e');
      rethrow;
    }
  }

  @override
  Future<CampaignBid> createBid({
    required String campaignId,
    required double proposedPrice,
    String? message,
  }) async {
    try {
      final response = await dio.post(
        '/campaigns/$campaignId/bids',
        data: {
          'proposed_price': proposedPrice,
          if (message != null && message.trim().isNotEmpty)
            'message': message.trim(),
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = _normalizeMap(response.data);
        return CampaignBid.fromJson(_extractBid(data));
      }
      throw Exception('Failed to create bid: ${response.statusMessage}');
    } catch (e) {
      AppLogger.auth.e('Error creating bid: $e');
      rethrow;
    }
  }

  @override
  Future<CampaignBid> updateBid({
    required String campaignId,
    required String bidId,
    required double proposedPrice,
    String? message,
  }) async {
    try {
      final response = await dio.put(
        '/campaigns/$campaignId/bids/$bidId',
        data: {
          'proposed_price': proposedPrice,
          if (message != null && message.trim().isNotEmpty)
            'message': message.trim(),
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = _normalizeMap(response.data);
        return CampaignBid.fromJson(_extractBid(data));
      }
      throw Exception('Failed to update bid: ${response.statusMessage}');
    } catch (e) {
      AppLogger.auth.e('Error updating bid: $e');
      rethrow;
    }
  }

  @override
  Future<CampaignBid> withdrawBid({
    required String campaignId,
    required String bidId,
  }) async {
    try {
      final response = await dio.post(
        '/campaigns/$campaignId/bids/$bidId/withdraw',
        options: Options(headers: {'Accept': 'application/json'}),
      );

      if (response.statusCode == 200) {
        final data = _normalizeMap(response.data);
        return CampaignBid.fromJson(_extractBid(data));
      }
      throw Exception('Failed to withdraw bid: ${response.statusMessage}');
    } catch (e) {
      AppLogger.auth.e('Error withdrawing bid: $e');
      rethrow;
    }
  }

  @override
  Future<PaymentInfo> acceptBid({
    required String campaignId,
    required String bidId,
  }) async {
    try {
      final response = await dio.post(
        '/campaigns/$campaignId/accept-bid',
        data: {'bid_id': bidId},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = _normalizeMap(response.data);
        return _extractPaymentInfo(data);
      }
      throw Exception('Failed to accept bid: ${response.statusMessage}');
    } catch (e) {
      AppLogger.auth.e('Error accepting bid: $e');
      rethrow;
    }
  }

  @override
  Future<PaymentInfo> confirmPayment({
    required String campaignId,
    String? gatewayId,
  }) async {
    try {
      final response = await dio.post(
        '/campaigns/$campaignId/confirm-payment',
        data: {
          if (gatewayId != null && gatewayId.trim().isNotEmpty)
            'gateway_id': gatewayId.trim(),
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = _normalizeMap(response.data);
        return _extractPaymentInfo(data);
      }
      throw Exception('Failed to confirm payment: ${response.statusMessage}');
    } catch (e) {
      AppLogger.auth.e('Error confirming payment: $e');
      rethrow;
    }
  }

  @override
  Future<PaymentInfo> retryPaymentCheckout(String campaignId) async {
    try {
      final response = await dio.post(
        '/campaigns/$campaignId/retry-payment-checkout',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = _normalizeMap(response.data);
        return _extractPaymentInfo(data);
      }
      throw Exception(
          'Failed to retry payment checkout: ${response.statusMessage}');
    } catch (e) {
      AppLogger.auth.e('Error retrying payment checkout: $e');
      rethrow;
    }
  }

  @override
  Future<Campaign> startCampaign(String campaignId) async {
    try {
      final response = await dio.post(
        '/campaigns/$campaignId/start',
        options: Options(headers: {'Accept': 'application/json'}),
      );

      if (response.statusCode == 200) {
        final data = _normalizeMap(response.data);
        final campaignJson = _extractCampaign(data);
        return Campaign.fromJson(campaignJson);
      }
      throw Exception('Failed to start campaign: ${response.statusMessage}');
    } catch (e) {
      AppLogger.auth.e('Error starting campaign: $e');
      rethrow;
    }
  }

  @override
  Future<Campaign> completeCampaign(String campaignId) async {
    try {
      final response = await dio.post(
        '/campaigns/$campaignId/complete',
        options: Options(headers: {'Accept': 'application/json'}),
      );

      if (response.statusCode == 200) {
        final data = _normalizeMap(response.data);
        final campaignJson = _extractCampaign(data);
        return Campaign.fromJson(campaignJson);
      }
      throw Exception('Failed to complete campaign: ${response.statusMessage}');
    } catch (e) {
      AppLogger.auth.e('Error completing campaign: $e');
      rethrow;
    }
  }

  Map<String, dynamic> _normalizeMap(dynamic data) {
    if (data is String) {
      return jsonDecode(data) as Map<String, dynamic>;
    }
    if (data is Map<String, dynamic>) {
      return data;
    }
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    return <String, dynamic>{};
  }

  Map<String, dynamic> _extractCampaign(Map<String, dynamic> data) {
    if (data['campaign'] is Map<String, dynamic>) {
      return data['campaign'] as Map<String, dynamic>;
    }
    if (data['data'] is Map<String, dynamic>) {
      return data['data'] as Map<String, dynamic>;
    }
    return data;
  }

  Map<String, dynamic> _extractBid(Map<String, dynamic> data) {
    if (data['bid'] is Map<String, dynamic>) {
      return data['bid'] as Map<String, dynamic>;
    }
    if (data['data'] is Map<String, dynamic>) {
      return data['data'] as Map<String, dynamic>;
    }
    return data;
  }

  PaymentInfo _extractPaymentInfo(Map<String, dynamic> data) {
    final paymentData = <String, dynamic>{};

    // Get payment status from nested payment object
    if (data['payment'] is Map<String, dynamic>) {
      paymentData.addAll(data['payment'] as Map<String, dynamic>);
    } else if (data['data'] is Map<String, dynamic>) {
      paymentData.addAll(data['data'] as Map<String, dynamic>);
    }

    // Get checkout_url and preference_id from root level (backend returns these at root)
    if (data['checkout_url'] != null) {
      paymentData['checkout_url'] = data['checkout_url'];
    }
    if (data['preference_id'] != null) {
      paymentData['preference_id'] = data['preference_id'];
    }

    if (paymentData.isEmpty) {
      return PaymentInfo.fromJson(data);
    }

    return PaymentInfo.fromJson(paymentData);
  }
}
