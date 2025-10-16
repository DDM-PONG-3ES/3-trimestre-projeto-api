import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:desafio/modelo/entidades/prazoDuracao/prazoDuracao.dart';
import 'package:desafio/servicos/prazoDuracao_servico.dart';

class PrazosDuracaoTela extends StatefulWidget {
  const PrazosDuracaoTela({super.key});

  @override
  State<PrazosDuracaoTela> createState() => _PrazosDuracaoTelaState();
}

class _PrazosDuracaoTelaState extends State<PrazosDuracaoTela> {
  final _pesquisaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PrazoDuracaoServico>().carregarPrazosDuracao();
    });
  }

  @override
  void dispose() {
    _pesquisaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prazos de Duração'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _pesquisaController,
              decoration: InputDecoration(
                labelText: 'Pesquisar prazos',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _pesquisaController.clear();
                    setState(() {});
                  },
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          Expanded(child: _buildLista()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarDialog(),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildLista() {
    return Consumer<PrazoDuracaoServico>(
      builder: (context, servico, _) {
        if (servico.isCarregando) {
          return const Center(child: CircularProgressIndicator());
        }

        var prazos = servico.prazosDuracao;
        if (_pesquisaController.text.isNotEmpty) {
          prazos = prazos.where((p) =>
            p.tipoPrazo?.toLowerCase().contains(_pesquisaController.text.toLowerCase()) ?? false
          ).toList();
        }

        if (prazos.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.schedule, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text('Nenhum prazo cadastrado', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => _mostrarDialog(),
                  icon: const Icon(Icons.add),
                  label: const Text('Criar primeiro prazo'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: servico.carregarPrazosDuracao,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: prazos.length,
            itemBuilder: (context, index) {
              final prazo = prazos[index];
              final isIndet = prazo.tipoPrazo?.contains('Indeterminado') ?? false;
              final isProj = prazo.tipoPrazo?.contains('projeto') ?? false;
              
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isIndet ? Colors.green : isProj ? Colors.orange : Theme.of(context).primaryColor,
                    child: Icon(
                      isIndet ? Icons.all_inclusive : isProj ? Icons.work_outline : Icons.schedule,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(prazo.tipoPrazo ?? 'Não informado', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Criado ${_formatarData(prazo.criadoEm)}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  trailing: PopupMenuButton<String>(
                    onSelected: (v) => v == 'editar' ? _mostrarDialog(prazo: prazo) : _excluir(prazo),
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'editar', child: ListTile(leading: Icon(Icons.edit), title: Text('Editar'), contentPadding: EdgeInsets.zero)),
                      PopupMenuItem(value: 'excluir', child: ListTile(leading: Icon(Icons.delete, color: Colors.red), title: Text('Excluir', style: TextStyle(color: Colors.red)), contentPadding: EdgeInsets.zero)),
                    ],
                  ),
                  onTap: () => _mostrarDialog(prazo: prazo),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _mostrarDialog({PrazoDuracao? prazo}) {
    showDialog(context: context, builder: (context) => _PrazoDuracaoDialog(prazoDuracao: prazo));
  }

  Future<void> _excluir(PrazoDuracao prazo) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: const Text('Tem certeza que deseja excluir este prazo?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Excluir', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmar == true && mounted) {
      final servico = context.read<PrazoDuracaoServico>();
      final sucesso = await servico.excluirPrazoDuracao(prazo.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(sucesso ? 'Excluído com sucesso' : servico.erro ?? 'Erro'), backgroundColor: sucesso ? null : Colors.red),
        );
      }
    }
  }

  String _formatarData(DateTime? data) {
    if (data == null) return 'Não informada';
    final dif = DateTime.now().difference(data);
    if (dif.inDays > 7) return '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}';
    if (dif.inDays > 0) return '${dif.inDays} dia${dif.inDays == 1 ? '' : 's'} atrás';
    if (dif.inHours > 0) return '${dif.inHours}h atrás';
    return dif.inMinutes > 0 ? '${dif.inMinutes}min atrás' : 'Agora';
  }
}

class _PrazoDuracaoDialog extends StatefulWidget {
  final PrazoDuracao? prazoDuracao;

  const _PrazoDuracaoDialog({this.prazoDuracao});

  @override
  State<_PrazoDuracaoDialog> createState() => _PrazoDuracaoDialogState();
}

class _PrazoDuracaoDialogState extends State<_PrazoDuracaoDialog> {
  final _formKey = GlobalKey<FormState>();
  final _mesesController = TextEditingController();
  final _descricaoController = TextEditingController();
  bool _carregando = false;
  String _tipo = 'determinado';
  bool _renovavel = false;

  @override
  void initState() {
    super.initState();
    if (widget.prazoDuracao != null) _carregarDados(widget.prazoDuracao!.tipoPrazo ?? '');
  }

  void _carregarDados(String prazo) {
    if (prazo.contains('Indeterminado')) {
      _tipo = 'indeterminado';
    } else if (prazo.contains('projeto')) {
      _tipo = 'projeto';
      final match = RegExp(r'projeto:\s*(.+)').firstMatch(prazo);
      if (match != null) _descricaoController.text = match.group(1) ?? '';
    } else {
      _renovavel = prazo.contains('Renovável');
      final matchMeses = RegExp(r'(\d+)\s*meses?').firstMatch(prazo);
      if (matchMeses != null) {
        _mesesController.text = matchMeses.group(1) ?? '';
      } else {
        final matchAnos = RegExp(r'(\d+)\s*anos?').firstMatch(prazo);
        if (matchAnos != null) {
          final anos = int.parse(matchAnos.group(1) ?? '0');
          _mesesController.text = (anos * 12).toString();
        }
      }
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

    final totalMeses = int.parse(_mesesController.text);
    final anos = totalMeses ~/ 12;
    final meses = totalMeses % 12;
    
    String prazo = 'Prazo Determinado - ';
    prazo += anos > 0 
      ? '$anos ${anos == 1 ? 'ano' : 'anos'}${meses > 0 ? ' e $meses ${meses == 1 ? 'mês' : 'meses'}' : ''}'
      : '$totalMeses ${totalMeses == 1 ? 'mês' : 'meses'}';

    return _renovavel ? '$prazo (Renovável automaticamente)' : prazo;
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _carregando = true);
    final servico = context.read<PrazoDuracaoServico>();
    
    bool sucesso;
    if (widget.prazoDuracao == null) {
      sucesso = await servico.criarPrazoDuracao(tipoPrazo: _gerarPrazo());
    } else {
      sucesso = await servico.atualizarPrazoDuracao(
        PrazoDuracao(
          id: widget.prazoDuracao!.id,
          tipoPrazo: _gerarPrazo(),
          criadoEm: widget.prazoDuracao!.criadoEm,
          atualizadoEm: DateTime.now(),
        ),
      );
    }

    if (mounted) {
      setState(() => _carregando = false);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(sucesso ? '${widget.prazoDuracao == null ? 'Criado' : 'Atualizado'} com sucesso' : servico.erro ?? 'Erro'),
          backgroundColor: sucesso ? Colors.green : Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(widget.prazoDuracao != null ? Icons.edit_calendar : Icons.schedule, color: Theme.of(context).primaryColor),
          const SizedBox(width: 8),
          Text(widget.prazoDuracao != null ? 'Editar Prazo' : 'Novo Prazo'),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('Determinado'),
                    selected: _tipo == 'determinado',
                    onSelected: (v) => setState(() {
                      _tipo = 'determinado';
                      _mesesController.clear();
                      _descricaoController.clear();
                      _renovavel = false;
                    }),
                  ),
                  ChoiceChip(
                    label: const Text('Indeterminado'),
                    selected: _tipo == 'indeterminado',
                    onSelected: (v) => setState(() {
                      _tipo = 'indeterminado';
                      _mesesController.clear();
                      _descricaoController.clear();
                    }),
                  ),
                  ChoiceChip(
                    label: const Text('Por Projeto'),
                    selected: _tipo == 'projeto',
                    onSelected: (v) => setState(() {
                      _tipo = 'projeto';
                      _mesesController.clear();
                      _descricaoController.clear();
                    }),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (_tipo == 'determinado') ...[
                TextFormField(
                  controller: _mesesController,
                  decoration: const InputDecoration(
                    labelText: 'Duração em Meses *',
                    prefixIcon: Icon(Icons.calendar_month),
                    border: OutlineInputBorder(),
                    helperText: 'Ex: 12 meses = 1 ano',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (v) {
                    if (v?.isEmpty ?? true) return 'Campo obrigatório';
                    final n = int.tryParse(v!);
                    return (n == null || n < 1 || n > 600) ? 'Entre 1 e 600 meses' : null;
                  },
                ),
                const SizedBox(height: 12),
                CheckboxListTile(
                  value: _renovavel,
                  onChanged: (v) => setState(() => _renovavel = v ?? false),
                  title: const Text('Renovável automaticamente'),
                  contentPadding: EdgeInsets.zero,
                ),
              ],
              if (_tipo == 'projeto')
                TextFormField(
                  controller: _descricaoController,
                  decoration: const InputDecoration(
                    labelText: 'Descrição do Projeto *',
                    prefixIcon: Icon(Icons.work_outline),
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v?.trim().isEmpty ?? true ? 'Campo obrigatório' : null,
                  maxLength: 200,
                  maxLines: 2,
                ),
              if (_tipo == 'indeterminado')
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.all_inclusive, color: Colors.green, size: 32),
                      SizedBox(width: 12),
                      Expanded(child: Text('Sem data de término.')),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: _carregando ? null : () => Navigator.pop(context), child: const Text('Cancelar')),
        ElevatedButton(
          onPressed: _carregando ? null : _salvar,
          child: _carregando
            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
            : Text(widget.prazoDuracao != null ? 'Salvar' : 'Criar'),
        ),
      ],
    );
  }
}