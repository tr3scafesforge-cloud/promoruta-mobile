import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:promoruta/features/promotor/route_execution/domain/models/campaign_execution_state.dart';
import 'package:promoruta/features/promotor/route_execution/domain/use_cases/sync_gps_points_use_case.dart';
import 'package:promoruta/features/promotor/route_execution/presentation/providers/campaign_execution_notifier.dart';
import 'package:promoruta/shared/services/location_service.dart';

// Mocks
class MockLocationService extends Mock implements LocationService {}

class MockSyncGpsPointsUseCase extends Mock implements SyncGpsPointsUseCase {}

void main() {
  late CampaignExecutionNotifier notifier;
  late MockLocationService mockLocationService;
  late MockSyncGpsPointsUseCase mockSyncUseCase;
  late StreamController<Position> positionStreamController;

  setUpAll(() {
    registerFallbackValue(Duration.zero);
    registerFallbackValue('');  // Fallback for String used in any()
  });

  setUp(() {
    // Set up mock SharedPreferences with no persisted state
    SharedPreferences.setMockInitialValues({});

    mockLocationService = MockLocationService();
    mockSyncUseCase = MockSyncGpsPointsUseCase();
    positionStreamController = StreamController<Position>.broadcast();

    // Default mocks
    when(() => mockLocationService.positionStream)
        .thenAnswer((_) => positionStreamController.stream);
    when(() => mockLocationService.isTracking).thenReturn(false);
  });

  tearDown(() {
    positionStreamController.close();
  });

  CampaignExecutionNotifier createNotifier() {
    return CampaignExecutionNotifier(mockLocationService, mockSyncUseCase);
  }

  group('CampaignExecutionNotifier', () {
    group('Initial State', () {
      test('should start with idle status', () async {
        notifier = createNotifier();

        // Wait for async initialization
        await Future.delayed(const Duration(milliseconds: 100));

        expect(notifier.state.status, equals(CampaignExecutionStatus.idle));
        expect(notifier.state.campaignId, isNull);
        expect(notifier.state.pendingPoints, isEmpty);
        expect(notifier.state.allPoints, isEmpty);
      });
    });

    group('startExecution', () {
      test('should transition from idle to active when permission granted', () async {
        notifier = createNotifier();
        await Future.delayed(const Duration(milliseconds: 100));

        when(() => mockLocationService.requestPermission())
            .thenAnswer((_) async => LocationPermissionResult.granted);
        when(() => mockLocationService.startTracking())
            .thenAnswer((_) async => true);
        when(() => mockLocationService.getCurrentPosition())
            .thenAnswer((_) async => null);

        final result = await notifier.startExecution(
          campaignId: 'campaign-1',
          campaignName: 'Test Campaign',
        );

        expect(result, isTrue);
        expect(notifier.state.status, equals(CampaignExecutionStatus.active));
        expect(notifier.state.campaignId, equals('campaign-1'));
        expect(notifier.state.campaignName, equals('Test Campaign'));
        expect(notifier.state.startedAt, isNotNull);
      });

      test('should fail when permission denied', () async {
        notifier = createNotifier();
        await Future.delayed(const Duration(milliseconds: 100));

        when(() => mockLocationService.requestPermission())
            .thenAnswer((_) async => LocationPermissionResult.denied);

        final result = await notifier.startExecution(
          campaignId: 'campaign-1',
          campaignName: 'Test Campaign',
        );

        expect(result, isFalse);
        expect(notifier.state.status, equals(CampaignExecutionStatus.error));
        expect(notifier.state.errorMessage, contains('permission'));
      });

      test('should fail when location services disabled', () async {
        notifier = createNotifier();
        await Future.delayed(const Duration(milliseconds: 100));

        when(() => mockLocationService.requestPermission())
            .thenAnswer((_) async => LocationPermissionResult.serviceDisabled);

        final result = await notifier.startExecution(
          campaignId: 'campaign-1',
          campaignName: 'Test Campaign',
        );

        expect(result, isFalse);
        expect(notifier.state.status, equals(CampaignExecutionStatus.error));
      });

      test('should fail when tracking cannot start', () async {
        notifier = createNotifier();
        await Future.delayed(const Duration(milliseconds: 100));

        when(() => mockLocationService.requestPermission())
            .thenAnswer((_) async => LocationPermissionResult.granted);
        when(() => mockLocationService.startTracking())
            .thenAnswer((_) async => false);

        final result = await notifier.startExecution(
          campaignId: 'campaign-1',
          campaignName: 'Test Campaign',
        );

        expect(result, isFalse);
        expect(notifier.state.status, equals(CampaignExecutionStatus.error));
        expect(notifier.state.errorMessage, contains('tracking'));
      });
    });

    group('Single Active Campaign Enforcement', () {
      test('should reject starting new campaign while one is active', () async {
        notifier = createNotifier();
        await Future.delayed(const Duration(milliseconds: 100));

        when(() => mockLocationService.requestPermission())
            .thenAnswer((_) async => LocationPermissionResult.granted);
        when(() => mockLocationService.startTracking())
            .thenAnswer((_) async => true);
        when(() => mockLocationService.getCurrentPosition())
            .thenAnswer((_) async => null);

        // Start first campaign
        final firstResult = await notifier.startExecution(
          campaignId: 'campaign-1',
          campaignName: 'First Campaign',
        );
        expect(firstResult, isTrue);
        expect(notifier.state.status, equals(CampaignExecutionStatus.active));

        // Try to start second campaign
        final secondResult = await notifier.startExecution(
          campaignId: 'campaign-2',
          campaignName: 'Second Campaign',
        );

        expect(secondResult, isFalse);
        expect(notifier.state.campaignId, equals('campaign-1'));
        expect(notifier.state.campaignName, equals('First Campaign'));
      });

      test('should reject starting new campaign while one is paused', () async {
        notifier = createNotifier();
        await Future.delayed(const Duration(milliseconds: 100));

        when(() => mockLocationService.requestPermission())
            .thenAnswer((_) async => LocationPermissionResult.granted);
        when(() => mockLocationService.startTracking())
            .thenAnswer((_) async => true);
        when(() => mockLocationService.getCurrentPosition())
            .thenAnswer((_) async => null);
        when(() => mockLocationService.pauseTracking()).thenReturn(null);

        // Start and pause first campaign
        await notifier.startExecution(
          campaignId: 'campaign-1',
          campaignName: 'First Campaign',
        );
        await notifier.pauseExecution();
        expect(notifier.state.status, equals(CampaignExecutionStatus.paused));

        // Try to start second campaign
        final secondResult = await notifier.startExecution(
          campaignId: 'campaign-2',
          campaignName: 'Second Campaign',
        );

        expect(secondResult, isFalse);
        expect(notifier.state.campaignId, equals('campaign-1'));
      });

      test('should allow starting new campaign after previous is completed', () async {
        notifier = createNotifier();
        await Future.delayed(const Duration(milliseconds: 100));

        when(() => mockLocationService.requestPermission())
            .thenAnswer((_) async => LocationPermissionResult.granted);
        when(() => mockLocationService.startTracking())
            .thenAnswer((_) async => true);
        when(() => mockLocationService.getCurrentPosition())
            .thenAnswer((_) async => null);
        when(() => mockLocationService.stopTracking()).thenReturn(null);
        when(() => mockSyncUseCase.call(any()))
            .thenAnswer((_) async => const SyncResult(synced: 0, failed: 0));

        // Start and complete first campaign
        await notifier.startExecution(
          campaignId: 'campaign-1',
          campaignName: 'First Campaign',
        );
        await notifier.completeExecution();
        expect(notifier.state.status, equals(CampaignExecutionStatus.completed));

        // Reset state
        await notifier.reset();
        expect(notifier.state.status, equals(CampaignExecutionStatus.idle));

        // Start second campaign
        final secondResult = await notifier.startExecution(
          campaignId: 'campaign-2',
          campaignName: 'Second Campaign',
        );

        expect(secondResult, isTrue);
        expect(notifier.state.campaignId, equals('campaign-2'));
      });
    });

    group('pauseExecution', () {
      test('should transition from active to paused', () async {
        notifier = createNotifier();
        await Future.delayed(const Duration(milliseconds: 100));

        when(() => mockLocationService.requestPermission())
            .thenAnswer((_) async => LocationPermissionResult.granted);
        when(() => mockLocationService.startTracking())
            .thenAnswer((_) async => true);
        when(() => mockLocationService.getCurrentPosition())
            .thenAnswer((_) async => null);
        when(() => mockLocationService.pauseTracking()).thenReturn(null);

        await notifier.startExecution(
          campaignId: 'campaign-1',
          campaignName: 'Test Campaign',
        );

        await notifier.pauseExecution();

        expect(notifier.state.status, equals(CampaignExecutionStatus.paused));
        expect(notifier.state.pausedAt, isNotNull);
        verify(() => mockLocationService.pauseTracking()).called(1);
      });

      test('should not pause if not active', () async {
        notifier = createNotifier();
        await Future.delayed(const Duration(milliseconds: 100));

        await notifier.pauseExecution();

        expect(notifier.state.status, equals(CampaignExecutionStatus.idle));
        verifyNever(() => mockLocationService.pauseTracking());
      });
    });

    group('resumeExecution', () {
      test('should transition from paused to active', () async {
        notifier = createNotifier();
        await Future.delayed(const Duration(milliseconds: 100));

        when(() => mockLocationService.requestPermission())
            .thenAnswer((_) async => LocationPermissionResult.granted);
        when(() => mockLocationService.startTracking())
            .thenAnswer((_) async => true);
        when(() => mockLocationService.getCurrentPosition())
            .thenAnswer((_) async => null);
        when(() => mockLocationService.pauseTracking()).thenReturn(null);
        when(() => mockLocationService.resumeTracking()).thenReturn(null);

        await notifier.startExecution(
          campaignId: 'campaign-1',
          campaignName: 'Test Campaign',
        );
        await notifier.pauseExecution();
        await notifier.resumeExecution();

        expect(notifier.state.status, equals(CampaignExecutionStatus.active));
        expect(notifier.state.pausedAt, isNull);
        verify(() => mockLocationService.resumeTracking()).called(1);
      });

      test('should accumulate pause duration', () async {
        notifier = createNotifier();
        await Future.delayed(const Duration(milliseconds: 100));

        when(() => mockLocationService.requestPermission())
            .thenAnswer((_) async => LocationPermissionResult.granted);
        when(() => mockLocationService.startTracking())
            .thenAnswer((_) async => true);
        when(() => mockLocationService.getCurrentPosition())
            .thenAnswer((_) async => null);
        when(() => mockLocationService.pauseTracking()).thenReturn(null);
        when(() => mockLocationService.resumeTracking()).thenReturn(null);

        await notifier.startExecution(
          campaignId: 'campaign-1',
          campaignName: 'Test Campaign',
        );

        final initialPausedDuration = notifier.state.totalPausedDuration;

        await notifier.pauseExecution();
        await Future.delayed(const Duration(milliseconds: 100));
        await notifier.resumeExecution();

        expect(
          notifier.state.totalPausedDuration,
          greaterThan(initialPausedDuration),
        );
      });

      test('should not resume if not paused', () async {
        notifier = createNotifier();
        await Future.delayed(const Duration(milliseconds: 100));

        await notifier.resumeExecution();

        expect(notifier.state.status, equals(CampaignExecutionStatus.idle));
        verifyNever(() => mockLocationService.resumeTracking());
      });
    });

    group('completeExecution', () {
      test('should transition to completed and return summary', () async {
        notifier = createNotifier();
        await Future.delayed(const Duration(milliseconds: 100));

        when(() => mockLocationService.requestPermission())
            .thenAnswer((_) async => LocationPermissionResult.granted);
        when(() => mockLocationService.startTracking())
            .thenAnswer((_) async => true);
        when(() => mockLocationService.getCurrentPosition())
            .thenAnswer((_) async => null);
        when(() => mockLocationService.stopTracking()).thenReturn(null);
        when(() => mockSyncUseCase.call(any()))
            .thenAnswer((_) async => const SyncResult(synced: 0, failed: 0));

        await notifier.startExecution(
          campaignId: 'campaign-1',
          campaignName: 'Test Campaign',
        );

        final summary = await notifier.completeExecution();

        expect(notifier.state.status, equals(CampaignExecutionStatus.completed));
        expect(summary.campaignId, equals('campaign-1'));
        expect(summary.campaignName, equals('Test Campaign'));
        expect(summary.startedAt, isNotNull);
        expect(summary.completedAt, isNotNull);
        verify(() => mockLocationService.stopTracking()).called(1);
        // Note: Sync use case is only called if there are pending points
        // In this test, no GPS points were collected, so sync is not called
      });

      test('should throw when no active execution', () async {
        notifier = createNotifier();
        await Future.delayed(const Duration(milliseconds: 100));

        expect(
          () => notifier.completeExecution(),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('cancelExecution', () {
      test('should reset to idle state', () async {
        notifier = createNotifier();
        await Future.delayed(const Duration(milliseconds: 100));

        when(() => mockLocationService.requestPermission())
            .thenAnswer((_) async => LocationPermissionResult.granted);
        when(() => mockLocationService.startTracking())
            .thenAnswer((_) async => true);
        when(() => mockLocationService.getCurrentPosition())
            .thenAnswer((_) async => null);
        when(() => mockLocationService.stopTracking()).thenReturn(null);

        await notifier.startExecution(
          campaignId: 'campaign-1',
          campaignName: 'Test Campaign',
        );
        await notifier.cancelExecution();

        expect(notifier.state.status, equals(CampaignExecutionStatus.idle));
        expect(notifier.state.campaignId, isNull);
        verify(() => mockLocationService.stopTracking()).called(1);
      });
    });

    group('Point Accumulation', () {
      Position createPosition({
        required double latitude,
        required double longitude,
        double speed = 5.0,
        double accuracy = 10.0,
      }) {
        return Position(
          latitude: latitude,
          longitude: longitude,
          timestamp: DateTime.now(),
          accuracy: accuracy,
          altitude: 0,
          altitudeAccuracy: 0,
          heading: 0,
          headingAccuracy: 0,
          speed: speed,
          speedAccuracy: 0,
        );
      }

      test('should accumulate GPS points during tracking', () async {
        notifier = createNotifier();
        await Future.delayed(const Duration(milliseconds: 100));

        when(() => mockLocationService.requestPermission())
            .thenAnswer((_) async => LocationPermissionResult.granted);
        when(() => mockLocationService.startTracking())
            .thenAnswer((_) async => true);
        when(() => mockLocationService.getCurrentPosition())
            .thenAnswer((_) async => null);

        await notifier.startExecution(
          campaignId: 'campaign-1',
          campaignName: 'Test Campaign',
        );

        // Emit position updates
        positionStreamController.add(createPosition(
          latitude: 10.0,
          longitude: 20.0,
        ));

        await Future.delayed(const Duration(milliseconds: 50));

        positionStreamController.add(createPosition(
          latitude: 10.001,
          longitude: 20.001,
        ));

        await Future.delayed(const Duration(milliseconds: 50));

        expect(notifier.state.allPoints.length, greaterThanOrEqualTo(1));
        expect(notifier.state.currentPosition, isNotNull);
      });

      test('should filter out GPS drift (small distance, low speed)', () async {
        notifier = createNotifier();
        await Future.delayed(const Duration(milliseconds: 100));

        when(() => mockLocationService.requestPermission())
            .thenAnswer((_) async => LocationPermissionResult.granted);
        when(() => mockLocationService.startTracking())
            .thenAnswer((_) async => true);
        when(() => mockLocationService.getCurrentPosition())
            .thenAnswer((_) async => createPosition(
                  latitude: 10.0,
                  longitude: 20.0,
                ));

        await notifier.startExecution(
          campaignId: 'campaign-1',
          campaignName: 'Test Campaign',
        );

        final initialPointCount = notifier.state.allPoints.length;

        // Emit a position very close to current with low speed (GPS drift)
        positionStreamController.add(createPosition(
          latitude: 10.00001,
          longitude: 20.00001,
          speed: 0.1, // Below minimum speed filter
        ));

        await Future.delayed(const Duration(milliseconds: 50));

        // Point should be filtered out as GPS drift
        expect(notifier.state.allPoints.length, equals(initialPointCount));
      });

      test('should calculate distance traveled', () async {
        notifier = createNotifier();
        await Future.delayed(const Duration(milliseconds: 100));

        when(() => mockLocationService.requestPermission())
            .thenAnswer((_) async => LocationPermissionResult.granted);
        when(() => mockLocationService.startTracking())
            .thenAnswer((_) async => true);
        when(() => mockLocationService.getCurrentPosition())
            .thenAnswer((_) async => createPosition(
                  latitude: 10.0,
                  longitude: 20.0,
                ));

        await notifier.startExecution(
          campaignId: 'campaign-1',
          campaignName: 'Test Campaign',
        );

        expect(notifier.state.distanceTraveled, equals(0.0));

        // Emit position ~111 meters away (0.001 degrees at equator ≈ 111m)
        positionStreamController.add(createPosition(
          latitude: 10.001,
          longitude: 20.0,
          speed: 5.0,
        ));

        await Future.delayed(const Duration(milliseconds: 50));

        // Distance should have increased
        expect(notifier.state.distanceTraveled, greaterThan(0));
      });
    });
  });
}
