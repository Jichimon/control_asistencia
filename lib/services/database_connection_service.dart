import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:control_asistencia/models/user.dart';
import 'package:control_asistencia/models/marcaje.dart';

class DBProvider {

  //Singleton Pattern para el constructor
  DBProvider();
  static final DBProvider db = DBProvider();

  //properties
  static Database _database;

  //SQL_Methods
  static final String createTable_User =
      "CREATE TABLE IF NOT EXISTS users("
      "id INTEGER PRIMARY KEY AUTOINCREMENT,"
      "name TEXT NOT NULL,"
      "phoneNumber INTEGER"
      ");";

  static final String createTable_Marcaje =
    "CREATE TABLE IF NOT EXISTS marcaje("
      "id INTEGER PRIMARY KEY AUTOINCREMENT,"
      "date TEXT NOT NULL,"
      "userId INTEGER NOT NULL,"
      "FOREIGN KEY(userId) REFERENCES users(id)"
      "ON DELETE CASCADE"
      "ON UPDATE CASCADE"
      ");";

  //_________________methods________________________

  //accediendo a la base de datos
  Future<Database> get database async {
    if (_database != null) {
      return _database;
    }
    //si la base de datos no existe, la creamos con
    _database = await initDB();
    return _database;
  }

  initDB() async {
    String db_name = "marcajeDB";
    String path = join(await getDatabasesPath(), db_name);

    return await openDatabase(path, version: 1,
      onCreate: onCreate,
    );
  }

  FutureOr<void> onCreate(Database db, int version) async{
    String createTables = createTable_User + "\n" + createTable_Marcaje;
    return db.execute(createTables);
  }

  //_______CRUD Methods______________________
  //user
  Future<void> insertUser(User newUser) async{
    final Database db = await database;
    var res = await db.insert(
        "users",
        newUser.toMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore);
        //si el user ya existe, simplemente ignorará la nueva llamada
    return res;
  }

  Future<User> getUser(int id) async{
    final Database db = await database;
    var res = await db.query(
      "users",
      where: "id = ?",
      whereArgs: [id]);
    //el map que recibí lo convierto a instancia de User
    return res.isEmpty ? null : User.fromMap(res.first);
  }

  Future<List<User>> getAllUsers() async {
    final Database db = await database;
    var res = await db.query("users");
    List<User> list =
        //cada map que recibí lo convierto en User, y lo pongo en una lista
        res.isNotEmpty ? res.map((e) => User.fromMap(e)).toList() : [];
    return list;
  }

  Future<void> deleteUser(int id) async{
    final Database db = await database;
    await db.delete(
      "users",
      where: "id = ?",
      whereArgs: [id],
    );
  }

  //marcaje
  Future<void> insertMarcaje(Marcaje newMarcaje) async{
    final Database db = await database;
    var res = await db.insert(
        "marcaje",
        newMarcaje.toMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore);
    //si el user ya existe, simplemente ignorará la nueva llamada
    return res;
  }

  Future<Marcaje> getMarcaje(int id) async{
    final Database db = await database;
    var res = await db.query(
        "marcaje",
        where: "id = ?",
        whereArgs: [id]);
    //el map que recibí lo convierto a instancia de Marcaje
    return res.isEmpty ? null : Marcaje.fromMap(res.first);
  }

  Future<List<Marcaje>> getAllMarcajes() async {
    final Database db = await database;
    var res = await db.query("marcaje");
    List<Marcaje> list =
    //cada map que recibí lo convierto en User, y lo pongo en una lista
    res.isNotEmpty ? res.map((e) => Marcaje.fromMap(e)).toList() : [];
    return list;
  }



}