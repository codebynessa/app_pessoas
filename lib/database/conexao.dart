import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Conexao {
  static Future<Database> abrirConexao() async {
    final caminhoBanco = await getDatabasesPath();
    final caminhoCompleto = join(caminhoBanco, 'pessoas.db');

    return await openDatabase(
      caminhoCompleto,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE usuarios (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nome TEXT NOT NULL,
            email TEXT NOT NULL UNIQUE,
            senha TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE pessoas (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nome TEXT NOT NULL,
            idade INTEGER NOT NULL,
            email TEXT NOT NULL,
            telefone TEXT NOT NULL
          )
        ''');
      },
    );
  }
}