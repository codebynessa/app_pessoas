import 'package:flutter/material.dart';
import '../database/bancoPessoa.dart';
import '../models/pessoa.dart';

class PessoaFormScreen extends StatefulWidget {
  final Pessoa? pessoa; // null = nova pessoa; preenchido = edição

  const PessoaFormScreen({super.key, this.pessoa});

  @override
  State<PessoaFormScreen> createState() => _PessoaFormScreenState();
}

class _PessoaFormScreenState extends State<PessoaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nomeController;
  late final TextEditingController _idadeController;
  late final TextEditingController _telefoneController;
  late final TextEditingController _emailController;

  bool get _editando => widget.pessoa != null;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.pessoa?.nome ?? '');
    _idadeController =
        TextEditingController(text: widget.pessoa?.idade.toString() ?? '');
    _telefoneController =
        TextEditingController(text: widget.pessoa?.telefone ?? '');
    _emailController = TextEditingController(text: widget.pessoa?.email ?? '');
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _idadeController.dispose();
    _telefoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    final pessoa = Pessoa(
      id: widget.pessoa?.id ?? 0,
      nome: _nomeController.text.trim(),
      email: _emailController.text.trim(),
      idade: int.parse(_idadeController.text.trim()),
      telefone: _telefoneController.text.trim(),
    );

    if (_editando) {
      await BancoPessoa.atualizarPessoa(pessoa);
    } else {
      await BancoPessoa.inserirPessoa(pessoa);
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_editando
            ? 'Pessoa atualizada com sucesso!'
            : 'Pessoa salva com sucesso!'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_editando ? 'Editar pessoa' : 'Nova pessoa'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Informe o nome' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _idadeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Idade',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Informe a idade';
                  if (int.tryParse(v.trim()) == null) return 'Idade inválida';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _telefoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Telefone',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Informe o telefone'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'E-mail',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || !v.contains('@')) ? 'E-mail inválido' : null,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _salvar,
                  child: Text(_editando ? 'Atualizar' : 'Salvar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}