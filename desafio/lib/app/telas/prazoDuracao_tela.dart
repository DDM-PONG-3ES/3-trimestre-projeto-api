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

class _PrazosDuracaoTelaState extends State<PrazosDuracaoTela>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _pesquisaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PrazoDuracaoServico>(context, listen: false)
          .carregarPrazosDuracao();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pesquisaController.dispose();
    super.dispose();
  }

  void _mostrarDialogoPrazoDuracao({PrazoDuracao? prazoDuracao}) {
    showDialog(
      context: context,
      builder: (context) => _PrazoDuracaoDialog(prazoDuracao: prazoDuracao),
    );
  }

  void _excluirPrazoDuracao(PrazoDuracao prazoDuracao) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: const Text(
          'Tem certeza que deseja excluir este prazo de duração?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Excluir',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmar == true && mounted) {
      final prazoDuracaoServico = Provider.of<PrazoDuracaoServico>(
        context,
        listen: false,
      );
      final sucesso = await prazoDuracaoServico.excluirPrazoDuracao(
        prazoDuracao.id!,
      );

      if (sucesso && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Prazo de duração excluído com sucesso'),
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              prazoDuracaoServico.erro ?? 'Erro ao excluir prazo de duração',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prazos de Duração'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.list), text: 'Todos'),
            Tab(icon: Icon(Icons.schedule), text: 'Determinados'),
            Tab(icon: Icon(Icons.all_inclusive), text: 'Indeterminados'),
            Tab(icon: Icon(Icons.work_outline), text: 'Por Projeto'),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _pesquisaController,
              decoration: InputDecoration(
                labelText: 'Pesquisar prazos',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _pesquisaController.clear();
                    setState(() {});
                  },
                ),
              ),
              onChanged: (value) => setState(() {}),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPrazosList(filtro: 'todos'),
                _buildPrazosList(filtro: 'determinado'),
                _buildPrazosList(filtro: 'indeterminado'),
                _buildPrazosList(filtro: 'projeto'),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarDialogoPrazoDuracao(),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildPrazosList({required String filtro}) {
    return Consumer<PrazoDuracaoServico>(
      builder: (context, prazoDuracaoServico, child) {
        if (prazoDuracaoServico.isCarregando) {
          return const Center(child: CircularProgressIndicator());
        }

        List<PrazoDuracao> prazos = [];

        switch (filtro) {
          case 'todos':
            prazos = prazoDuracaoServico.prazosDuracao;
            break;
          case 'determinado':
            prazos = prazoDuracaoServico.prazosDuracao
                .where((p) =>
                    p.tipoPrazo?.contains('Prazo Determinado') ?? false)
                .toList();
            break;
          case 'indeterminado':
            prazos = prazoDuracaoServico.prazosDuracao
                .where((p) =>
                    p.tipoPrazo?.contains('Prazo Indeterminado') ?? false)
                .toList();
            break;
          case 'projeto':
            prazos = prazoDuracaoServico.prazosDuracao
                .where((p) => p.tipoPrazo?.contains('projeto') ?? false)
                .toList();
            break;
        }

        if (_pesquisaController.text.isNotEmpty) {
          prazos = prazos
              .where((p) =>
                  p.tipoPrazo?.toLowerCase().contains(
                        _pesquisaController.text.toLowerCase(),
                      ) ??
                  false)
              .toList();
        }

        if (prazos.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.schedule, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  _pesquisaController.text.isNotEmpty
                      ? 'Nenhum prazo encontrado para "${_pesquisaController.text}"'
                      : 'Nenhum prazo de duração encontrado',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                if (_pesquisaController.text.isEmpty) ...[
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _mostrarDialogoPrazoDuracao(),
                    icon: const Icon(Icons.add),
                    label: const Text('Criar primeiro prazo'),
                  ),
                ],
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: prazoDuracaoServico.carregarPrazosDuracao,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: prazos.length,
            itemBuilder: (context, index) {
              final prazo = prazos[index];
              return _buildPrazoDuracaoCard(prazo);
            },
          ),
        );
      },
    );
  }

  Widget _buildPrazoDuracaoCard(PrazoDuracao prazoDuracao) {
    IconData iconData;
    Color iconColor;

    if (prazoDuracao.tipoPrazo?.contains('Indeterminado') ?? false) {
      iconData = Icons.all_inclusive;
      iconColor = Colors.green;
    } else if (prazoDuracao.tipoPrazo?.contains('projeto') ?? false) {
      iconData = Icons.work_outline;
      iconColor = Colors.orange;
    } else {
      iconData = Icons.schedule;
      iconColor = Theme.of(context).primaryColor;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: iconColor,
          child: Icon(iconData, color: Colors.white),
        ),
        title: Text(
          prazoDuracao.tipoPrazo ?? 'Prazo não informado',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'Criado em ${_formatarData(prazoDuracao.criadoEm)}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'editar':
                _mostrarDialogoPrazoDuracao(prazoDuracao: prazoDuracao);
                break;
              case 'excluir':
                _excluirPrazoDuracao(prazoDuracao);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'editar',
              child: ListTile(
                leading: Icon(Icons.edit),
                title: Text('Editar'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'excluir',
              child: ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text('Excluir', style: TextStyle(color: Colors.red)),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
        onTap: () => _mostrarDialogoPrazoDuracao(prazoDuracao: prazoDuracao),
      ),
    );
  }

  String _formatarData(DateTime? data) {
    if (data == null) return 'Data não informada';

    final agora = DateTime.now();
    final diferenca = agora.difference(data);

    if (diferenca.inDays > 7) {
      return '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}';
    } else if (diferenca.inDays > 0) {
      return '${diferenca.inDays} dia${diferenca.inDays == 1 ? '' : 's'} atrás';
    } else if (diferenca.inHours > 0) {
      return '${diferenca.inHours} hora${diferenca.inHours == 1 ? '' : 's'} atrás';
    } else if (diferenca.inMinutes > 0) {
      return '${diferenca.inMinutes} minuto${diferenca.inMinutes == 1 ? '' : 's'} atrás';
    } else {
      return 'Agora mesmo';
    }
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
  bool _isCarregando = false;
  String _tipo = 'determinado';
  bool _renovavel = false;

  @override
  void initState() {
    super.initState();
    if (widget.prazoDuracao != null) {
      _parseExistingValue(widget.prazoDuracao!.tipoPrazo ?? '');
    }
  }

  void _parseExistingValue(String prazo) {
    if (prazo.contains('Indeterminado')) {
      _tipo = 'indeterminado';
    } else if (prazo.contains('projeto')) {
      _tipo = 'projeto';
      final match = RegExp(r'projeto:\s*(.+)').firstMatch(prazo);
      if (match != null) _descricaoController.text = match.group(1) ?? '';
    } else {
      _tipo = 'determinado';
      final match = RegExp(r'(\d+)\s*meses?').firstMatch(prazo);
      if (match != null) {
        _mesesController.text = match.group(1) ?? '';
      } else {
        // Tentar extrair anos
        final anosMatch = RegExp(r'(\d+)\s*anos?').firstMatch(prazo);
        if (anosMatch != null) {
          final anos = int.parse(anosMatch.group(1) ?? '0');
          final mesesMatch = RegExp(r'(\d+)\s*meses?').firstMatch(prazo);
          final meses = mesesMatch != null ? int.parse(mesesMatch.group(1) ?? '0') : 0;
          _mesesController.text = (anos * 12 + meses).toString();
        }
      }
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
    if (_tipo == 'projeto') {
      return 'Até conclusão do projeto: ${_descricaoController.text.trim()}';
    }

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
          : await servico.atualizarPrazoDuracao(
              PrazoDuracao(
                id: widget.prazoDuracao!.id,
                tipoPrazo: prazo,
                criadoEm: widget.prazoDuracao!.criadoEm,
                atualizadoEm: DateTime.now(),
              ),
            );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              sucesso
                  ? '${widget.prazoDuracao == null ? 'Criado' : 'Atualizado'} com sucesso'
                  : servico.erro ?? 'Erro ao salvar',
            ),
            backgroundColor: sucesso ? Colors.green : Colors.red,
          ),
        );
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
          Icon(
            widget.prazoDuracao != null ? Icons.edit_calendar : Icons.schedule,
            color: Theme.of(context).primaryColor,
            size: 28,
          ),
          const SizedBox(width: 8),
          Text(
            widget.prazoDuracao != null
                ? 'Editar Prazo de Duração'
                : 'Novo Prazo de Duração',
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tipo de Prazo',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
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
                      selectedColor: Theme.of(context).primaryColor.withOpacity(0.3),
                    ),
                    ChoiceChip(
                      label: const Text('Indeterminado'),
                      selected: _tipo == 'indeterminado',
                      onSelected: (v) => setState(() {
                        _tipo = 'indeterminado';
                        _mesesController.clear();
                        _descricaoController.clear();
                        _renovavel = false;
                      }),
                      selectedColor: Colors.green.withOpacity(0.3),
                    ),
                    ChoiceChip(
                      label: const Text('Até Projeto'),
                      selected: _tipo == 'projeto',
                      onSelected: (v) => setState(() {
                        _tipo = 'projeto';
                        _mesesController.clear();
                        _descricaoController.clear();
                        _renovavel = false;
                      }),
                      selectedColor: Colors.orange.withOpacity(0.3),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (_tipo == 'determinado') ...[
                  TextFormField(
                    controller: _mesesController,
                    decoration: InputDecoration(
                      labelText: 'Duração em Meses *',
                      prefixIcon: const Icon(Icons.calendar_month),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      helperText: 'Ex: 12 meses = 1 ano',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (v) {
                      if (v?.isEmpty ?? true) return 'Campo obrigatório';
                      final n = int.tryParse(v!);
                      return (n == null || n < 1 || n > 600)
                          ? 'Valor entre 1 e 600 meses'
                          : null;
                    },
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Atalhos rápidos:',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [6, 12, 24, 36, 60].map((m) {
                      return ActionChip(
                        label: Text('$m meses'),
                        onPressed: () => setState(
                          () => _mesesController.text = '$m',
                        ),
                        backgroundColor: Colors.grey[200],
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  CheckboxListTile(
                    value: _renovavel,
                    onChanged: (v) => setState(() => _renovavel = v ?? false),
                    title: const Text('Renovável automaticamente'),
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                ] else if (_tipo == 'projeto')
                  TextFormField(
                    controller: _descricaoController,
                    decoration: InputDecoration(
                      labelText: 'Descrição do Projeto *',
                      prefixIcon: const Icon(Icons.work_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      hintText: 'Ex: Construção do edifício principal',
                    ),
                    validator: (v) => v?.trim().isEmpty ?? true
                        ? 'Campo obrigatório'
                        : null,
                    maxLength: 200,
                    maxLines: 2,
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.all_inclusive,
                          color: Colors.green.shade700,
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Este contrato não terá data de término definida.',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
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
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
          ),
          child: _isCarregando
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(widget.prazoDuracao != null ? 'Salvar' : 'Criar'),
        ),
      ],
    );
  }
}