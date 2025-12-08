import 'package:latlong2/latlong.dart';

abstract class OfflineMapService {
  /// Download map tiles for offline use
  Future<void> downloadMapRegion({
    required LatLng southwest,
    required LatLng northeast,
    required String regionName,
    double minZoom = 10.0,
    double maxZoom = 16.0,
  });

  /// Check if a region is already downloaded
  Future<bool> isRegionDownloaded(String regionName);

  /// Get list of downloaded regions
  Future<List<String>> getDownloadedRegions();

  /// Delete a downloaded region
  Future<void> deleteRegion(String regionName);

  /// Get download progress for a region
  Stream<double> getDownloadProgress(String regionName);

  /// Get total size of offline maps in MB
  Future<double> getTotalOfflineMapSize();
}
