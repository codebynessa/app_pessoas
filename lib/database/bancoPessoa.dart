import 'package:sqflite/sql.dart';

import 'conexao.dart';
import '../models/pessoa.dart';

class BancoPessoa {
  static Future<void> inserirPessoa(Pessoa pessoa) async {
    final db = await Conexao.abrirConexao();
    final dados = pessoa.toMap()..remove('id');
    await db.insert(
      'pessoas',
      dados,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<Pessoa>> listarPessoas() async {
    final db = await Conexao.abrirConexao();
    final List<Map<String, dynamic>> maps = await db.query('pessoas');

    return List.generate(maps.length, (i) {
      return Pessoa.fromMap(maps[i]);
    });
  }

  static Future<void> atualizarPessoa(Pessoa pessoa) async {
    final db = await Conexao.abrirConexao();
    await db.update(
      'pessoas',
      pessoa.toMap(),
      where: 'id = ?',
      whereArgs: [pessoa.id],
    );
  }

  static Future<void> excluirPessoa(Pessoa pessoa) async {
    final db = await Conexao.abrirConexao();
    await db.delete('pessoas', where: 'id = ?', whereArgs: [pessoa.id]);
  }
}