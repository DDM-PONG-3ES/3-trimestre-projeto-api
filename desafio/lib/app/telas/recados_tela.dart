import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:desafio/servicos/recado_servico.dart';
import 'package:desafio/modelo/entidades/recado/recado.dart';

class RecadosTela extends StatefulWidget {
  const RecadosTela({super.key});

  @override
  State<RecadosTela> createState() => _RecadosTelaState();
}

class _RecadosTelaState extends State<RecadosTela>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _pesquisaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RecadoServico>(context, listen: false).carregarRecados();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pesquisaController.dispose();
    super.dispose();
  }

  void _mostrarDialogoRecado({Recado? recado}) {
    showDialog(
      context: context,
      builder: (context) => _RecadoDialog(recado: recado),
    );
  }

  void _excluirRecado(Recado recado) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirmar exclusão'),
            content: Text(
              'Tem certeza que deseja excluir o recado "${recado.nome}"?',
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
      final recadoServico = Provider.of<RecadoServico>(context, listen: false);
      final sucesso = await recadoServico.excluirRecado(recado.id!);

      if (sucesso && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recado excluído com sucesso')),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(recadoServico.erro ?? 'Erro ao excluir recado'),
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
        title: const Text('Recados'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.list), text: 'Todos'),
            Tab(icon: Icon(Icons.error), text: 'Com Erros'),
            Tab(icon: Icon(Icons.check_circle), text: 'Sem Erros'),
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
                labelText: 'Pesquisar recados',
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
                _buildRecadosList(filtro: 'todos'),
                _buildRecadosList(filtro: 'comErros'),
                _buildRecadosList(filtro: 'semErros'),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarDialogoRecado(),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildRecadosList({required String filtro}) {
    return Consumer<RecadoServico>(
      builder: (context, recadoServico, child) {
        if (recadoServico.isCarregando) {
          return const Center(child: CircularProgressIndicator());
        }

        List<Recado> recados = [];

        // Aplicar filtros
        switch (filtro) {
          case 'todos':
            recados = recadoServico.recados;
            break;
          case 'comErros':
            recados =
                recadoServico.recados
                    .where((r) => r.erroIA != null && r.erroIA!.isNotEmpty)
                    .toList();
            break;
          case 'semErros':
            recados =
                recadoServico.recados
                    .where((r) => r.erroIA == null || r.erroIA!.isEmpty)
                    .toList();
            break;
        }

        // Aplicar pesquisa
        if (_pesquisaController.text.isNotEmpty) {
          recados =
              recados
                  .where(
                    (r) =>
                        r.nome?.toLowerCase().contains(
                          _pesquisaController.text.toLowerCase(),
                        ) ==
                        true,
                  )
                  .toList();
        }

        if (recados.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  _pesquisaController.text.isNotEmpty
                      ? 'Nenhum recado encontrado para "${_pesquisaController.text}"'
                      : 'Nenhum recado encontrado',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                if (_pesquisaController.text.isEmpty) ...[
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _mostrarDialogoRecado(),
                    icon: const Icon(Icons.add),
                    label: const Text('Criar primeiro recado'),
                  ),
                ],
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: recadoServico.carregarRecados,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: recados.length,
            itemBuilder: (context, index) {
              final recado = recados[index];
              return _buildRecadoCard(recado);
            },
          ),
        );
      },
    );
  }

  Widget _buildRecadoCard(Recado recado) {
    final temErro = recado.erroIA != null && recado.erroIA!.isNotEmpty;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: temErro ? Colors.red : Colors.green,
          child: Icon(
            temErro ? Icons.error : Icons.check_circle,
            color: Colors.white,
          ),
        ),
        title: Text(
          recado.nome ?? 'Sem nome',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (temErro) ...[
              const SizedBox(height: 4),
              Text(
                'Erro: ${recado.erroIA}',
                style: const TextStyle(color: Colors.red),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 4),
            Text(
              'Criado em ${_formatarData(recado.criadoEm)}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'editar':
                _mostrarDialogoRecado(recado: recado);
                break;
              case 'excluir':
                _excluirRecado(recado);
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
                    title: Text('Excluir', style: TextStyle(color: Colors.red)),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
        ),
        onTap: () => _mostrarDialogoRecado(recado: recado),
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

class _RecadoDialog extends StatefulWidget {
  final Recado? recado;

  const _RecadoDialog({this.recado});

  @override
  State<_RecadoDialog> createState() => _RecadoDialogState();
}

class _RecadoDialogState extends State<_RecadoDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomeController;
  late TextEditingController _erroIAController;
  bool _isCarregando = false;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.recado?.nome ?? '');
    _erroIAController = TextEditingController(
      text: widget.recado?.erroIA ?? '',
    );
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _erroIAController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isCarregando = true);

    final recadoServico = Provider.of<RecadoServico>(context, listen: false);
    bool sucesso = false;

    try {
      if (widget.recado == null) {
        // Criar novo recado
        sucesso = await recadoServico.criarRecado(
          nome: _nomeController.text.trim(),
          erroIA:
              _erroIAController.text.trim().isEmpty
                  ? null
                  : _erroIAController.text.trim(),
        );
      } else {
        // Atualizar recado existente
        final recadoAtualizado = Recado(
          id: widget.recado!.id,
          nome: _nomeController.text.trim(),
          erroIA:
              _erroIAController.text.trim().isEmpty
                  ? null
                  : _erroIAController.text.trim(),
          criadoEm: widget.recado!.criadoEm,
          atualizadoEm: DateTime.now(),
        );

        sucesso = await recadoServico.atualizarRecado(recadoAtualizado);
      }

      if (sucesso && mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.recado == null
                  ? 'Recado criado com sucesso'
                  : 'Recado atualizado com sucesso',
            ),
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(recadoServico.erro ?? 'Erro ao salvar recado'),
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
      title: Text(widget.recado == null ? 'Novo Recado' : 'Editar Recado'),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome do recado *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'O nome é obrigatório';
                  }
                  return null;
                },
                maxLength: 100,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _erroIAController,
                decoration: const InputDecoration(
                  labelText: 'Erro da IA (opcional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                maxLength: 500,
              ),
            ],
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
                  : Text(widget.recado == null ? 'Criar' : 'Salvar'),
        ),
      ],
    );
  }
}
