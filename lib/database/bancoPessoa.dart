import 'package:hive_flutter/hive_flutter.dart';

import 'conexao.dart';
import '../models/pessoa.dart';

class BancoPessoa {
  static Box get _box => Conexao.pessoas;

  static Future<void> inserirPessoa(Pessoa pessoa) async {
    final dados = pessoa.toMap();
    // add() cria uma chave automática (0, 1, 2...) e devolve ela
    final chave = await _box.add(dados);
    // guarda a chave também como "id" da pessoa
    dados['id'] = chave;
    await _box.put(chave, dados);
  }

  static Future<List<Pessoa>> listarPessoas() async {
    final lista = _box.values
        .map((m) => Pessoa.fromMap(Map<String, dynamic>.from(m as Map)))
        .toList();
    lista.sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));
    return lista;
  }

  static Future<void> atualizarPessoa(Pessoa pessoa) async {
    await _box.put(pessoa.id, pessoa.toMap());
  }

  static Future<void> excluirPessoa(Pessoa pessoa) async {
    await _box.delete(pessoa.id);
  }
}