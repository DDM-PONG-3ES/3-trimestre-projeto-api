import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:desafio/servicos/administracao_servico.dart';
import 'package:desafio/modelo/entidades/administracao/administracao.dart';
import 'package:desafio/modelo/entidades/clausula/clausula.dart';

class AdministracaoTela extends StatefulWidget {
  final Clausula clausula;

  const AdministracaoTela({super.key, required this.clausula});

  @override
  State<AdministracaoTela> createState() => _AdministracaoTelaState();
}

class _AdministracaoTelaState extends State<AdministracaoTela> {
  final TextEditingController _pesquisaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdministracaoServico>(
        context,
        listen: false,
      ).carregarAdministracoesPorClausula(widget.clausula.id!);
    });
  }

  @override
  void dispose() {
    _pesquisaController.dispose();
    super.dispose();
  }

  void _mostrarDialogoAdministracao({Administracao? administracao}) {
    showDialog(
      context: context,
      builder: (context) => _AdministracaoDialog(
        administracao: administracao,
        clausulaId: widget.clausula.id!,
      ),
    );
  }

  void _excluirAdministracao(Administracao administracao) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: const Text(
          'Tem certeza que deseja excluir esta administração?',
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
      final administracaoServico = Provider.of<AdministracaoServico>(
        context,
        listen: false,
      );
      final sucesso = await administracaoServico.excluirAdministracao(
        administracao.id!,
      );

      if (sucesso && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Administração excluída com sucesso')),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              administracaoServico.erro ?? 'Erro ao excluir administração',
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Administrações'),
            Text(
              'Cláusula: ${widget.clausula.tipo ?? 'Sem tipo'}',
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
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
                  'Tipo: ${widget.clausula.tipo ?? 'Não informado'}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                if (widget.clausula.status != null) ...[
                  const SizedBox(height: 4),
                  Text('Status: ${widget.clausula.status}'),
                ],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _pesquisaController,
              decoration: InputDecoration(
                labelText: 'Pesquisar administrações',
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
            child: _buildAdministracoesList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarDialogoAdministracao(),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildAdministracoesList() {
    return Consumer<AdministracaoServico>(
      builder: (context, administracaoServico, child) {
        if (administracaoServico.isCarregando) {
          return const Center(child: CircularProgressIndicator());
        }

        List<Administracao> administracoes = administracaoServico.administracoes
            .where((a) => a.clausulaId == widget.clausula.id)
            .toList();

        if (_pesquisaController.text.isNotEmpty) {
          administracoes = administracoes.where((a) =>
            a.nomeAdministrador?.toLowerCase().contains(
              _pesquisaController.text.toLowerCase(),
            ) == true ||
            a.poderesAdministrativos?.toLowerCase().contains(
              _pesquisaController.text.toLowerCase(),
            ) == true
          ).toList();
        }

        if (administracoes.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.admin_panel_settings, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  _pesquisaController.text.isNotEmpty
                      ? 'Nenhuma administração encontrada para "${_pesquisaController.text}"'
                      : 'Nenhuma administração encontrada',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                if (_pesquisaController.text.isEmpty) ...[
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _mostrarDialogoAdministracao(),
                    icon: const Icon(Icons.add),
                    label: const Text('Criar primeira administração'),
                  ),
                ],
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => administracaoServico.carregarAdministracoesPorClausula(
            widget.clausula.id!,
          ),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: administracoes.length,
            itemBuilder: (context, index) {
              final administracao = administracoes[index];
              return _buildAdministracaoCard(administracao);
            },
          ),
        );
      },
    );
  }

  Widget _buildAdministracaoCard(Administracao administracao) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor,
          child: const Icon(Icons.admin_panel_settings, color: Colors.white),
        ),
        title: Text(
          administracao.nomeAdministrador ?? 'Nome não informado',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              'Poderes: ${administracao.poderesAdministrativos ?? 'Não informado'}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'Criado em ${_formatarData(administracao.criadoEm)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'editar':
                _mostrarDialogoAdministracao(administracao: administracao);
                break;
              case 'excluir':
                _excluirAdministracao(administracao);
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
        onTap: () => _mostrarDialogoAdministracao(administracao: administracao),
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

class _AdministracaoDialog extends StatefulWidget {
  final Administracao? administracao;
  final int clausulaId;

  const _AdministracaoDialog({this.administracao, required this.clausulaId});

  @override
  State<_AdministracaoDialog> createState() => _AdministracaoDialogState();
}

class _AdministracaoDialogState extends State<_AdministracaoDialog> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nomeAdministradorController;
  late TextEditingController _poderesAdministrativosController;
  
  bool _isCarregando = false;

  @override
  void initState() {
    super.initState();
    _nomeAdministradorController = TextEditingController(
      text: widget.administracao?.nomeAdministrador ?? '',
    );
    _poderesAdministrativosController = TextEditingController(
      text: widget.administracao?.poderesAdministrativos ?? '',
    );
  }

  @override
  void dispose() {
    _nomeAdministradorController.dispose();
    _poderesAdministrativosController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isCarregando = true);

    final administracaoServico = Provider.of<AdministracaoServico>(
      context,
      listen: false,
    );
    bool sucesso = false;

    try {
      if (widget.administracao == null) {
        sucesso = await administracaoServico.criarAdministracao(
          nomeAdministrador: _nomeAdministradorController.text.trim(),
          poderesAdministrativos: _poderesAdministrativosController.text.trim(),
          clausulaId: widget.clausulaId,
        );
      } else {
        final administracaoAtualizada = Administracao(
          id: widget.administracao!.id,
          nomeAdministrador: _nomeAdministradorController.text.trim(),
          poderesAdministrativos: _poderesAdministrativosController.text.trim(),
          clausulaId: widget.clausulaId,
          criadoEm: widget.administracao!.criadoEm,
          atualizadoEm: DateTime.now(),
        );

        sucesso = await administracaoServico.atualizarAdministracao(
          administracaoAtualizada,
        );
      }

      if (sucesso && mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.administracao == null
                  ? 'Administração criada com sucesso'
                  : 'Administração atualizada com sucesso',
            ),
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              administracaoServico.erro ?? 'Erro ao salvar administração',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }