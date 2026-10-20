import 'package:sqflite/sql.dart';

import 'conexao.dart';
import '../models/usuario.dart';

class BancoUsuario {
  static Future<void> inserirUsuario(Usuario usuario) async {
    final db = await Conexao.abrirConexao();
    final dados = usuario.toMap()..remove('id');
    await db.insert(
      'usuarios',
      dados,
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  static Future<bool> emailJaExiste(String email) async {
    final db = await Conexao.abrirConexao();
    final resultado = await db.query(
      'usuarios',
      where: 'email = ?',
      whereArgs: [email],
    );
    return resultado.isNotEmpty;
  }

  static Future<Usuario?> login(String email, String senha) async {
    final db = await Conexao.abrirConexao();
    final resultado = await db.query(
      'usuarios',
      where: 'email = ? AND senha = ?',
      whereArgs: [email, senha],
    );
    if (resultado.isEmpty) return null;
    return Usuario.fromMap(resultado.first);
  }
}