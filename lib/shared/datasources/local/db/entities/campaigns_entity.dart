import 'package:drift/drift.dart';

class CampaignsEntity extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get description => text()();
  TextColumn get createdById => text()();
  DateTimeColumn get startTime => dateTime()();
  DateTimeColumn get endTime => dateTime()();
  TextColumn get status => text().withDefault(const Constant('active'))();
  TextColumn get zone => text().withDefault(const Constant(''))();
  RealColumn get suggestedPrice => real().withDefault(const Constant(0.0))();

  @override
  Set<Column> get primaryKey => {id};
}
