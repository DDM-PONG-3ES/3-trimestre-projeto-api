import 'package:desafio/app/telas/capitalSocial_tela.dart';
import 'package:desafio/app/telas/administracao_tela.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:desafio/servicos/clausula_servico.dart';
import 'package:desafio/modelo/entidades/clausula/clausula.dart';
import 'package:desafio/modelo/entidades/contrato/contrato.dart';
import 'package:desafio/app/telas/sede_tela.dart';

class ClausulasTela extends StatefulWidget {
  final Contrato contrato;

  const ClausulasTela({super.key, required this.contrato});

  @override
  State<ClausulasTela> createState() => _ClausulasTelaState();
}

class _ClausulasTelaState extends State<ClausulasTela>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _pesquisaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ClausulaServico>(
        context,
        listen: false,
      ).carregarClausulasPorContrato(widget.contrato.id!);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pesquisaController.dispose();
    super.dispose();
  }

  void _mostrarDialogoClausula({Clausula? clausula}) {
    showDialog(
      context: context,
      builder:
          (context) => _ClausulaDialog(
            clausula: clausula,
            contratoId: widget.contrato.id!,
          ),
    );
  }

  void _excluirClausula(Clausula clausula) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirmar exclusão'),
            content: const Text(
              'Tem certeza que deseja excluir esta cláusula?',
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
      final clausulaServico = Provider.of<ClausulaServico>(
        context,
        listen: false,
      );
      final sucesso = await clausulaServico.excluirClausula(clausula.id!);

      if (sucesso && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cláusula excluída com sucesso')),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(clausulaServico.erro ?? 'Erro ao excluir cláusula'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _navegarParaCapitalSocial(Clausula clausula) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CapitalSocialTela(clausula: clausula),
      ),
    );
  }

  void _navegarParaSede(Clausula clausula) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SedeTela(clausula: clausula)),
    );
  }

  void _navegarParaAdministracao(Clausula clausula) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdministracaoTela(clausula: clausula),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Cláusulas'),
            Text(
              widget.contrato.titulo ?? 'Contrato sem título',
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.list), text: 'Todas'),
            Tab(icon: Icon(Icons.pending), text: 'Pendentes'),
            Tab(icon: Icon(Icons.check_circle), text: 'Aprovadas'),
            Tab(icon: Icon(Icons.cancel), text: 'Rejeitadas'),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            color: Colors.grey[100],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Empresa: ${widget.contrato.nomeEmpresa ?? 'Não informado'}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                if (widget.contrato.status != null) ...[
                  const SizedBox(height: 4),
                  Text('Status: ${widget.contrato.status}'),
                ],
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _pesquisaController,
              decoration: InputDecoration(
                labelText: 'Pesquisar cláusulas',
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
                _buildClausulasList(filtro: 'todas'),
                _buildClausulasList(filtro: 'pendente'),
                _buildClausulasList(filtro: 'aprovada'),
                _buildClausulasList(filtro: 'rejeitada'),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarDialogoClausula(),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildClausulasList({required String filtro}) {
    return Consumer<ClausulaServico>(
      builder: (context, clausulaServico, child) {
        if (clausulaServico.isCarregando) {
          return const Center(child: CircularProgressIndicator());
        }

        List<Clausula> clausulas = [];

        switch (filtro) {
          case 'todas':
            clausulas =
                clausulaServico.clausulas
                    .where((c) => c.contratoId == widget.contrato.id)
                    .toList();
            break;
          case 'pendente':
          case 'aprovada':
          case 'rejeitada':
            clausulas =
                clausulaServico.clausulas
                    .where(
                      (c) =>
                          c.contratoId == widget.contrato.id &&
                          c.status?.toLowerCase() == filtro.toLowerCase(),
                    )
                    .toList();
            break;
        }

        if (_pesquisaController.text.isNotEmpty) {
          clausulas =
              clausulas
                  .where(
                    (c) =>
                        c.texto?.toLowerCase().contains(
                              _pesquisaController.text.toLowerCase(),
                            ) ==
                            true ||
                        c.tipo?.toLowerCase().contains(
                              _pesquisaController.text.toLowerCase(),
                            ) ==
                            true,
                  )
                  .toList();
        }

        if (clausulas.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.list_alt, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  _pesquisaController.text.isNotEmpty
                      ? 'Nenhuma cláusula encontrada para "${_pesquisaController.text}"'
                      : 'Nenhuma cláusula encontrada',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                if (_pesquisaController.text.isEmpty) ...[
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _mostrarDialogoClausula(),
                    icon: const Icon(Icons.add),
                    label: const Text('Criar primeira cláusula'),
                  ),
                ],
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh:
              () => clausulaServico.carregarClausulasPorContrato(
                widget.contrato.id!,
              ),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: clausulas.length,
            itemBuilder: (context, index) {
              final clausula = clausulas[index];
              return _buildClausulaCard(clausula);
            },
          ),
        );
      },
    );
  }

  Widget _buildClausulaCard(Clausula clausula) {
    Color statusColor;
    IconData statusIcon;

    switch (clausula.status?.toLowerCase()) {
      case 'aprovada':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'rejeitada':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      case 'pendente':
      default:
        statusColor = Colors.orange;
        statusIcon = Icons.pending;
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: statusColor,
              child: Icon(statusIcon, color: Colors.white),
            ),
            title: Text(
              clausula.tipo ?? 'Tipo não informado',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (clausula.texto?.isNotEmpty == true) ...[
                  const SizedBox(height: 4),
                  Text(
                    clausula.texto!,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  'Status: ${clausula.status ?? 'Não informado'}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                Text(
                  'Criado em ${_formatarData(clausula.criadoEm)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'editar':
                    _mostrarDialogoClausula(clausula: clausula);
                    break;
                  case 'excluir':
                    _excluirClausula(clausula);
                    break;
                }
              },
              itemBuilder:
                  (context) => [
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
                        title: Text(
                          'Excluir',
                          style: TextStyle(color: Colors.red),
                        ),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
            ),
            onTap: () => _mostrarDialogoClausula(clausula: clausula),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _navegarParaCapitalSocial(clausula),
                        icon: const Icon(Icons.account_balance, size: 18),
                        label: const Text('Capital Social'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _navegarParaSede(clausula),
                        icon: const Icon(Icons.location_on, size: 18),
                        label: const Text('Sede'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _navegarParaAdministracao(clausula),
                    icon: const Icon(Icons.admin_panel_settings, size: 18),
                    label: const Text('Administração'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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

class _ClausulaDialog extends StatefulWidget {
  final Clausula? clausula;
  final int contratoId;

  const _ClausulaDialog({this.clausula, required this.contratoId});

  @override
  State<_ClausulaDialog> createState() => _ClausulaDialogState();
}

class _ClausulaDialogState extends State<_ClausulaDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _textoController;
  late TextEditingController _tipoController;
  late String _statusSelecionado;
  bool _isCarregando = false;

  final List<String> _statusOptions = ['Pendente', 'Aprovada', 'Rejeitada'];
  final List<String> _tipoOptions = [
    'Pagamento',
    'Prazo',
    'Rescisão',
    'Responsabilidade',
    'Garantia',
    'Confidencialidade',
    'Propriedade Intelectual',
    'Força Maior',
    'Foro',
    'Outro',
  ];

  @override
  void initState() {
    super.initState();
    _textoController = TextEditingController(
      text: widget.clausula?.texto ?? '',
    );
    _tipoController = TextEditingController(text: widget.clausula?.tipo ?? '');
    _statusSelecionado = widget.clausula?.status ?? 'Pendente';
  }

  @override
  void dispose() {
    _textoController.dispose();
    _tipoController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isCarregando = true);

    final clausulaServico = Provider.of<ClausulaServico>(
      context,
      listen: false,
    );
    bool sucesso = false;

    try {
      if (widget.clausula == null) {
        sucesso = await clausulaServico.criarClausula(
          texto: _textoController.text.trim(),
          tipo: _tipoController.text.trim(),
          status: _statusSelecionado,
          contratoId: widget.contratoId,
        );
      } else {
        final clausulaAtualizada = Clausula(
          id: widget.clausula!.id,
          texto: _textoController.text.trim(),
          tipo: _tipoController.text.trim(),
          status: _statusSelecionado,
          contratoId: widget.contratoId,
          criadoEm: widget.clausula!.criadoEm,
          atualizadoEm: DateTime.now(),
        );

        sucesso = await clausulaServico.atualizarClausula(clausulaAtualizada);
      }

      if (sucesso && mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.clausula == null
                  ? 'Cláusula criada com sucesso'
                  : 'Cláusula atualizada com sucesso',
            ),
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(clausulaServico.erro ?? 'Erro ao salvar cláusula'),
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
        widget.clausula == null ? 'Nova Cláusula' : 'Editar Cláusula',
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value:
                      _tipoOptions.contains(_tipoController.text)
                          ? _tipoController.text
                          : _tipoOptions.first,
                  decoration: const InputDecoration(
                    labelText: 'Tipo *',
                    border: OutlineInputBorder(),
                  ),
                  items:
                      _tipoOptions.map((String tipo) {
                        return DropdownMenuItem<String>(
                          value: tipo,
                          child: Text(tipo),
                        );
                      }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _tipoController.text = newValue;
                      });
                    }
                  },
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'O tipo é obrigatório';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _textoController,
                  decoration: const InputDecoration(
                    labelText: 'Texto da Cláusula *',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'O texto da cláusula é obrigatório';
                    }
                    return null;
                  },
                  maxLines: 5,
                  maxLength: 1000,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _statusSelecionado,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(),
                  ),
                  items:
                      _statusOptions.map((String status) {
                        return DropdownMenuItem<String>(
                          value: status,
                          child: Text(status),
                        );
                      }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _statusSelecionado = newValue;
                      });
                    }
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
                  : Text(widget.clausula == null ? 'Criar' : 'Salvar'),
        ),
      ],
    );
  }
}