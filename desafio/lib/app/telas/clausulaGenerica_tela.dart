import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:desafio/modelo/entidades/clausulaGenerica/clausulaGenerica.dart';
import 'package:desafio/servicos/clausulaGenerica_servico.dart';

class ClausulaGenericaTela extends StatefulWidget {
  final ClausulaGenerica? clausulaGenerica;

  const ClausulaGenericaTela({Key? key, this.clausulaGenerica})
    : super(key: key);

  @override
  State<ClausulaGenericaTela> createState() => _ClausulaGenericaTelaState();
}

class _ClausulaGenericaTelaState extends State<ClausulaGenericaTela> {
  final _formKey = GlobalKey<FormState>();
  final _nomeClausulaController = TextEditingController();
  final _conteudoController = TextEditingController();
  bool _isCarregando = false;

  @override
  void initState() {
    super.initState();
    if (widget.clausulaGenerica != null) {
      _nomeClausulaController.text =
          widget.clausulaGenerica!.nomeClausula ?? '';
      _conteudoController.text = widget.clausulaGenerica!.conteudo ?? '';
    }
  }

  @override
  void dispose() {
    _nomeClausulaController.dispose();
    _conteudoController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isCarregando = true);
    final clausulaGenericaServico = Provider.of<ClausulaGenericaServico>(
      context,
      listen: false,
    );

    try {
      bool sucesso;
      if (widget.clausulaGenerica == null) {
        sucesso = await clausulaGenericaServico.criarClausulaGenerica(
          nomeClausula: _nomeClausulaController.text.trim(),
          conteudo: _conteudoController.text.trim(),
        );
      } else {
        final clausulaGenericaAtualizada = ClausulaGenerica(
          id: widget.clausulaGenerica!.id,
          nomeClausula: _nomeClausulaController.text.trim(),
          conteudo: _conteudoController.text.trim(),
          criadoEm: widget.clausulaGenerica!.criadoEm,
          atualizadoEm: DateTime.now(),
        );
        sucesso = await clausulaGenericaServico.atualizarClausulaGenerica(
          clausulaGenericaAtualizada,
        );
      }

      if (sucesso && mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.clausulaGenerica == null
                  ? 'Cláusula Genérica criada com sucesso'
                  : 'Cláusula Genérica atualizada com sucesso',
            ),
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              clausulaGenericaServico.erro ??
                  'Erro ao salvar cláusula genérica',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCarregando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.clausulaGenerica == null
            ? 'Nova Cláusula Genérica'
            : 'Editar Cláusula Genérica',
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nomeClausulaController,
                  decoration: const InputDecoration(
                    labelText: 'Nome da Cláusula *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'O nome da cláusula é obrigatório';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _conteudoController,
                  decoration: const InputDecoration(
                    labelText: 'Conteúdo da Cláusula *',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'O conteúdo da cláusula é obrigatório';
                    }
                    return null;
                  },
                  maxLines: 5,
                  maxLength: 1000,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isCarregando ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isCarregando ? null : _salvar,
          child:
              _isCarregando
                  ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                  : Text(widget.clausulaGenerica == null ? 'Criar' : 'Salvar'),
        ),
      ],
    );
  }
}
