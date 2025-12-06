import 'package:drift/drift.dart';

import 'package:promoruta/core/models/gps_point.dart' as model;
import 'package:promoruta/core/models/route.dart' as model_route;
import '../../../domain/repositories/gps_repository.dart';
import 'package:promoruta/shared/datasources/local/db/database.dart';

class GpsLocalDataSourceImpl implements GpsLocalDataSource {
  final AppDatabase db;

  GpsLocalDataSourceImpl(this.db);

  @override
  Future<void> saveRoute(model_route.Route route) async {
    await db.into(db.routes).insertOnConflictUpdate(
      RoutesCompanion(
        id: Value(route.id),
        promoterId: Value(route.promoterId),
        campaignId: Value(route.campaignId),
        startTime: Value(route.startTime),
        endTime: Value(route.endTime),
        isCompleted: Value(route.isCompleted),
      ),
    );
  }

  @override
  Future<List<model_route.Route>> getRoutes() async {
    final routeRows = await db.select(db.routes).get();
    final routes = <model_route.Route>[];

    for (final routeRow in routeRows) {
      final points = await getGpsPoints(routeRow.id);
      routes.add(model_route.Route(
        id: routeRow.id,
        promoterId: routeRow.promoterId,
        campaignId: routeRow.campaignId,
        startTime: routeRow.startTime,
        endTime: routeRow.endTime,
        points: points,
        isCompleted: routeRow.isCompleted,
      ));
    }

    return routes;
  }

  @override
  Future<model_route.Route?> getRoute(String id) async {
    final routeRow = await (db.select(db.routes)
      ..where((tbl) => tbl.id.equals(id)))
      .getSingleOrNull();

    if (routeRow == null) return null;

    final points = await getGpsPoints(id);
    return model_route.Route(
      id: routeRow.id,
      promoterId: routeRow.promoterId,
      campaignId: routeRow.campaignId,
      startTime: routeRow.startTime,
      endTime: routeRow.endTime,
      points: points,
      isCompleted: routeRow.isCompleted,
    );
  }

  @override
  Future<void> saveGpsPoint(model.GpsPoint point) async {
    await db.into(db.gpsPoints).insertOnConflictUpdate(
      GpsPointsCompanion(
        id: Value(point.id),
        routeId: Value(point.routeId),
        latitude: Value(point.latitude),
        longitude: Value(point.longitude),
        timestamp: Value(point.timestamp),
        speed: Value(point.speed),
        accuracy: Value(point.accuracy),
      ),
    );
  }

  Future<void> saveGpsPoints(List<model.GpsPoint> points) async {
    await db.batch((batch) {
      for (final point in points) {
        batch.insert(
          db.gpsPoints,
          GpsPointsCompanion(
            id: Value(point.id),
            routeId: Value(point.routeId),
            latitude: Value(point.latitude),
            longitude: Value(point.longitude),
            timestamp: Value(point.timestamp),
            speed: Value(point.speed),
            accuracy: Value(point.accuracy),
          ),
        );
      }
    });
  }

  @override
  Future<List<model.GpsPoint>> getGpsPoints(String routeId) async {
    final pointRows = await (db.select(db.gpsPoints)
      ..where((tbl) => tbl.routeId.equals(routeId)))
      .get();

    return pointRows.map((row) => model.GpsPoint(
      id: row.id,
      routeId: row.routeId,
      latitude: row.latitude,
      longitude: row.longitude,
      timestamp: row.timestamp,
      speed: row.speed,
      accuracy: row.accuracy,
    )).toList();
  }

  @override
  Future<void> updateRoute(model_route.Route route) async {
    await (db.update(db.routes)
      ..where((tbl) => tbl.id.equals(route.id)))
      .write(RoutesCompanion(
        endTime: Value(route.endTime),
        isCompleted: Value(route.isCompleted),
      ));
  }

  @override
  Future<void> deleteRoute(String id) async {
    await (db.delete(db.routes)
      ..where((tbl) => tbl.id.equals(id)))
      .go();
  }

  Future<List<model_route.Route>> getPendingSyncRoutes() async {
    final routeRows = await (db.select(db.routes)
      ..where((tbl) => tbl.isCompleted.equals(true)))
      .get();

    final routes = <model_route.Route>[];
    for (final routeRow in routeRows) {
      final points = await getGpsPoints(routeRow.id);
      routes.add(model_route.Route(
        id: routeRow.id,
        promoterId: routeRow.promoterId,
        campaignId: routeRow.campaignId,
        startTime: routeRow.startTime,
        endTime: routeRow.endTime,
        points: points,
        isCompleted: routeRow.isCompleted,
      ));
    }

    return routes;
  }
}