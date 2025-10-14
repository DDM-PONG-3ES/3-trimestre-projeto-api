import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:desafio/modelo/entidades/clausulaGenerica/clausulaGenerica.dart';
import 'package:desafio/servicos/clausulaGenerica_servico.dart';

class ClausulaGenericaTela extends StatefulWidget {
  final ClausulaGenerica? clausulaGenerica;
  const ClausulaGenericaTela({Key? key, this.clausulaGenerica}) : super(key: key);

  @override
  State<ClausulaGenericaTela> createState() => _ClausulaGenericaTelaState();
}

class _ClausulaGenericaTelaState extends State<ClausulaGenericaTela> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _conteudoController = TextEditingController();
  bool _isCarregando = false;

  @override
  void initState() {
    super.initState();
    if (widget.clausulaGenerica != null) {
      _nomeController.text = widget.clausulaGenerica!.nomeClausula ?? '';
      _conteudoController.text = widget.clausulaGenerica!.conteudo ?? '';
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _conteudoController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isCarregando = true);
    final servico = Provider.of<ClausulaGenericaServico>(context, listen: false);

    try {
      final sucesso = widget.clausulaGenerica == null
          ? await servico.criarClausulaGenerica(
              nomeClausula: _nomeController.text.trim(),
              conteudo: _conteudoController.text.trim(),
            )
          : await servico.atualizarClausulaGenerica(
              ClausulaGenerica(
                id: widget.clausulaGenerica!.id,
                nomeClausula: _nomeController.text.trim(),
                conteudo: _conteudoController.text.trim(),
                criadoEm: widget.clausulaGenerica!.criadoEm,
                atualizadoEm: DateTime.now(),
              ),
            );

      if (mounted) {
        if (sucesso) {
          Navigator.pop(context);
          _showSnack(widget.clausulaGenerica == null ? 'Criada com sucesso' : 'Atualizada com sucesso', false);
        } else {
          _showSnack(servico.erro ?? 'Erro ao salvar', true);
        }
      }
    } finally {
      if (mounted) setState(() => _isCarregando = false);
    }
  }

  void _showSnack(String msg, bool isError) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.clausulaGenerica != null;
    
    return AlertDialog(
      title: Row(
        children: [
          Icon(isEdit ? Icons.edit : Icons.add_circle_outline),
          const SizedBox(width: 12),
          Text(isEdit ? 'Editar Cláusula' : 'Nova Cláusula'),
        ],
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: InputDecoration(
                  labelText: 'Nome da Cláusula *',
                  prefixIcon: const Icon(Icons.label_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                validator: (v) => v?.trim().isEmpty ?? true ? 'Campo obrigatório' : null,
                maxLength: 100,
                enabled: !_isCarregando,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _conteudoController,
                decoration: InputDecoration(
                  labelText: 'Conteúdo *',
                  prefixIcon: const Icon(Icons.description_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  alignLabelWithHint: true,
                ),
                validator: (v) => v?.trim().isEmpty ?? true ? 'Campo obrigatório' : null,
                maxLines: 5,
                maxLength: 1000,
                enabled: !_isCarregando,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isCarregando ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isCarregando ? null : _salvar,
          child: _isCarregando
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(isEdit ? 'Salvar' : 'Criar'),
        ),
      ],
    );
  }
}