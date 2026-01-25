import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:promoruta/core/models/gps_point.dart';
import 'package:promoruta/features/promotor/gps_tracking/data/datasources/local/gps_local_data_source.dart';
import 'package:promoruta/features/promotor/gps_tracking/data/datasources/remote/gps_remote_data_source.dart';
import 'package:promoruta/features/promotor/route_execution/domain/use_cases/sync_gps_points_use_case.dart';

// Mocks
class MockGpsLocalDataSource extends Mock implements GpsLocalDataSourceImpl {}

class MockGpsRemoteDataSource extends Mock implements GpsRemoteDataSourceImpl {}

void main() {
  late SyncGpsPointsUseCase useCase;
  late MockGpsLocalDataSource mockLocalDataSource;
  late MockGpsRemoteDataSource mockRemoteDataSource;

  setUp(() {
    mockLocalDataSource = MockGpsLocalDataSource();
    mockRemoteDataSource = MockGpsRemoteDataSource();
    useCase = SyncGpsPointsUseCase(
      localDataSource: mockLocalDataSource,
      remoteDataSource: mockRemoteDataSource,
    );
  });

  GpsPoint createGpsPoint({
    required String id,
    required double latitude,
    required double longitude,
  }) {
    return GpsPoint(
      id: id,
      routeId: '',
      latitude: latitude,
      longitude: longitude,
      timestamp: DateTime.now(),
    );
  }

  group('SyncGpsPointsUseCase', () {
    const campaignId = 'campaign-123';

    group('call', () {
      test('should return zero synced when no unsynced points', () async {
        when(() => mockLocalDataSource.getUnsyncedCampaignPoints(campaignId))
            .thenAnswer((_) async => []);

        final result = await useCase.call(campaignId);

        expect(result.synced, equals(0));
        expect(result.failed, equals(0));
        expect(result.hasError, isFalse);
        expect(result.isSuccess, isFalse); // No points synced

        verify(() => mockLocalDataSource.getUnsyncedCampaignPoints(campaignId))
            .called(1);
        verifyNever(
          () => mockRemoteDataSource.uploadCampaignGpsTracks(any(), any()),
        );
      });

      test('should upload points and mark as synced on success', () async {
        final points = [
          createGpsPoint(id: 'point-1', latitude: 10.0, longitude: 20.0),
          createGpsPoint(id: 'point-2', latitude: 10.1, longitude: 20.1),
          createGpsPoint(id: 'point-3', latitude: 10.2, longitude: 20.2),
        ];

        when(() => mockLocalDataSource.getUnsyncedCampaignPoints(campaignId))
            .thenAnswer((_) async => points);
        when(
          () => mockRemoteDataSource.uploadCampaignGpsTracks(campaignId, points),
        ).thenAnswer(
          (_) async => GpsTrackUploadResponse(
            created: 3,
            existing: 0,
            total: 3,
            trackIds: ['track-1'],
          ),
        );
        when(
          () => mockLocalDataSource.markPointsAsSynced(
            ['point-1', 'point-2', 'point-3'],
          ),
        ).thenAnswer((_) async {});

        final result = await useCase.call(campaignId);

        expect(result.synced, equals(3));
        expect(result.failed, equals(0));
        expect(result.hasError, isFalse);
        expect(result.isSuccess, isTrue);

        verify(() => mockLocalDataSource.getUnsyncedCampaignPoints(campaignId))
            .called(1);
        verify(
          () => mockRemoteDataSource.uploadCampaignGpsTracks(campaignId, points),
        ).called(1);
        verify(
          () => mockLocalDataSource.markPointsAsSynced(
            ['point-1', 'point-2', 'point-3'],
          ),
        ).called(1);
      });

      test('should handle idempotency (existing points)', () async {
        final points = [
          createGpsPoint(id: 'point-1', latitude: 10.0, longitude: 20.0),
          createGpsPoint(id: 'point-2', latitude: 10.1, longitude: 20.1),
        ];

        when(() => mockLocalDataSource.getUnsyncedCampaignPoints(campaignId))
            .thenAnswer((_) async => points);
        when(
          () => mockRemoteDataSource.uploadCampaignGpsTracks(campaignId, points),
        ).thenAnswer(
          (_) async => GpsTrackUploadResponse(
            created: 0,
            existing: 2, // All points already existed (idempotent)
            total: 2,
            trackIds: ['track-1'],
          ),
        );
        when(
          () => mockLocalDataSource.markPointsAsSynced(['point-1', 'point-2']),
        ).thenAnswer((_) async {});

        final result = await useCase.call(campaignId);

        expect(result.synced, equals(2));
        expect(result.failed, equals(0));
        expect(result.isSuccess, isTrue);

        // Points should still be marked as synced locally
        verify(
          () => mockLocalDataSource.markPointsAsSynced(['point-1', 'point-2']),
        ).called(1);
      });

      test('should return error on upload failure', () async {
        final points = [
          createGpsPoint(id: 'point-1', latitude: 10.0, longitude: 20.0),
        ];

        when(() => mockLocalDataSource.getUnsyncedCampaignPoints(campaignId))
            .thenAnswer((_) async => points);
        when(
          () => mockRemoteDataSource.uploadCampaignGpsTracks(campaignId, points),
        ).thenThrow(Exception('Network error'));

        final result = await useCase.call(campaignId);

        expect(result.synced, equals(0));
        expect(result.failed, equals(1));
        expect(result.hasError, isTrue);
        expect(result.errorMessage, contains('Network error'));

        // Points should NOT be marked as synced
        verifyNever(() => mockLocalDataSource.markPointsAsSynced(any()));
      });

      test('should return error on local data source failure', () async {
        when(() => mockLocalDataSource.getUnsyncedCampaignPoints(campaignId))
            .thenThrow(Exception('Database error'));

        final result = await useCase.call(campaignId);

        expect(result.synced, equals(0));
        expect(result.failed, equals(1));
        expect(result.hasError, isTrue);
        expect(result.errorMessage, contains('Database error'));

        verifyNever(
          () => mockRemoteDataSource.uploadCampaignGpsTracks(any(), any()),
        );
        verifyNever(() => mockLocalDataSource.markPointsAsSynced(any()));
      });

      test('should handle partial success (some points uploaded)', () async {
        final points = [
          createGpsPoint(id: 'point-1', latitude: 10.0, longitude: 20.0),
          createGpsPoint(id: 'point-2', latitude: 10.1, longitude: 20.1),
        ];

        when(() => mockLocalDataSource.getUnsyncedCampaignPoints(campaignId))
            .thenAnswer((_) async => points);
        when(
          () => mockRemoteDataSource.uploadCampaignGpsTracks(campaignId, points),
        ).thenAnswer(
          (_) async => GpsTrackUploadResponse(
            created: 1,
            existing: 1,
            total: 2,
            trackIds: ['track-1'],
          ),
        );
        when(
          () => mockLocalDataSource.markPointsAsSynced(['point-1', 'point-2']),
        ).thenAnswer((_) async {});

        final result = await useCase.call(campaignId);

        expect(result.synced, equals(2));
        expect(result.failed, equals(0));
        expect(result.isSuccess, isTrue);
      });
    });

    group('getUnsyncedCount', () {
      test('should return count from local data source', () async {
        when(() => mockLocalDataSource.getUnsyncedPointCount(campaignId))
            .thenAnswer((_) async => 42);

        final count = await useCase.getUnsyncedCount(campaignId);

        expect(count, equals(42));
        verify(() => mockLocalDataSource.getUnsyncedPointCount(campaignId))
            .called(1);
      });

      test('should return zero when no unsynced points', () async {
        when(() => mockLocalDataSource.getUnsyncedPointCount(campaignId))
            .thenAnswer((_) async => 0);

        final count = await useCase.getUnsyncedCount(campaignId);

        expect(count, equals(0));
      });
    });
  });

  group('SyncResult', () {
    test('hasError should be true when errorMessage is present', () {
      const result = SyncResult(
        synced: 0,
        failed: 1,
        errorMessage: 'Some error',
      );

      expect(result.hasError, isTrue);
    });

    test('hasError should be false when errorMessage is null', () {
      const result = SyncResult(synced: 5, failed: 0);

      expect(result.hasError, isFalse);
    });

    test('isSuccess should be true when synced > 0 and failed == 0', () {
      const result = SyncResult(synced: 5, failed: 0);

      expect(result.isSuccess, isTrue);
    });

    test('isSuccess should be false when synced == 0', () {
      const result = SyncResult(synced: 0, failed: 0);

      expect(result.isSuccess, isFalse);
    });

    test('isSuccess should be false when failed > 0', () {
      const result = SyncResult(synced: 5, failed: 1);

      expect(result.isSuccess, isFalse);
    });
  });
}
