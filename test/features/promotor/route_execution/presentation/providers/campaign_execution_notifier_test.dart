import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:promoruta/features/promotor/route_execution/domain/models/campaign_execution_state.dart';
import 'package:promoruta/features/promotor/route_execution/domain/use_cases/sync_gps_points_use_case.dart';
import 'package:promoruta/features/promotor/route_execution/presentation/providers/campaign_execution_notifier.dart';
import 'package:promoruta/features/campaign_bidding/domain/use_cases/campaign_bidding_use_cases.dart';
import 'package:promoruta/shared/models/gps_tracking_config.dart';
import 'package:promoruta/shared/services/location_service.dart';
import 'package:promoruta/core/models/campaign.dart' as model;

// Mocks
class MockLocationService extends Mock implements LocationService {}

class MockSyncGpsPointsUseCase extends Mock implements SyncGpsPointsUseCase {}
class MockStartCampaignUseCase extends Mock implements StartCampaignUseCase {}
class MockCompleteCampaignUseCase extends Mock
    implements CompleteCampaignUseCase {}

void main() {
  late CampaignExecutionNotifier notifier;
  late MockLocationService mockLocationService;
  late MockSyncGpsPointsUseCase mockSyncUseCase;
  late MockStartCampaignUseCase mockStartCampaignUseCase;
  late MockCompleteCampaignUseCase mockCompleteCampaignUseCase;
  late StreamController<Position> positionStreamController;

  model.Campaign sampleCampaign() {
    return model.Campaign(
      id: 'campaign-1',
      title: 'Test Campaign',
      zone: 'Test Zone',
      suggestedPrice: 100.0,
      bidDeadline: DateTime(2025, 1, 1, 10, 0),
      audioDuration: 30,
      distance: 1.0,
      routeCoordinates: const [],
      startTime: DateTime(2025, 1, 1, 10, 0),
      endTime: DateTime(2025, 1, 1, 11, 0),
    );
  }

  setUpAll(() {
    registerFallbackValue(Duration.zero);
    registerFallbackValue(''); // Fallback for String used in any()
  });

  setUp(() {
    // Set up mock SharedPreferences with no persisted state
    SharedPreferences.setMockInitialValues({});

    mockLocationService = MockLocationService();
    mockSyncUseCase = MockSyncGpsPointsUseCase();
    mockStartCampaignUseCase = MockStartCampaignUseCase();
    mockCompleteCampaignUseCase = MockCompleteCampaignUseCase();
    positionStreamController = StreamController<Position>.broadcast();

    // Default mocks
    when(() => mockLocationService.positionStream)
        .thenAnswer((_) => positionStreamController.stream);
    when(() => mockLocationService.isTracking).thenReturn(false);
    when(() => mockStartCampaignUseCase.call(any()))
        .thenAnswer((_) async => sampleCampaign());
    when(() => mockCompleteCampaignUseCase.call(any()))
        .thenAnswer((_) async => sampleCampaign());
  });

  tearDown(() {
    positionStreamController.close();
  });

  CampaignExecutionNotifier createNotifier() {
    return CampaignExecutionNotifier(
      mockLocationService,
      mockSyncUseCase,
      mockStartCampaignUseCase,
      mockCompleteCampaignUseCase,
    );
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
      test('should transition from idle to active when permission granted',
          () async {
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

      test('should allow starting new campaign after previous is completed',
          () async {
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
        expect(
            notifier.state.status, equals(CampaignExecutionStatus.completed));

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

        expect(
            notifier.state.status, equals(CampaignExecutionStatus.completed));
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

      test('should not process position updates when paused', () async {
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

        // Pause execution
        await notifier.pauseExecution();
        final pointsAfterPause = notifier.state.allPoints.length;

        // Emit a position while paused — should be ignored
        positionStreamController.add(createPosition(
          latitude: 10.1,
          longitude: 20.1,
          speed: 5.0,
        ));
        await Future.delayed(const Duration(milliseconds: 50));

        expect(notifier.state.allPoints.length, equals(pointsAfterPause));
      });

      test('should include initial position when available', () async {
        notifier = createNotifier();
        await Future.delayed(const Duration(milliseconds: 100));

        final initialPosition = createPosition(
          latitude: -34.9011,
          longitude: -56.1645,
        );

        when(() => mockLocationService.requestPermission())
            .thenAnswer((_) async => LocationPermissionResult.granted);
        when(() => mockLocationService.startTracking())
            .thenAnswer((_) async => true);
        when(() => mockLocationService.getCurrentPosition())
            .thenAnswer((_) async => initialPosition);

        await notifier.startExecution(
          campaignId: 'campaign-1',
          campaignName: 'Test Campaign',
        );

        expect(notifier.state.allPoints, hasLength(1));
        expect(notifier.state.pendingPoints, hasLength(1));
        expect(notifier.state.currentPosition, isNotNull);
        expect(
          notifier.state.currentPosition!.latitude,
          equals(initialPosition.latitude),
        );
      });

      test('should accept points above speed threshold', () async {
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

        // Emit a position far enough with high speed
        positionStreamController.add(createPosition(
          latitude: 10.001,
          longitude: 20.001,
          speed: 3.0,
        ));
        await Future.delayed(const Duration(milliseconds: 50));

        expect(notifier.state.allPoints.length, equals(initialPointCount + 1));
      });
    });

    group('startExecution - backend errors', () {
      test('should fail when backend rejects start (payment pending)',
          () async {
        notifier = createNotifier();
        await Future.delayed(const Duration(milliseconds: 100));

        when(() => mockStartCampaignUseCase.call(any()))
            .thenThrow(Exception('Access denied'));

        final result = await notifier.startExecution(
          campaignId: 'campaign-1',
          campaignName: 'Test Campaign',
        );

        expect(result, isFalse);
        expect(notifier.state.status, equals(CampaignExecutionStatus.error));
        expect(
          notifier.state.errorMessage,
          contains('Payment is still pending'),
        );
      });

      test('should show generic error for non-access-denied failures',
          () async {
        notifier = createNotifier();
        await Future.delayed(const Duration(milliseconds: 100));

        when(() => mockStartCampaignUseCase.call(any()))
            .thenThrow(Exception('Server unavailable'));

        final result = await notifier.startExecution(
          campaignId: 'campaign-1',
          campaignName: 'Test Campaign',
        );

        expect(result, isFalse);
        expect(notifier.state.status, equals(CampaignExecutionStatus.error));
        expect(notifier.state.errorMessage, contains('Server unavailable'));
      });

      test('should fail when permission permanently denied', () async {
        notifier = createNotifier();
        await Future.delayed(const Duration(milliseconds: 100));

        when(() => mockLocationService.requestPermission())
            .thenAnswer((_) async => LocationPermissionResult.deniedForever);

        final result = await notifier.startExecution(
          campaignId: 'campaign-1',
          campaignName: 'Test Campaign',
        );

        expect(result, isFalse);
        expect(notifier.state.status, equals(CampaignExecutionStatus.error));
        expect(notifier.state.errorMessage, contains('permanently denied'));
      });
    });

    group('Batch sync trigger', () {
      test('should trigger sync when batch size is reached', () async {
        notifier = CampaignExecutionNotifier(
          mockLocationService,
          mockSyncUseCase,
          mockStartCampaignUseCase,
          mockCompleteCampaignUseCase,
          gpsConfig: const GpsTrackingConfig(
            batchSize: 3,
            distanceFilterMeters: 0,
            minSpeedMetersSec: 0.0,
            syncIntervalSeconds: 9999,
          ),
        );
        await Future.delayed(const Duration(milliseconds: 100));

        Position createPos(int i) => Position(
              latitude: 10.0 + (i * 0.001),
              longitude: 20.0 + (i * 0.001),
              timestamp: DateTime.now(),
              accuracy: 5.0,
              altitude: 0,
              altitudeAccuracy: 0,
              heading: 0,
              headingAccuracy: 0,
              speed: 5.0,
              speedAccuracy: 0,
            );

        when(() => mockLocationService.requestPermission())
            .thenAnswer((_) async => LocationPermissionResult.granted);
        when(() => mockLocationService.startTracking())
            .thenAnswer((_) async => true);
        when(() => mockLocationService.getCurrentPosition())
            .thenAnswer((_) async => null);
        when(() => mockSyncUseCase.call(any()))
            .thenAnswer((_) async => const SyncResult(synced: 3, failed: 0));

        await notifier.startExecution(
          campaignId: 'campaign-1',
          campaignName: 'Test Campaign',
        );

        // Emit 3 points to reach batch size
        for (var i = 1; i <= 3; i++) {
          positionStreamController.add(createPos(i));
          await Future.delayed(const Duration(milliseconds: 20));
        }

        // Allow sync to complete
        await Future.delayed(const Duration(milliseconds: 100));

        verify(() => mockSyncUseCase.call('campaign-1'))
            .called(greaterThan(0));
      });
    });

    group('completeExecution - edge cases', () {
      test('should still complete when backend completion fails', () async {
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
        when(() => mockCompleteCampaignUseCase.call(any()))
            .thenThrow(Exception('Network error'));

        await notifier.startExecution(
          campaignId: 'campaign-1',
          campaignName: 'Test Campaign',
        );

        final summary = await notifier.completeExecution();

        // Should still mark as completed despite backend error
        expect(
          notifier.state.status,
          equals(CampaignExecutionStatus.completed),
        );
        expect(summary.campaignId, equals('campaign-1'));
      });

      test('should include collected points count in summary', () async {
        notifier = createNotifier();
        await Future.delayed(const Duration(milliseconds: 100));

        Position createPos(double lat, double lng) => Position(
              latitude: lat,
              longitude: lng,
              timestamp: DateTime.now(),
              accuracy: 5.0,
              altitude: 0,
              altitudeAccuracy: 0,
              heading: 0,
              headingAccuracy: 0,
              speed: 5.0,
              speedAccuracy: 0,
            );

        when(() => mockLocationService.requestPermission())
            .thenAnswer((_) async => LocationPermissionResult.granted);
        when(() => mockLocationService.startTracking())
            .thenAnswer((_) async => true);
        when(() => mockLocationService.getCurrentPosition())
            .thenAnswer((_) async => createPos(10.0, 20.0));
        when(() => mockLocationService.stopTracking()).thenReturn(null);
        when(() => mockSyncUseCase.call(any()))
            .thenAnswer((_) async => const SyncResult(synced: 0, failed: 0));

        await notifier.startExecution(
          campaignId: 'campaign-1',
          campaignName: 'Test Campaign',
        );

        // Add a few more points
        positionStreamController.add(createPos(10.001, 20.001));
        await Future.delayed(const Duration(milliseconds: 50));
        positionStreamController.add(createPos(10.002, 20.002));
        await Future.delayed(const Duration(milliseconds: 50));

        final summary = await notifier.completeExecution();

        // Initial position + 2 streamed points
        expect(summary.totalPoints, greaterThanOrEqualTo(2));
      });
    });
  });

  group('CampaignExecutionState', () {
    test('idle factory creates correct default state', () {
      final state = CampaignExecutionState.idle();

      expect(state.status, CampaignExecutionStatus.idle);
      expect(state.campaignId, isNull);
      expect(state.pendingPoints, isEmpty);
      expect(state.allPoints, isEmpty);
      expect(state.startedAt, isNull);
      expect(state.distanceTraveled, 0.0);
      expect(state.errorMessage, isNull);
    });

    test('isTrackingActive returns true only when active', () {
      const active = CampaignExecutionState(
        status: CampaignExecutionStatus.active,
      );
      const paused = CampaignExecutionState(
        status: CampaignExecutionStatus.paused,
      );
      final idle = CampaignExecutionState.idle();

      expect(active.isTrackingActive, isTrue);
      expect(paused.isTrackingActive, isFalse);
      expect(idle.isTrackingActive, isFalse);
    });

    test(
        'hasActiveExecution returns true for active, paused, starting, completing',
        () {
      for (final status in [
        CampaignExecutionStatus.active,
        CampaignExecutionStatus.paused,
        CampaignExecutionStatus.starting,
        CampaignExecutionStatus.completing,
      ]) {
        final state = CampaignExecutionState(status: status);
        expect(state.hasActiveExecution, isTrue, reason: '$status');
      }

      for (final status in [
        CampaignExecutionStatus.idle,
        CampaignExecutionStatus.completed,
        CampaignExecutionStatus.error,
      ]) {
        final state = CampaignExecutionState(status: status);
        expect(state.hasActiveExecution, isFalse, reason: '$status');
      }
    });

    test('elapsedTime returns zero when not started', () {
      final state = CampaignExecutionState.idle();
      expect(state.elapsedTime, Duration.zero);
    });

    test('formattedDistance shows meters when < 1km', () {
      const state = CampaignExecutionState(distanceTraveled: 500.0);
      expect(state.formattedDistance, '500 m');
    });

    test('formattedDistance shows km when >= 1km', () {
      const state = CampaignExecutionState(distanceTraveled: 2500.0);
      expect(state.formattedDistance, '2.50 km');
    });

    test('copyWith preserves values when nothing is changed', () {
      const original = CampaignExecutionState(
        status: CampaignExecutionStatus.active,
        campaignId: 'test-123',
        campaignName: 'Test',
        distanceTraveled: 100.0,
      );

      final copy = original.copyWith();

      expect(copy.status, original.status);
      expect(copy.campaignId, original.campaignId);
      expect(copy.campaignName, original.campaignName);
      expect(copy.distanceTraveled, original.distanceTraveled);
    });

    test('copyWith clearCampaignId nullifies campaign fields', () {
      const original = CampaignExecutionState(
        campaignId: 'test-123',
        campaignName: 'Test',
      );

      final cleared = original.copyWith(clearCampaignId: true);

      expect(cleared.campaignId, isNull);
      expect(cleared.campaignName, isNull);
    });

    test('copyWith clearError nullifies errorMessage', () {
      const original = CampaignExecutionState(
        errorMessage: 'Something failed',
      );

      final cleared = original.copyWith(clearError: true);

      expect(cleared.errorMessage, isNull);
    });

    test('copyWith clearPausedAt nullifies pausedAt', () {
      final original = CampaignExecutionState(
        pausedAt: DateTime(2026, 1, 1),
      );

      final cleared = original.copyWith(clearPausedAt: true);

      expect(cleared.pausedAt, isNull);
    });

    test('distanceKm converts meters to kilometers', () {
      const state = CampaignExecutionState(distanceTraveled: 5000.0);
      expect(state.distanceKm, 5.0);
    });
  });

  group('ExecutionGpsPoint', () {
    test('fromPosition creates correct point', () {
      final position = Position(
        latitude: -34.9011,
        longitude: -56.1645,
        timestamp: DateTime(2026, 3, 26),
        accuracy: 10.0,
        altitude: 0,
        altitudeAccuracy: 0,
        heading: 0,
        headingAccuracy: 0,
        speed: 3.5,
        speedAccuracy: 0,
      );

      final point = ExecutionGpsPoint.fromPosition(position, 'test-id');

      expect(point.id, 'test-id');
      expect(point.latitude, -34.9011);
      expect(point.longitude, -56.1645);
      expect(point.speed, 3.5);
      expect(point.accuracy, 10.0);
      expect(point.synced, isFalse);
    });

    test('copyWith updates synced status', () {
      final point = ExecutionGpsPoint(
        id: 'p1',
        latitude: 10.0,
        longitude: 20.0,
        timestamp: DateTime(2026, 1, 1),
        synced: false,
      );

      final synced = point.copyWith(synced: true);

      expect(synced.synced, isTrue);
      expect(synced.id, 'p1');
      expect(synced.latitude, 10.0);
    });

    test('toJson outputs correct format', () {
      final point = ExecutionGpsPoint(
        id: 'p1',
        latitude: -34.9011,
        longitude: -56.1645,
        timestamp: DateTime.utc(2026, 3, 26, 12, 0, 0),
        speed: 2.0,
        accuracy: 5.0,
      );

      final json = point.toJson();

      expect(json['lat'], -34.9011);
      expect(json['lng'], -56.1645);
      expect(json['speed'], 2.0);
      expect(json['accuracy'], 5.0);
      expect(json['timestamp'], '2026-03-26T12:00:00.000Z');
    });

    test('equatable compares all props', () {
      final timestamp = DateTime(2026, 1, 1);
      final point1 = ExecutionGpsPoint(
        id: 'p1',
        latitude: 10.0,
        longitude: 20.0,
        timestamp: timestamp,
      );
      final point2 = ExecutionGpsPoint(
        id: 'p1',
        latitude: 10.0,
        longitude: 20.0,
        timestamp: timestamp,
      );
      final point3 = ExecutionGpsPoint(
        id: 'p2',
        latitude: 10.0,
        longitude: 20.0,
        timestamp: timestamp,
      );

      expect(point1, equals(point2));
      expect(point1, isNot(equals(point3)));
    });
  });

  group('CampaignExecutionSummary', () {
    test('formattedDuration shows HH:MM:SS', () {
      final summary = CampaignExecutionSummary(
        campaignId: 'c1',
        campaignName: 'Test',
        startedAt: DateTime(2026, 1, 1, 10, 0),
        completedAt: DateTime(2026, 1, 1, 11, 30),
        totalDuration: const Duration(hours: 1, minutes: 25, seconds: 30),
        distanceTraveled: 5000.0,
        totalPoints: 100,
      );

      expect(summary.formattedDuration, '01:25:30');
    });

    test('formattedDistance shows meters when < 1km', () {
      final summary = CampaignExecutionSummary(
        campaignId: 'c1',
        campaignName: 'Test',
        startedAt: DateTime(2026),
        completedAt: DateTime(2026),
        totalDuration: Duration.zero,
        distanceTraveled: 750.0,
        totalPoints: 0,
      );

      expect(summary.formattedDistance, '750 m');
    });

    test('formattedDistance shows km when >= 1km', () {
      final summary = CampaignExecutionSummary(
        campaignId: 'c1',
        campaignName: 'Test',
        startedAt: DateTime(2026),
        completedAt: DateTime(2026),
        totalDuration: Duration.zero,
        distanceTraveled: 3250.0,
        totalPoints: 0,
      );

      expect(summary.formattedDistance, '3.25 km');
    });

    test('distanceKm converts meters to km', () {
      final summary = CampaignExecutionSummary(
        campaignId: 'c1',
        campaignName: 'Test',
        startedAt: DateTime(2026),
        completedAt: DateTime(2026),
        totalDuration: Duration.zero,
        distanceTraveled: 5000.0,
        totalPoints: 0,
      );

      expect(summary.distanceKm, 5.0);
    });
  });
}
