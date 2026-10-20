import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/bancoPessoa.dart';
import '../models/pessoa.dart';
import 'login_screen.dart';
import 'pessoa_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _buscaController = TextEditingController();
  String _nomeUsuario = '';
  List<Pessoa> _pessoas = [];

  @override
  void initState() {
    super.initState();
    _carregarNome();
    _carregarPessoas();
  }

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  // Lista já filtrada pelo texto da busca
  List<Pessoa> get _pessoasFiltradas {
    final texto = _buscaController.text.trim().toLowerCase();
    if (texto.isEmpty) return _pessoas;
    return _pessoas
        .where((p) =>
            p.nome.toLowerCase().contains(texto) ||
            p.email.toLowerCase().contains(texto))
        .toList();
  }

  Future<void> _carregarNome() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nomeUsuario = prefs.getString('nome_usuario') ?? '';
    });
  }

  Future<void> _carregarPessoas() async {
    final lista = await BancoPessoa.listarPessoas();
    setState(() {
      _pessoas = lista;
    });
  }

  Future<void> _abrirFormulario({Pessoa? pessoa}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PessoaFormScreen(pessoa: pessoa)),
    );
    _carregarPessoas(); // atualiza a lista ao voltar
  }

  Future<void> _excluirPessoa(Pessoa pessoa) async {
    await BancoPessoa.excluirPessoa(pessoa);
    setState(() {
      _pessoas.removeWhere((p) => p.id == pessoa.id);
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${pessoa.nome} foi excluído(a).')),
    );
  }

  Future<void> _sair() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('nome_usuario');
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    const azul = Color(0xFF2570E0);
    final lista = _pessoasFiltradas;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Home',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: _sair,
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: Text(
              'Olá, $_nomeUsuario!',
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _buscaController,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                hintText: 'Buscar pessoa',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Text(
              'Pessoas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: lista.isEmpty
                ? const Center(child: Text('Nenhuma pessoa encontrada.'))
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 90),
                    itemCount: lista.length,
                    itemBuilder: (context, index) {
                      final pessoa = lista[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Dismissible(
                            key: ValueKey(pessoa.id),
                            direction: DismissDirection.horizontal,
                            background: Container(
                              color: Colors.red,
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.only(left: 20),
                              child:
                                  const Icon(Icons.delete, color: Colors.white),
                            ),
                            secondaryBackground: Container(
                              color: Colors.red,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              child:
                                  const Icon(Icons.delete, color: Colors.white),
                            ),
                            onDismissed: (_) => _excluirPessoa(pessoa),
                            child: Material(
                              color: Colors.white,
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 6,
                                ),
                                leading: const CircleAvatar(
                                  radius: 24,
                                  backgroundColor: Color(0xFFD6E4FA),
                                  child: Icon(Icons.person, color: azul),
                                ),
                                title: Text(
                                  pessoa.nome,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: Text(
                                  '${pessoa.idade} anos • ${pessoa.telefone}\n${pessoa.email}',
                                ),
                                isThreeLine: true,
                                trailing: PopupMenuButton<String>(
                                  onSelected: (valor) {
                                    if (valor == 'editar') {
                                      _abrirFormulario(pessoa: pessoa);
                                    } else if (valor == 'excluir') {
                                      _excluirPessoa(pessoa);
                                    }
                                  },
                                  itemBuilder: (_) => const [
                                    PopupMenuItem(
                                      value: 'editar',
                                      child: Text('Editar'),
                                    ),
                                    PopupMenuItem(
                                      value: 'excluir',
                                      child: Text('Excluir'),
                                    ),
                                  ],
                                ),
                                onTap: () => _abrirFormulario(pessoa: pessoa),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _abrirFormulario(),
        child: const Icon(Icons.add),
      ),
    );
  }
}