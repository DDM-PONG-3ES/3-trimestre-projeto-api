import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final _mesesController = TextEditingController();
  final _descricaoController = TextEditingController();
  bool _isCarregando = false;
  String _tipo = 'determinado';
  bool _renovavel = false;

  @override
  void initState() {
    super.initState();
    if (widget.prazoDuracao != null) _parseExistingValue(widget.prazoDuracao!.tipoPrazo ?? '');
  }

  void _parseExistingValue(String prazo) {
    if (prazo.contains('Indeterminado')) {
      _tipo = 'indeterminado';
    } else if (prazo.contains('projeto')) {
      _tipo = 'projeto';
      final match = RegExp(r'projeto:\s*(.+)').firstMatch(prazo);
      if (match != null) _descricaoController.text = match.group(1) ?? '';
    } else {
      final match = RegExp(r'(\d+)\s*meses?').firstMatch(prazo);
      if (match != null) _mesesController.text = match.group(1) ?? '';
      _renovavel = prazo.contains('Renovável');
    }
  }

  @override
  void dispose() {
    _mesesController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  String _gerarPrazo() {
    if (_tipo == 'indeterminado') return 'Prazo Indeterminado';
    if (_tipo == 'projeto') return 'Até conclusão do projeto: ${_descricaoController.text.trim()}';
    
    final meses = int.parse(_mesesController.text);
    final anos = meses ~/ 12;
    final resto = meses % 12;
    String prazo = 'Prazo Determinado - ';
    
    prazo += anos > 0
        ? '$anos ${anos == 1 ? 'ano' : 'anos'}${resto > 0 ? ' e $resto ${resto == 1 ? 'mês' : 'meses'}' : ''}'
        : '$meses ${meses == 1 ? 'mês' : 'meses'}';
    
    return _renovavel ? '$prazo (Renovável automaticamente)' : prazo;
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isCarregando = true);
    final servico = Provider.of<PrazoDuracaoServico>(context, listen: false);

    try {
      final prazo = _gerarPrazo();
      final sucesso = widget.prazoDuracao == null
          ? await servico.criarPrazoDuracao(tipoPrazo: prazo)
          : await servico.atualizarPrazoDuracao(PrazoDuracao(
              id: widget.prazoDuracao!.id,
              tipoPrazo: prazo,
              criadoEm: widget.prazoDuracao!.criadoEm,
              atualizadoEm: DateTime.now(),
            ));

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(sucesso ? '${widget.prazoDuracao == null ? 'Criado' : 'Atualizado'} com sucesso' : servico.erro ?? 'Erro'),
          backgroundColor: sucesso ? Colors.green : Colors.red,
        ));
      }
    } finally {
      if (mounted) setState(() => _isCarregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(widget.prazoDuracao != null ? Icons.edit_calendar : Icons.schedule),
          const SizedBox(width: 12),
          Text(widget.prazoDuracao != null ? 'Editar Prazo' : 'Novo Prazo'),
        ],
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.7,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                children: ['determinado', 'indeterminado', 'projeto'].map((t) => 
                  ChoiceChip(
                    label: Text(t == 'determinado' ? 'Determinado' : t == 'indeterminado' ? 'Indeterminado' : 'Até Projeto'),
                    selected: _tipo == t,
                    onSelected: (v) => setState(() {
                      _tipo = t;
                      _mesesController.clear();
                      _descricaoController.clear();
                      _renovavel = false;
                    }),
                  ),
                ).toList(),
              ),
              const SizedBox(height: 16),
              if (_tipo == 'determinado') ...[
                TextFormField(
                  controller: _mesesController,
                  decoration: const InputDecoration(labelText: 'Meses *', prefixIcon: Icon(Icons.calendar_month)),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (v) {
                    if (v?.isEmpty ?? true) return 'Obrigatório';
                    final n = int.tryParse(v!);
                    return (n == null || n < 1 || n > 600) ? '1 a 600' : null;
                  },
                ),
                Wrap(spacing: 6, children: [6, 12, 24, 36, 60].map((m) => 
                  ActionChip(label: Text('${m}m'), onPressed: () => setState(() => _mesesController.text = '$m'))).toList()),
                CheckboxListTile(
                  value: _renovavel,
                  onChanged: (v) => setState(() => _renovavel = v ?? false),
                  title: const Text('Renovável'),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ] else if (_tipo == 'projeto')
                TextFormField(
                  controller: _descricaoController,
                  decoration: const InputDecoration(labelText: 'Projeto *', prefixIcon: Icon(Icons.work_outline)),
                  validator: (v) => v?.trim().isEmpty ?? true ? 'Obrigatório' : null,
                  maxLength: 200,
                  maxLines: 2,
                )
              else
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8)),
                  child: const Row(children: [Icon(Icons.all_inclusive, color: Colors.green), SizedBox(width: 12), Expanded(child: Text('Sem data de término'))]),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: _isCarregando ? null : () => Navigator.pop(context), child: const Text('Cancelar')),
        ElevatedButton(
          onPressed: _isCarregando ? null : _salvar,
          child: _isCarregando ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : Text(widget.prazoDuracao != null ? 'Salvar' : 'Criar'),
        ),
      ],
    );
  }
}