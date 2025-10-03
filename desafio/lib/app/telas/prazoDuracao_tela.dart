import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:desafio/modelo/entidades/prazoDuracao/prazoDuracao.dart';
import 'package:desafio/servicos/prazoDuracao_servico.dart';

class PrazoDuracaoTela extends StatefulWidget {
  final PrazoDuracao? prazoDuracao;

  const PrazoDuracaoTela({Key? key, this.prazoDuracao}) : super(key: key);

  @override
  State<PrazoDuracaoTela> createState() => _PrazoDuracaoTelaState();
}

class _PrazoDuracaoTelaState extends State<PrazoDuracaoTela> {
  final _formKey = GlobalKey<FormState>();
  final _tipoPrazoController = TextEditingController();
  bool _isCarregando = false;

  @override
  void initState() {
    super.initState();
    if (widget.prazoDuracao != null) {
      _tipoPrazoController.text = widget.prazoDuracao!.tipoPrazo ?? '';
    }
  }

  @override
  void dispose() {
    _tipoPrazoController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isCarregando = true);
    final prazoDuracaoServico = Provider.of<PrazoDuracaoServico>(
      context,
      listen: false,
    );

    try {
      bool sucesso;
      if (widget.prazoDuracao == null) {
        sucesso = await prazoDuracaoServico.criarPrazoDuracao(
          tipoPrazo: _tipoPrazoController.text.trim(),
        );
      } else {
        final prazoDuracaoAtualizada = PrazoDuracao(
          id: widget.prazoDuracao!.id,
          tipoPrazo: _tipoPrazoController.text.trim(),
          criadoEm: widget.prazoDuracao!.criadoEm,
          atualizadoEm: DateTime.now(),
        );
        sucesso = await prazoDuracaoServico.atualizarPrazoDuracao(
          prazoDuracaoAtualizada,
        );
      }

      if (sucesso && mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.prazoDuracao == null
                  ? 'Prazo de Duração criado com sucesso'
                  : 'Prazo de Duração atualizado com sucesso',
            ),
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              prazoDuracaoServico.erro ?? 'Erro ao salvar prazo de duração',
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
        widget.prazoDuracao == null
            ? 'Novo Prazo de Duração'
            : 'Editar Prazo de Duração',
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
                  controller: _tipoPrazoController,
                  decoration: const InputDecoration(
                    labelText: 'Tipo de Prazo *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'O tipo de prazo é obrigatório';
                    }
                    return null;
                  },
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
                  : Text(widget.prazoDuracao == null ? 'Criar' : 'Salvar'),
        ),
      ],
    );
  }
}
