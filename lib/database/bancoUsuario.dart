import 'package:hive_flutter/hive_flutter.dart';

import 'conexao.dart';
import '../models/usuario.dart';

class BancoUsuario {
  static Box get _box => Conexao.usuarios;

  static Future<void> inserirUsuario(Usuario usuario) async {
    final dados = usuario.toMap();
    final chave = await _box.add(dados);
    dados['id'] = chave;
    await _box.put(chave, dados);
  }

  static Future<bool> emailJaExiste(String email) async {
    return _box.values.any((m) => (m as Map)['email'] == email);
  }

  static Future<Usuario?> login(String email, String senha) async {
    for (final m in _box.values) {
      final mapa = Map<String, dynamic>.from(m as Map);
      if (mapa['email'] == email && mapa['senha'] == senha) {
        return Usuario.fromMap(mapa);
      }
    }
    return null;
  }
}