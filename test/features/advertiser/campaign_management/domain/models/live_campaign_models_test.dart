import 'package:flutter_test/flutter_test.dart';
import 'package:promoruta/features/advertiser/campaign_management/domain/models/live_campaign_models.dart';

void main() {
  group('LivePromoterLocation', () {
    group('constructor', () {
      test('should create instance with all required fields', () {
        final now = DateTime.now();
        final location = LivePromoterLocation(
          campaignId: 'campaign-1',
          promoterId: 'promoter-1',
          promoterName: 'John Doe',
          latitude: -34.9011,
          longitude: -56.1645,
          lastUpdate: now,
          distanceTraveled: 5.2,
          elapsedTime: const Duration(minutes: 45),
          status: PromoterExecutionStatus.active,
          signalStrength: 4,
        );

        expect(location.campaignId, equals('campaign-1'));
        expect(location.promoterId, equals('promoter-1'));
        expect(location.promoterName, equals('John Doe'));
        expect(location.latitude, equals(-34.9011));
        expect(location.longitude, equals(-56.1645));
        expect(location.lastUpdate, equals(now));
        expect(location.distanceTraveled, equals(5.2));
        expect(location.elapsedTime, equals(const Duration(minutes: 45)));
        expect(location.status, equals(PromoterExecutionStatus.active));
        expect(location.signalStrength, equals(4));
      });
    });

    group('isStale', () {
      test('should return false when location is recent (< 2 min)', () {
        final location = LivePromoterLocation(
          campaignId: 'campaign-1',
          promoterId: 'promoter-1',
          promoterName: 'John',
          latitude: 0,
          longitude: 0,
          lastUpdate: DateTime.now().subtract(const Duration(minutes: 1)),
          distanceTraveled: 0,
          elapsedTime: Duration.zero,
          status: PromoterExecutionStatus.active,
          signalStrength: 4,
        );

        expect(location.isStale, isFalse);
      });

      test('should return true when location is stale (>= 2 min)', () {
        final location = LivePromoterLocation(
          campaignId: 'campaign-1',
          promoterId: 'promoter-1',
          promoterName: 'John',
          latitude: 0,
          longitude: 0,
          lastUpdate: DateTime.now().subtract(const Duration(minutes: 3)),
          distanceTraveled: 0,
          elapsedTime: Duration.zero,
          status: PromoterExecutionStatus.active,
          signalStrength: 2,
        );

        expect(location.isStale, isTrue);
      });
    });

    group('hasNoSignal', () {
      test('should return false when signal is recent (< 5 min)', () {
        final location = LivePromoterLocation(
          campaignId: 'campaign-1',
          promoterId: 'promoter-1',
          promoterName: 'John',
          latitude: 0,
          longitude: 0,
          lastUpdate: DateTime.now().subtract(const Duration(minutes: 3)),
          distanceTraveled: 0,
          elapsedTime: Duration.zero,
          status: PromoterExecutionStatus.active,
          signalStrength: 2,
        );

        expect(location.hasNoSignal, isFalse);
      });

      test('should return true when no signal (>= 5 min)', () {
        final location = LivePromoterLocation(
          campaignId: 'campaign-1',
          promoterId: 'promoter-1',
          promoterName: 'John',
          latitude: 0,
          longitude: 0,
          lastUpdate: DateTime.now().subtract(const Duration(minutes: 6)),
          distanceTraveled: 0,
          elapsedTime: Duration.zero,
          status: PromoterExecutionStatus.active,
          signalStrength: 0,
        );

        expect(location.hasNoSignal, isTrue);
      });
    });

    group('formattedElapsedTime', () {
      test('should format as HH:MM', () {
        final location = LivePromoterLocation(
          campaignId: 'campaign-1',
          promoterId: 'promoter-1',
          promoterName: 'John',
          latitude: 0,
          longitude: 0,
          lastUpdate: DateTime.now(),
          distanceTraveled: 0,
          elapsedTime: const Duration(hours: 1, minutes: 30),
          status: PromoterExecutionStatus.active,
          signalStrength: 4,
        );

        expect(location.formattedElapsedTime, equals('01:30'));
      });

      test('should pad with zeros', () {
        final location = LivePromoterLocation(
          campaignId: 'campaign-1',
          promoterId: 'promoter-1',
          promoterName: 'John',
          latitude: 0,
          longitude: 0,
          lastUpdate: DateTime.now(),
          distanceTraveled: 0,
          elapsedTime: const Duration(minutes: 5),
          status: PromoterExecutionStatus.active,
          signalStrength: 4,
        );

        expect(location.formattedElapsedTime, equals('00:05'));
      });
    });

    group('formattedDistance', () {
      test('should show meters for distances under 1 km', () {
        final location = LivePromoterLocation(
          campaignId: 'campaign-1',
          promoterId: 'promoter-1',
          promoterName: 'John',
          latitude: 0,
          longitude: 0,
          lastUpdate: DateTime.now(),
          distanceTraveled: 0.5,
          elapsedTime: Duration.zero,
          status: PromoterExecutionStatus.active,
          signalStrength: 4,
        );

        expect(location.formattedDistance, equals('500 m'));
      });

      test('should show kilometers for distances 1 km and above', () {
        final location = LivePromoterLocation(
          campaignId: 'campaign-1',
          promoterId: 'promoter-1',
          promoterName: 'John',
          latitude: 0,
          longitude: 0,
          lastUpdate: DateTime.now(),
          distanceTraveled: 5.25,
          elapsedTime: Duration.zero,
          status: PromoterExecutionStatus.active,
          signalStrength: 4,
        );

        expect(location.formattedDistance, equals('5.25 km'));
      });
    });

    group('copyWith', () {
      test('should copy with new values', () {
        final original = LivePromoterLocation(
          campaignId: 'campaign-1',
          promoterId: 'promoter-1',
          promoterName: 'John',
          latitude: 0,
          longitude: 0,
          lastUpdate: DateTime.now(),
          distanceTraveled: 0,
          elapsedTime: Duration.zero,
          status: PromoterExecutionStatus.active,
          signalStrength: 4,
        );

        final copied = original.copyWith(
          status: PromoterExecutionStatus.paused,
          distanceTraveled: 10.0,
        );

        expect(copied.status, equals(PromoterExecutionStatus.paused));
        expect(copied.distanceTraveled, equals(10.0));
        expect(copied.campaignId, equals('campaign-1'));
        expect(copied.promoterName, equals('John'));
      });
    });

    group('fromJson', () {
      test('should parse from JSON correctly', () {
        final json = {
          'campaign_id': 'campaign-1',
          'id': 'promoter-1',
          'name': 'John Doe',
          'location': {
            'lat': -34.9011,
            'lng': -56.1645,
            'updated_at': '2024-01-15T10:30:00Z',
          },
          'execution': {
            'status': 'active',
            'distance_km': 5.2,
            'elapsed_minutes': 45,
            'started_at': '2024-01-15T09:45:00Z',
          },
        };

        final location = LivePromoterLocation.fromJson(json);

        expect(location.campaignId, equals('campaign-1'));
        expect(location.promoterId, equals('promoter-1'));
        expect(location.promoterName, equals('John Doe'));
        expect(location.latitude, equals(-34.9011));
        expect(location.longitude, equals(-56.1645));
        expect(location.distanceTraveled, equals(5.2));
        expect(location.elapsedTime, equals(const Duration(minutes: 45)));
        expect(location.status, equals(PromoterExecutionStatus.active));
      });
    });
  });

  group('LiveCampaign', () {
    group('hasActivePromoter', () {
      test('should return true when promoter is active', () {
        final campaign = LiveCampaign(
          id: 'campaign-1',
          title: 'Test Campaign',
          zone: 'Zone A',
          promoter: LivePromoterLocation(
            campaignId: 'campaign-1',
            promoterId: 'promoter-1',
            promoterName: 'John',
            latitude: 0,
            longitude: 0,
            lastUpdate: DateTime.now(),
            distanceTraveled: 0,
            elapsedTime: Duration.zero,
            status: PromoterExecutionStatus.active,
            signalStrength: 4,
          ),
        );

        expect(campaign.hasActivePromoter, isTrue);
      });

      test('should return false when promoter is paused', () {
        final campaign = LiveCampaign(
          id: 'campaign-1',
          title: 'Test Campaign',
          zone: 'Zone A',
          promoter: LivePromoterLocation(
            campaignId: 'campaign-1',
            promoterId: 'promoter-1',
            promoterName: 'John',
            latitude: 0,
            longitude: 0,
            lastUpdate: DateTime.now(),
            distanceTraveled: 0,
            elapsedTime: Duration.zero,
            status: PromoterExecutionStatus.paused,
            signalStrength: 4,
          ),
        );

        expect(campaign.hasActivePromoter, isFalse);
      });

      test('should return false when no promoter', () {
        const campaign = LiveCampaign(
          id: 'campaign-1',
          title: 'Test Campaign',
          zone: 'Zone A',
        );

        expect(campaign.hasActivePromoter, isFalse);
      });
    });

    group('promoterHasNoSignal', () {
      test('should return true when no promoter', () {
        const campaign = LiveCampaign(
          id: 'campaign-1',
          title: 'Test Campaign',
          zone: 'Zone A',
        );

        expect(campaign.promoterHasNoSignal, isTrue);
      });

      test('should return false when promoter has signal', () {
        final campaign = LiveCampaign(
          id: 'campaign-1',
          title: 'Test Campaign',
          zone: 'Zone A',
          promoter: LivePromoterLocation(
            campaignId: 'campaign-1',
            promoterId: 'promoter-1',
            promoterName: 'John',
            latitude: 0,
            longitude: 0,
            lastUpdate: DateTime.now(),
            distanceTraveled: 0,
            elapsedTime: Duration.zero,
            status: PromoterExecutionStatus.active,
            signalStrength: 4,
          ),
        );

        expect(campaign.promoterHasNoSignal, isFalse);
      });
    });
  });

  group('CampaignAlert', () {
    group('timeAgo', () {
      test('should return "Just now" for < 1 min', () {
        final alert = CampaignAlert(
          id: 'alert-1',
          campaignId: 'campaign-1',
          campaignTitle: 'Test',
          type: CampaignAlertType.started,
          message: 'Started',
          createdAt: DateTime.now(),
        );

        expect(alert.timeAgo, equals('Just now'));
      });

      test('should return minutes for < 60 min', () {
        final alert = CampaignAlert(
          id: 'alert-1',
          campaignId: 'campaign-1',
          campaignTitle: 'Test',
          type: CampaignAlertType.started,
          message: 'Started',
          createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
        );

        expect(alert.timeAgo, equals('30 min ago'));
      });

      test('should return hours for < 24 hours', () {
        final alert = CampaignAlert(
          id: 'alert-1',
          campaignId: 'campaign-1',
          campaignTitle: 'Test',
          type: CampaignAlertType.started,
          message: 'Started',
          createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        );

        expect(alert.timeAgo, equals('5h ago'));
      });

      test('should return days for >= 24 hours', () {
        final alert = CampaignAlert(
          id: 'alert-1',
          campaignId: 'campaign-1',
          campaignTitle: 'Test',
          type: CampaignAlertType.started,
          message: 'Started',
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
        );

        expect(alert.timeAgo, equals('2d ago'));
      });
    });

    group('copyWith', () {
      test('should copy with isRead', () {
        final alert = CampaignAlert(
          id: 'alert-1',
          campaignId: 'campaign-1',
          campaignTitle: 'Test',
          type: CampaignAlertType.started,
          message: 'Started',
          createdAt: DateTime.now(),
          isRead: false,
        );

        final copied = alert.copyWith(isRead: true);

        expect(copied.isRead, isTrue);
        expect(copied.id, equals('alert-1'));
      });
    });
  });

  group('AdvertiserLiveState', () {
    group('filteredCampaigns', () {
      final activeCampaign = LiveCampaign(
        id: 'active-1',
        title: 'Active Campaign',
        zone: 'Zone A',
        promoter: LivePromoterLocation(
          campaignId: 'active-1',
          promoterId: 'promoter-1',
          promoterName: 'John',
          latitude: 0,
          longitude: 0,
          lastUpdate: DateTime.now(),
          distanceTraveled: 0,
          elapsedTime: Duration.zero,
          status: PromoterExecutionStatus.active,
          signalStrength: 4,
        ),
      );

      final pausedCampaign = LiveCampaign(
        id: 'paused-1',
        title: 'Paused Campaign',
        zone: 'Zone B',
        promoter: LivePromoterLocation(
          campaignId: 'paused-1',
          promoterId: 'promoter-2',
          promoterName: 'Jane',
          latitude: 0,
          longitude: 0,
          lastUpdate: DateTime.now(),
          distanceTraveled: 0,
          elapsedTime: Duration.zero,
          status: PromoterExecutionStatus.paused,
          signalStrength: 3,
        ),
      );

      const pendingCampaign = LiveCampaign(
        id: 'pending-1',
        title: 'Pending Campaign',
        zone: 'Zone C',
      );

      final noSignalCampaign = LiveCampaign(
        id: 'nosignal-1',
        title: 'No Signal Campaign',
        zone: 'Zone D',
        promoter: LivePromoterLocation(
          campaignId: 'nosignal-1',
          promoterId: 'promoter-3',
          promoterName: 'Bob',
          latitude: 0,
          longitude: 0,
          lastUpdate: DateTime.now().subtract(const Duration(minutes: 10)),
          distanceTraveled: 0,
          elapsedTime: Duration.zero,
          status: PromoterExecutionStatus.active,
          signalStrength: 0,
        ),
      );

      test('should return all campaigns for filter all', () {
        final state = AdvertiserLiveState(
          campaigns: [activeCampaign, pausedCampaign, pendingCampaign],
          filter: LiveCampaignFilter.all,
        );

        expect(state.filteredCampaigns.length, equals(3));
      });

      test('should return only active/paused for filter active', () {
        final state = AdvertiserLiveState(
          campaigns: [activeCampaign, pausedCampaign, pendingCampaign],
          filter: LiveCampaignFilter.active,
        );

        expect(state.filteredCampaigns.length, equals(2));
        expect(state.filteredCampaigns, contains(activeCampaign));
        expect(state.filteredCampaigns, contains(pausedCampaign));
      });

      test('should return only pending for filter pending', () {
        final state = AdvertiserLiveState(
          campaigns: [activeCampaign, pausedCampaign, pendingCampaign],
          filter: LiveCampaignFilter.pending,
        );

        expect(state.filteredCampaigns.length, equals(1));
        expect(state.filteredCampaigns.first.id, equals('pending-1'));
      });

      test('should return only no signal for filter noSignal', () {
        final state = AdvertiserLiveState(
          campaigns: [activeCampaign, noSignalCampaign, pendingCampaign],
          filter: LiveCampaignFilter.noSignal,
        );

        // Both noSignalCampaign and pendingCampaign have no signal
        expect(state.filteredCampaigns.length, equals(2));
      });
    });

    group('selectedCampaign', () {
      test('should return null when no campaign selected', () {
        const state = AdvertiserLiveState(
          campaigns: [],
        );

        expect(state.selectedCampaign, isNull);
      });

      test('should return campaign when selected', () {
        final campaign = LiveCampaign(
          id: 'campaign-1',
          title: 'Test',
          zone: 'Zone A',
        );

        final state = AdvertiserLiveState(
          campaigns: [campaign],
          selectedCampaignId: 'campaign-1',
        );

        expect(state.selectedCampaign, equals(campaign));
      });
    });

    group('hasActiveCampaigns', () {
      test('should return false when no active campaigns', () {
        const state = AdvertiserLiveState(
          campaigns: [
            LiveCampaign(id: '1', title: 'Test', zone: 'A'),
          ],
        );

        expect(state.hasActiveCampaigns, isFalse);
      });

      test('should return true when has active promoter', () {
        final state = AdvertiserLiveState(
          campaigns: [
            LiveCampaign(
              id: '1',
              title: 'Test',
              zone: 'A',
              promoter: LivePromoterLocation(
                campaignId: '1',
                promoterId: 'p1',
                promoterName: 'John',
                latitude: 0,
                longitude: 0,
                lastUpdate: DateTime.now(),
                distanceTraveled: 0,
                elapsedTime: Duration.zero,
                status: PromoterExecutionStatus.active,
                signalStrength: 4,
              ),
            ),
          ],
        );

        expect(state.hasActiveCampaigns, isTrue);
      });
    });

    group('copyWith', () {
      test('should copy with new values', () {
        const original = AdvertiserLiveState(
          isLoading: false,
          filter: LiveCampaignFilter.all,
        );

        final copied = original.copyWith(
          isLoading: true,
          filter: LiveCampaignFilter.active,
        );

        expect(copied.isLoading, isTrue);
        expect(copied.filter, equals(LiveCampaignFilter.active));
      });

      test('clearSelectedCampaign should clear selection', () {
        const original = AdvertiserLiveState(
          selectedCampaignId: 'campaign-1',
        );

        final copied = original.copyWith(clearSelectedCampaign: true);

        expect(copied.selectedCampaignId, isNull);
      });

      test('clearError should clear error', () {
        const original = AdvertiserLiveState(
          error: 'Some error',
        );

        final copied = original.copyWith(clearError: true);

        expect(copied.error, isNull);
      });
    });
  });

  group('PromoterExecutionStatus', () {
    test('should have all required statuses', () {
      expect(PromoterExecutionStatus.values,
          contains(PromoterExecutionStatus.active));
      expect(PromoterExecutionStatus.values,
          contains(PromoterExecutionStatus.paused));
      expect(PromoterExecutionStatus.values,
          contains(PromoterExecutionStatus.completed));
      expect(PromoterExecutionStatus.values,
          contains(PromoterExecutionStatus.unknown));
    });
  });

  group('CampaignAlertType', () {
    test('should have all required alert types', () {
      expect(CampaignAlertType.values, contains(CampaignAlertType.started));
      expect(CampaignAlertType.values, contains(CampaignAlertType.paused));
      expect(CampaignAlertType.values, contains(CampaignAlertType.resumed));
      expect(CampaignAlertType.values, contains(CampaignAlertType.completed));
      expect(CampaignAlertType.values, contains(CampaignAlertType.noSignal));
      expect(CampaignAlertType.values, contains(CampaignAlertType.outOfZone));
    });
  });

  group('LiveCampaignFilter', () {
    test('should have all required filters', () {
      expect(LiveCampaignFilter.values, contains(LiveCampaignFilter.all));
      expect(LiveCampaignFilter.values, contains(LiveCampaignFilter.active));
      expect(LiveCampaignFilter.values, contains(LiveCampaignFilter.pending));
      expect(LiveCampaignFilter.values, contains(LiveCampaignFilter.noSignal));
    });
  });

  group('RoutePoint', () {
    test('should create from constructor', () {
      const point = RoutePoint(lat: -34.9011, lng: -56.1645);
      expect(point.lat, equals(-34.9011));
      expect(point.lng, equals(-56.1645));
    });

    test('should serialize to JSON', () {
      const point = RoutePoint(lat: -34.9011, lng: -56.1645);
      final json = point.toJson();
      expect(json['lat'], equals(-34.9011));
      expect(json['lng'], equals(-56.1645));
    });

    test('should deserialize from JSON', () {
      final json = {'lat': -34.9011, 'lng': -56.1645};
      final point = RoutePoint.fromJson(json);
      expect(point.lat, equals(-34.9011));
      expect(point.lng, equals(-56.1645));
    });
  });
}
