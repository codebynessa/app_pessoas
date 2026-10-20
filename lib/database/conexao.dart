import 'package:hive_flutter/hive_flutter.dart';

class Conexao {
  // Chamado uma vez no main(): prepara o Hive e abre as "caixas" (boxes)
  static Future<void> iniciar() async {
    await Hive.initFlutter();
    await Hive.openBox('usuarios');
    await Hive.openBox('pessoas');
  }

  static Box get usuarios => Hive.box('usuarios');
  static Box get pessoas => Hive.box('pessoas');
}