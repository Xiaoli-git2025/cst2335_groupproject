// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

abstract class $AppDatabaseBuilderContract {
  /// Adds migrations to the builder.
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations);

  /// Adds a database [Callback] to the builder.
  $AppDatabaseBuilderContract addCallback(Callback callback);

  /// Creates the database and initializes it.
  Future<AppDatabase> build();
}

// ignore: avoid_classes_with_only_static_members
class $FloorAppDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract databaseBuilder(String name) =>
      _$AppDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract inMemoryDatabaseBuilder() =>
      _$AppDatabaseBuilder(null);
}

class _$AppDatabaseBuilder implements $AppDatabaseBuilderContract {
  _$AppDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  @override
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  @override
  $AppDatabaseBuilderContract addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  @override
  Future<AppDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$AppDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$AppDatabase extends AppDatabase {
  _$AppDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  SalesItemsDao? _salesItemsDaoInstance;

  CustomerItemsDao? _customerItemsDaoInstance;

  AirplaneItemsDao? _airplaneItemsDaoInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `SalesItem` (`id` INTEGER NOT NULL, `customer_id` INTEGER NOT NULL, `car_id` INTEGER NOT NULL, `dealership_id` INTEGER NOT NULL, `purchase_date` TEXT NOT NULL, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `CustomerItem` (`id` INTEGER NOT NULL, `firstname` TEXT NOT NULL, `lastname` TEXT NOT NULL, `address` TEXT NOT NULL, `dateOfBirth` TEXT NOT NULL, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `AirplaneItem` (`id` INTEGER, `airplane_model` TEXT NOT NULL, `max_passengers` INTEGER NOT NULL, `max_speed` INTEGER NOT NULL, `max_mileage` INTEGER NOT NULL, PRIMARY KEY (`id`))');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  SalesItemsDao get salesItemsDao {
    return _salesItemsDaoInstance ??= _$SalesItemsDao(database, changeListener);
  }

  @override
  CustomerItemsDao get customerItemsDao {
    return _customerItemsDaoInstance ??=
        _$CustomerItemsDao(database, changeListener);
  }

  @override
  AirplaneItemsDao get airplaneItemsDao {
    return _airplaneItemsDaoInstance ??=
        _$AirplaneItemsDao(database, changeListener);
  }
}

class _$SalesItemsDao extends SalesItemsDao {
  _$SalesItemsDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _salesItemInsertionAdapter = InsertionAdapter(
            database,
            'SalesItem',
            (SalesItem item) => <String, Object?>{
                  'id': item.id,
                  'customer_id': item.customer_id,
                  'car_id': item.car_id,
                  'dealership_id': item.dealership_id,
                  'purchase_date': item.purchase_date
                }),
        _salesItemDeletionAdapter = DeletionAdapter(
            database,
            'SalesItem',
            ['id'],
            (SalesItem item) => <String, Object?>{
                  'id': item.id,
                  'customer_id': item.customer_id,
                  'car_id': item.car_id,
                  'dealership_id': item.dealership_id,
                  'purchase_date': item.purchase_date
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<SalesItem> _salesItemInsertionAdapter;

  final DeletionAdapter<SalesItem> _salesItemDeletionAdapter;

  @override
  Future<List<SalesItem>> findAllItems() async {
    return _queryAdapter.queryList('SELECT * FROM SalesItem',
        mapper: (Map<String, Object?> row) => SalesItem(
            row['id'] as int,
            row['customer_id'] as int,
            row['car_id'] as int,
            row['dealership_id'] as int,
            row['purchase_date'] as String));
  }

  @override
  Future<void> insertItem(SalesItem item) async {
    await _salesItemInsertionAdapter.insert(item, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteItem(SalesItem item) async {
    await _salesItemDeletionAdapter.delete(item);
  }
}

class _$CustomerItemsDao extends CustomerItemsDao {
  _$CustomerItemsDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _customerItemInsertionAdapter = InsertionAdapter(
            database,
            'CustomerItem',
            (CustomerItem item) => <String, Object?>{
                  'id': item.id,
                  'firstname': item.firstname,
                  'lastname': item.lastname,
                  'address': item.address,
                  'dateOfBirth': item.dateOfBirth
                }),
        _customerItemDeletionAdapter = DeletionAdapter(
            database,
            'CustomerItem',
            ['id'],
            (CustomerItem item) => <String, Object?>{
                  'id': item.id,
                  'firstname': item.firstname,
                  'lastname': item.lastname,
                  'address': item.address,
                  'dateOfBirth': item.dateOfBirth
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<CustomerItem> _customerItemInsertionAdapter;

  final DeletionAdapter<CustomerItem> _customerItemDeletionAdapter;

  @override
  Future<List<CustomerItem>> findAllItems() async {
    return _queryAdapter.queryList('SELECT * FROM CustomerItem',
        mapper: (Map<String, Object?> row) => CustomerItem(
            row['id'] as int,
            row['firstname'] as String,
            row['lastname'] as String,
            row['address'] as String,
            row['dateOfBirth'] as String));
  }

  @override
  Future<CustomerItem?> findItemById(int id) async {
    return _queryAdapter.query('SELECT * FROM CustomerItem WHERE id = ?1',
        mapper: (Map<String, Object?> row) => CustomerItem(
            row['id'] as int,
            row['firstname'] as String,
            row['lastname'] as String,
            row['address'] as String,
            row['dateOfBirth'] as String),
        arguments: [id]);
  }

  @override
  Future<void> insertItem(CustomerItem item) async {
    await _customerItemInsertionAdapter.insert(item, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteItem(CustomerItem item) async {
    await _customerItemDeletionAdapter.delete(item);
  }
}

class _$AirplaneItemsDao extends AirplaneItemsDao {
  _$AirplaneItemsDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _airplaneItemInsertionAdapter = InsertionAdapter(
            database,
            'AirplaneItem',
            (AirplaneItem item) => <String, Object?>{
                  'id': item.id,
                  'airplane_model': item.airplane_model,
                  'max_passengers': item.max_passengers,
                  'max_speed': item.max_speed,
                  'max_mileage': item.max_mileage
                }),
        _airplaneItemDeletionAdapter = DeletionAdapter(
            database,
            'AirplaneItem',
            ['id'],
            (AirplaneItem item) => <String, Object?>{
                  'id': item.id,
                  'airplane_model': item.airplane_model,
                  'max_passengers': item.max_passengers,
                  'max_speed': item.max_speed,
                  'max_mileage': item.max_mileage
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<AirplaneItem> _airplaneItemInsertionAdapter;

  final DeletionAdapter<AirplaneItem> _airplaneItemDeletionAdapter;

  @override
  Future<List<AirplaneItem>> findAllItems() async {
    return _queryAdapter.queryList('SELECT * FROM AirplaneItem',
        mapper: (Map<String, Object?> row) => AirplaneItem(
            row['id'] as int?,
            row['airplane_model'] as String,
            row['max_passengers'] as int,
            row['max_speed'] as int,
            row['max_mileage'] as int));
  }

  @override
  Future<void> insertItem(AirplaneItem item) async {
    await _airplaneItemInsertionAdapter.insert(item, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteItem(AirplaneItem item) async {
    await _airplaneItemDeletionAdapter.delete(item);
  }
}
