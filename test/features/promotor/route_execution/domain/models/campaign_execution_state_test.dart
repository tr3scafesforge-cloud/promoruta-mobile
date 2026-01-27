import 'package:flutter_test/flutter_test.dart';

import 'package:promoruta/features/promotor/route_execution/domain/models/campaign_execution_state.dart';

void main() {
  group('CampaignExecutionState', () {
    group('Factory constructors', () {
      test('idle() should create idle state', () {
        final state = CampaignExecutionState.idle();

        expect(state.status, equals(CampaignExecutionStatus.idle));
        expect(state.campaignId, isNull);
        expect(state.campaignName, isNull);
        expect(state.pendingPoints, isEmpty);
        expect(state.allPoints, isEmpty);
        expect(state.startedAt, isNull);
        expect(state.pausedAt, isNull);
        expect(state.totalPausedDuration, equals(Duration.zero));
        expect(state.distanceTraveled, equals(0.0));
        expect(state.errorMessage, isNull);
        expect(state.currentPosition, isNull);
      });
    });

    group('hasActiveExecution', () {
      test('should return false for idle status', () {
        final state = CampaignExecutionState.idle();
        expect(state.hasActiveExecution, isFalse);
      });

      test('should return true for active status', () {
        const state = CampaignExecutionState(
          status: CampaignExecutionStatus.active,
          campaignId: 'campaign-1',
        );
        expect(state.hasActiveExecution, isTrue);
      });

      test('should return true for paused status', () {
        const state = CampaignExecutionState(
          status: CampaignExecutionStatus.paused,
          campaignId: 'campaign-1',
        );
        expect(state.hasActiveExecution, isTrue);
      });

      test('should return true for starting status', () {
        const state = CampaignExecutionState(
          status: CampaignExecutionStatus.starting,
          campaignId: 'campaign-1',
        );
        expect(state.hasActiveExecution, isTrue);
      });

      test('should return true for completing status', () {
        const state = CampaignExecutionState(
          status: CampaignExecutionStatus.completing,
          campaignId: 'campaign-1',
        );
        expect(state.hasActiveExecution, isTrue);
      });

      test('should return false for completed status', () {
        const state = CampaignExecutionState(
          status: CampaignExecutionStatus.completed,
          campaignId: 'campaign-1',
        );
        expect(state.hasActiveExecution, isFalse);
      });

      test('should return false for error status', () {
        const state = CampaignExecutionState(
          status: CampaignExecutionStatus.error,
          errorMessage: 'Some error',
        );
        expect(state.hasActiveExecution, isFalse);
      });
    });

    group('isTrackingActive', () {
      test('should return true only for active status', () {
        expect(
          const CampaignExecutionState(status: CampaignExecutionStatus.active)
              .isTrackingActive,
          isTrue,
        );

        expect(
          const CampaignExecutionState(status: CampaignExecutionStatus.idle)
              .isTrackingActive,
          isFalse,
        );

        expect(
          const CampaignExecutionState(status: CampaignExecutionStatus.paused)
              .isTrackingActive,
          isFalse,
        );

        expect(
          const CampaignExecutionState(status: CampaignExecutionStatus.starting)
              .isTrackingActive,
          isFalse,
        );
      });
    });

    group('elapsedTime', () {
      test('should return zero when not started', () {
        final state = CampaignExecutionState.idle();
        expect(state.elapsedTime, equals(Duration.zero));
      });

      test('should calculate elapsed time excluding paused duration', () {
        final startedAt = DateTime.now().subtract(const Duration(minutes: 30));
        const pausedDuration = Duration(minutes: 10);

        final state = CampaignExecutionState(
          status: CampaignExecutionStatus.active,
          startedAt: startedAt,
          totalPausedDuration: pausedDuration,
        );

        // Elapsed should be approximately 20 minutes (30 - 10 paused)
        expect(state.elapsedTime.inMinutes, closeTo(20, 1));
      });

      test('should include current pause in calculation when paused', () {
        final startedAt = DateTime.now().subtract(const Duration(minutes: 30));
        final pausedAt = DateTime.now().subtract(const Duration(minutes: 5));

        final state = CampaignExecutionState(
          status: CampaignExecutionStatus.paused,
          startedAt: startedAt,
          pausedAt: pausedAt,
          totalPausedDuration: Duration.zero,
        );

        // Elapsed should be approximately 25 minutes (30 - 5 current pause)
        expect(state.elapsedTime.inMinutes, closeTo(25, 1));
      });
    });

    group('formattedElapsedTime', () {
      test('should format as HH:MM:SS', () {
        final startedAt = DateTime.now().subtract(
          const Duration(hours: 1, minutes: 30, seconds: 45),
        );

        final state = CampaignExecutionState(
          status: CampaignExecutionStatus.active,
          startedAt: startedAt,
        );

        final formatted = state.formattedElapsedTime;

        // Format should be HH:MM:SS
        expect(formatted, matches(RegExp(r'^\d{2}:\d{2}:\d{2}$')));
        expect(formatted.substring(0, 2), equals('01')); // Hours
      });

      test('should pad with zeros', () {
        final startedAt = DateTime.now().subtract(
          const Duration(minutes: 5, seconds: 3),
        );

        final state = CampaignExecutionState(
          status: CampaignExecutionStatus.active,
          startedAt: startedAt,
        );

        final formatted = state.formattedElapsedTime;
        expect(formatted, equals('00:05:03'));
      });
    });

    group('formattedDistance', () {
      test('should show meters for distances under 1000m', () {
        const state = CampaignExecutionState(
          status: CampaignExecutionStatus.active,
          distanceTraveled: 500.0,
        );

        expect(state.formattedDistance, equals('500 m'));
      });

      test('should show kilometers for distances 1000m and above', () {
        const state = CampaignExecutionState(
          status: CampaignExecutionStatus.active,
          distanceTraveled: 1500.0,
        );

        expect(state.formattedDistance, equals('1.50 km'));
      });

      test('should show two decimal places for kilometers', () {
        const state = CampaignExecutionState(
          status: CampaignExecutionStatus.active,
          distanceTraveled: 2345.67,
        );

        expect(state.formattedDistance, equals('2.35 km'));
      });
    });

    group('distanceKm', () {
      test('should convert meters to kilometers', () {
        const state = CampaignExecutionState(
          status: CampaignExecutionStatus.active,
          distanceTraveled: 5000.0,
        );

        expect(state.distanceKm, equals(5.0));
      });
    });

    group('copyWith', () {
      test('should copy with new status', () {
        const original = CampaignExecutionState(
          status: CampaignExecutionStatus.idle,
        );

        final copied = original.copyWith(
          status: CampaignExecutionStatus.active,
        );

        expect(copied.status, equals(CampaignExecutionStatus.active));
      });

      test('should preserve values not specified', () {
        const original = CampaignExecutionState(
          status: CampaignExecutionStatus.active,
          campaignId: 'campaign-1',
          campaignName: 'Test Campaign',
          distanceTraveled: 100.0,
        );

        final copied = original.copyWith(
          distanceTraveled: 200.0,
        );

        expect(copied.status, equals(CampaignExecutionStatus.active));
        expect(copied.campaignId, equals('campaign-1'));
        expect(copied.campaignName, equals('Test Campaign'));
        expect(copied.distanceTraveled, equals(200.0));
      });

      test('clearCampaignId should set campaignId and campaignName to null',
          () {
        const original = CampaignExecutionState(
          status: CampaignExecutionStatus.active,
          campaignId: 'campaign-1',
          campaignName: 'Test Campaign',
        );

        final copied = original.copyWith(clearCampaignId: true);

        expect(copied.campaignId, isNull);
        expect(copied.campaignName, isNull);
      });

      test('clearPausedAt should set pausedAt to null', () {
        final original = CampaignExecutionState(
          status: CampaignExecutionStatus.paused,
          pausedAt: DateTime.now(),
        );

        final copied = original.copyWith(clearPausedAt: true);

        expect(copied.pausedAt, isNull);
      });

      test('clearError should set errorMessage to null', () {
        const original = CampaignExecutionState(
          status: CampaignExecutionStatus.error,
          errorMessage: 'Some error',
        );

        final copied = original.copyWith(clearError: true);

        expect(copied.errorMessage, isNull);
      });
    });
  });

  group('ExecutionGpsPoint', () {
    test('should create from constructor', () {
      final point = ExecutionGpsPoint(
        id: 'point-1',
        latitude: 10.0,
        longitude: 20.0,
        timestamp: DateTime.now(),
        speed: 5.0,
        accuracy: 10.0,
        synced: false,
      );

      expect(point.id, equals('point-1'));
      expect(point.latitude, equals(10.0));
      expect(point.longitude, equals(20.0));
      expect(point.speed, equals(5.0));
      expect(point.accuracy, equals(10.0));
      expect(point.synced, isFalse);
    });

    test('copyWith should copy with new values', () {
      final original = ExecutionGpsPoint(
        id: 'point-1',
        latitude: 10.0,
        longitude: 20.0,
        timestamp: DateTime.now(),
        synced: false,
      );

      final copied = original.copyWith(synced: true);

      expect(copied.id, equals('point-1'));
      expect(copied.latitude, equals(10.0));
      expect(copied.synced, isTrue);
    });

    test('toJson should serialize correctly', () {
      final timestamp = DateTime.now();
      final point = ExecutionGpsPoint(
        id: 'point-1',
        latitude: 10.0,
        longitude: 20.0,
        timestamp: timestamp,
        speed: 5.0,
        accuracy: 10.0,
      );

      final json = point.toJson();

      expect(json['lat'], equals(10.0));
      expect(json['lng'], equals(20.0));
      expect(json['timestamp'], equals(timestamp.toIso8601String()));
      expect(json['speed'], equals(5.0));
      expect(json['accuracy'], equals(10.0));
    });

    test('should be equal when properties match', () {
      final timestamp = DateTime(2024, 1, 1, 12, 0, 0);
      final point1 = ExecutionGpsPoint(
        id: 'point-1',
        latitude: 10.0,
        longitude: 20.0,
        timestamp: timestamp,
      );
      final point2 = ExecutionGpsPoint(
        id: 'point-1',
        latitude: 10.0,
        longitude: 20.0,
        timestamp: timestamp,
      );

      expect(point1, equals(point2));
    });

    test('should not be equal when properties differ', () {
      final timestamp = DateTime.now();
      final point1 = ExecutionGpsPoint(
        id: 'point-1',
        latitude: 10.0,
        longitude: 20.0,
        timestamp: timestamp,
      );
      final point2 = ExecutionGpsPoint(
        id: 'point-2',
        latitude: 10.0,
        longitude: 20.0,
        timestamp: timestamp,
      );

      expect(point1, isNot(equals(point2)));
    });
  });

  group('CampaignExecutionStatus', () {
    test('should have all required statuses', () {
      expect(CampaignExecutionStatus.values,
          contains(CampaignExecutionStatus.idle));
      expect(CampaignExecutionStatus.values,
          contains(CampaignExecutionStatus.starting));
      expect(CampaignExecutionStatus.values,
          contains(CampaignExecutionStatus.active));
      expect(CampaignExecutionStatus.values,
          contains(CampaignExecutionStatus.paused));
      expect(CampaignExecutionStatus.values,
          contains(CampaignExecutionStatus.completing));
      expect(CampaignExecutionStatus.values,
          contains(CampaignExecutionStatus.completed));
      expect(CampaignExecutionStatus.values,
          contains(CampaignExecutionStatus.error));
    });
  });
}
