import 'package:drift/drift.dart';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:drift/native.dart';

part 'database.g.dart';

class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get description => text().withLength(min: 1, max: 100)();
  RealColumn get amount => real()();
  DateTimeColumn get date => dateTime()();
  IntColumn get categoryId => integer().nullable()();
}

class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get description => text().withLength(min: 1, max: 50)();
}

@DriftDatabase(tables: [Transactions, Categories])
class AppDatabase extends _$AppDatabase {
  AppDatabase({QueryExecutor? executor}) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  // the LazyDatabase util lets us find the right location for the file async.
  return LazyDatabase(() async {
    // put the database file, called db.sqlite here, into the documents folder
    // for your app.
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}