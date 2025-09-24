import 'package:desafio/app/telas/clausula_tela.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:desafio/servicos/contrato_servico.dart';
import 'package:desafio/modelo/entidades/contrato/contrato.dart';

class ContratosTela extends StatefulWidget {
  const ContratosTela({super.key});

  @override
  State<ContratosTela> createState() => _ContratosTelaState();
}

class _ContratosTelaState extends State<ContratosTela>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _pesquisaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ContratoServico>(context, listen: false).carregarContratos();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pesquisaController.dispose();
    super.dispose();
  }

  void _mostrarDialogoContrato({Contrato? contrato}) {
    showDialog(
      context: context,
      builder: (context) => _ContratoDialog(contrato: contrato),
    );
  }

  void _excluirContrato(Contrato contrato) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirmar exclusão'),
            content: Text(
              'Tem certeza que deseja excluir o contrato "${contrato.titulo}"?',
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
      final contratoServico = Provider.of<ContratoServico>(
        context,
        listen: false,
      );
      final sucesso = await contratoServico.excluirContrato(contrato.id!);

      if (sucesso && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contrato excluído com sucesso')),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(contratoServico.erro ?? 'Erro ao excluir contrato'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _verClausulas(Contrato contrato) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ClausulasTela(contrato: contrato),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contratos'),
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
            Tab(icon: Icon(Icons.pending), text: 'Pendentes'),
            Tab(icon: Icon(Icons.check_circle), text: 'Aprovados'),
            Tab(icon: Icon(Icons.cancel), text: 'Rejeitados'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Barra de pesquisa
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _pesquisaController,
              decoration: InputDecoration(
                labelText: 'Pesquisar contratos',
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

          // Conteúdo das abas
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildContratosList(filtro: 'todos'),
                _buildContratosList(filtro: 'pendente'),
                _buildContratosList(filtro: 'aprovado'),
                _buildContratosList(filtro: 'rejeitado'),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarDialogoContrato(),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildContratosList({required String filtro}) {
    return Consumer<ContratoServico>(
      builder: (context, contratoServico, child) {
        if (contratoServico.isCarregando) {
          return const Center(child: CircularProgressIndicator());
        }

        List<Contrato> contratos = [];

        // Aplicar filtros
        switch (filtro) {
          case 'todos':
            contratos = contratoServico.contratos;
            break;
          case 'pendente':
          case 'aprovado':
          case 'rejeitado':
            contratos =
                contratoServico.contratos
                    .where(
                      (c) => c.status?.toLowerCase() == filtro.toLowerCase(),
                    )
                    .toList();
            break;
        }

        // Aplicar pesquisa
        if (_pesquisaController.text.isNotEmpty) {
          contratos =
              contratos
                  .where(
                    (c) =>
                        c.titulo?.toLowerCase().contains(
                              _pesquisaController.text.toLowerCase(),
                            ) ==
                            true ||
                        c.nomeEmpresa?.toLowerCase().contains(
                              _pesquisaController.text.toLowerCase(),
                            ) ==
                            true,
                  )
                  .toList();
        }

        if (contratos.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.description, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  _pesquisaController.text.isNotEmpty
                      ? 'Nenhum contrato encontrado para "${_pesquisaController.text}"'
                      : 'Nenhum contrato encontrado',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                if (_pesquisaController.text.isEmpty) ...[
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _mostrarDialogoContrato(),
                    icon: const Icon(Icons.add),
                    label: const Text('Criar primeiro contrato'),
                  ),
                ],
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: contratoServico.carregarContratos,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: contratos.length,
            itemBuilder: (context, index) {
              final contrato = contratos[index];
              return _buildContratoCard(contrato);
            },
          ),
        );
      },
    );
  }

  Widget _buildContratoCard(Contrato contrato) {
    Color statusColor;
    IconData statusIcon;

    switch (contrato.status?.toLowerCase()) {
      case 'aprovado':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'rejeitado':
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
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor,
          child: Icon(statusIcon, color: Colors.white),
        ),
        title: Text(
          contrato.titulo ?? 'Sem título',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Empresa: ${contrato.nomeEmpresa ?? 'Não informado'}'),
            if (contrato.descricao?.isNotEmpty == true) ...[
              const SizedBox(height: 4),
              Text(
                contrato.descricao!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
            const SizedBox(height: 4),
            Text(
              'Criado em ${_formatarData(contrato.criadoEm)}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'clausulas':
                _verClausulas(contrato);
                break;
              case 'editar':
                _mostrarDialogoContrato(contrato: contrato);
                break;
              case 'excluir':
                _excluirContrato(contrato);
                break;
            }
          },
          itemBuilder:
              (context) => [
                const PopupMenuItem(
                  value: 'clausulas',
                  child: ListTile(
                    leading: Icon(Icons.list_alt),
                    title: Text('Ver Cláusulas'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
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
        onTap: () => _verClausulas(contrato),
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

class _ContratoDialog extends StatefulWidget {
  final Contrato? contrato;

  const _ContratoDialog({this.contrato});

  @override
  State<_ContratoDialog> createState() => _ContratoDialogState();
}

class _ContratoDialogState extends State<_ContratoDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _tituloController;
  late TextEditingController _nomeEmpresaController;
  late TextEditingController _descricaoController;
  late TextEditingController _dataGeracaoController;
  late TextEditingController _linkController;
  late String _statusSelecionado;
  bool _isCarregando = false;

  final List<String> _statusOptions = ['Pendente', 'Aprovado', 'Rejeitado'];

  @override
  void initState() {
    super.initState();
    _tituloController = TextEditingController(
      text: widget.contrato?.titulo ?? '',
    );
    _nomeEmpresaController = TextEditingController(
      text: widget.contrato?.nomeEmpresa ?? '',
    );
    _descricaoController = TextEditingController(
      text: widget.contrato?.descricao ?? '',
    );
    _dataGeracaoController = TextEditingController(
      text: widget.contrato?.dataGeracao ?? '',
    );
    _linkController = TextEditingController(text: widget.contrato?.link ?? '');
    _statusSelecionado = widget.contrato?.status ?? 'Pendente';
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _nomeEmpresaController.dispose();
    _descricaoController.dispose();
    _dataGeracaoController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isCarregando = true);

    final contratoServico = Provider.of<ContratoServico>(
      context,
      listen: false,
    );
    bool sucesso = false;

    try {
      if (widget.contrato == null) {
        // Criar novo contrato
        sucesso = await contratoServico.criarContrato(
          titulo: _tituloController.text.trim(),
          nomeEmpresa: _nomeEmpresaController.text.trim(),
          status: _statusSelecionado,
          descricao: _descricaoController.text.trim(),
          dataGeracao: _dataGeracaoController.text.trim(),
          link: _linkController.text.trim(),
        );
      } else {
        // Atualizar contrato existente
        final contratoAtualizado = Contrato(
          id: widget.contrato!.id,
          titulo: _tituloController.text.trim(),
          nomeEmpresa: _nomeEmpresaController.text.trim(),
          status: _statusSelecionado,
          descricao: _descricaoController.text.trim(),
          dataGeracao: _dataGeracaoController.text.trim(),
          link: _linkController.text.trim(),
          criadoEm: widget.contrato!.criadoEm,
          atualizadoEm: DateTime.now(),
        );

        sucesso = await contratoServico.atualizarContrato(contratoAtualizado);
      }

      if (sucesso && mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.contrato == null
                  ? 'Contrato criado com sucesso'
                  : 'Contrato atualizado com sucesso',
            ),
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(contratoServico.erro ?? 'Erro ao salvar contrato'),
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
        widget.contrato == null ? 'Novo Contrato' : 'Editar Contrato',
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
                  controller: _tituloController,
                  decoration: const InputDecoration(
                    labelText: 'Título *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'O título é obrigatório';
                    }
                    return null;
                  },
                  maxLength: 200,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nomeEmpresaController,
                  decoration: const InputDecoration(
                    labelText: 'Nome da Empresa *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'O nome da empresa é obrigatório';
                    }
                    return null;
                  },
                  maxLength: 100,
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
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descricaoController,
                  decoration: const InputDecoration(
                    labelText: 'Descrição',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  maxLength: 500,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _dataGeracaoController,
                  decoration: const InputDecoration(
                    labelText: 'Data de Geração',
                    border: OutlineInputBorder(),
                    hintText: 'dd/mm/aaaa',
                  ),
                  maxLength: 50,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _linkController,
                  decoration: const InputDecoration(
                    labelText: 'Link',
                    border: OutlineInputBorder(),
                    hintText: 'https://...',
                  ),
                  maxLength: 500,
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
                  : Text(widget.contrato == null ? 'Criar' : 'Salvar'),
        ),
      ],
    );
  }
}
