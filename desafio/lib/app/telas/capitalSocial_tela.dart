import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:desafio/servicos/capital_social_servico.dart';
import 'package:desafio/modelo/entidades/capital_social/capital_social.dart';
import 'package:desafio/modelo/entidades/clausula/clausula.dart';
import 'package:intl/intl.dart';

class CapitalSocialTela extends StatefulWidget {
  final Clausula clausula;

  const CapitalSocialTela({super.key, required this.clausula});

  @override
  State<CapitalSocialTela> createState() => _CapitalSocialTelaState();
}

class _CapitalSocialTelaState extends State<CapitalSocialTela> {
  final TextEditingController _pesquisaController = TextEditingController();
  final NumberFormat _currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CapitalSocialServico>(
        context,
        listen: false,
      ).carregarCapitaisSociaisPorClausula(widget.clausula.id!);
    });
  }

  @override
  void dispose() {
    _pesquisaController.dispose();
    super.dispose();
  }

  void _mostrarDialogoCapitalSocial({CapitalSocial? capitalSocial}) {
    showDialog(
      context: context,
      builder: (context) => _CapitalSocialDialog(
        capitalSocial: capitalSocial,
        clausulaId: widget.clausula.id!,
      ),
    );
  }

  void _excluirCapitalSocial(CapitalSocial capitalSocial) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: const Text(
          'Tem certeza que deseja excluir este capital social?',
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
      final capitalSocialServico = Provider.of<CapitalSocialServico>(
        context,
        listen: false,
      );
      final sucesso = await capitalSocialServico.excluirCapitalSocial(
        capitalSocial.id!,
      );

      if (sucesso && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Capital social excluído com sucesso')),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              capitalSocialServico.erro ?? 'Erro ao excluir capital social',
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
            const Text('Capitais Sociais'),
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
                labelText: 'Pesquisar capitais sociais',
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
            child: _buildCapitaisSociaisList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarDialogoCapitalSocial(),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCapitaisSociaisList() {
    return Consumer<CapitalSocialServico>(
      builder: (context, capitalSocialServico, child) {
        if (capitalSocialServico.isCarregando) {
          return const Center(child: CircularProgressIndicator());
        }

        List<CapitalSocial> capitaisSociais = capitalSocialServico.capitaisSociais
            .where((c) => c.clausulaId == widget.clausula.id)
            .toList();

        if (_pesquisaController.text.isNotEmpty) {
          capitaisSociais = capitaisSociais.where((c) =>
            c.divisaoQuotas?.toLowerCase().contains(
              _pesquisaController.text.toLowerCase(),
            ) == true ||
            c.formaIntegralizacao?.toLowerCase().contains(
              _pesquisaController.text.toLowerCase(),
            ) == true
          ).toList();
        }

        if (capitaisSociais.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.account_balance, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  _pesquisaController.text.isNotEmpty
                      ? 'Nenhum capital social encontrado para "${_pesquisaController.text}"'
                      : 'Nenhum capital social encontrado',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                if (_pesquisaController.text.isEmpty) ...[
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _mostrarDialogoCapitalSocial(),
                    icon: const Icon(Icons.add),
                    label: const Text('Criar primeiro capital social'),
                  ),
                ],
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => capitalSocialServico.carregarCapitaisSociaisPorClausula(
            widget.clausula.id!,
          ),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: capitaisSociais.length,
            itemBuilder: (context, index) {
              final capitalSocial = capitaisSociais[index];
              return _buildCapitalSocialCard(capitalSocial);
            },
          ),
        );
      },
    );
  }

  Widget _buildCapitalSocialCard(CapitalSocial capitalSocial) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor,
          child: const Icon(Icons.account_balance, color: Colors.white),
        ),
        title: Text(
          _currencyFormat.format(capitalSocial.valorTotal ?? 0),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'Divisão: ${capitalSocial.divisaoQuotas ?? 'Não informado'}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 2),
            Text(
              'Integralização: ${capitalSocial.formaIntegralizacao ?? 'Não informado'}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 4),
            Text(
              'Criado em ${_formatarData(capitalSocial.criadoEm)}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'editar':
                _mostrarDialogoCapitalSocial(capitalSocial: capitalSocial);
                break;
              case 'excluir':
                _excluirCapitalSocial(capitalSocial);
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
        onTap: () => _mostrarDialogoCapitalSocial(capitalSocial: capitalSocial),
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

class _CapitalSocialDialog extends StatefulWidget {
  final CapitalSocial? capitalSocial;
  final int clausulaId;

  const _CapitalSocialDialog({this.capitalSocial, required this.clausulaId});

  @override
  State<_CapitalSocialDialog> createState() => _CapitalSocialDialogState();
}

class _CapitalSocialDialogState extends State<_CapitalSocialDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _valorTotalController;
  late TextEditingController _divisaoQuotasController;
  late TextEditingController _formaIntegralizacaoController;
  bool _isCarregando = false;

  final List<String> _formasIntegralizacao = [
    'Dinheiro',
    'Bens',
    'Serviços',
    'Créditos',
    'Misto',
    'Outro',
  ];

  @override
  void initState() {
    super.initState();
    _valorTotalController = TextEditingController(
      text: widget.capitalSocial?.valorTotal?.toString() ?? '',
    );
    _divisaoQuotasController = TextEditingController(
      text: widget.capitalSocial?.divisaoQuotas ?? '',
    );
    _formaIntegralizacaoController = TextEditingController(
      text: widget.capitalSocial?.formaIntegralizacao ?? 'Dinheiro',
    );
  }

  @override
  void dispose() {
    _valorTotalController.dispose();
    _divisaoQuotasController.dispose();
    _formaIntegralizacaoController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isCarregando = true);

    final capitalSocialServico = Provider.of<CapitalSocialServico>(
      context,
      listen: false,
    );
    bool sucesso = false;

    try {
      final valorTotal = double.parse(_valorTotalController.text.trim());

      if (widget.capitalSocial == null) {
        sucesso = await capitalSocialServico.criarCapitalSocial(
          valorTotal: valorTotal,
          divisaoQuotas: _divisaoQuotasController.text.trim(),
          formaIntegralizacao: _formaIntegralizacaoController.text.trim(),
          clausulaId: widget.clausulaId,
        );
      } else {
        final capitalSocialAtualizado = CapitalSocial(
          id: widget.capitalSocial!.id,
          valorTotal: valorTotal,
          divisaoQuotas: _divisaoQuotasController.text.trim(),
          formaIntegralizacao: _formaIntegralizacaoController.text.trim(),
          clausulaId: widget.clausulaId,
          criadoEm: widget.capitalSocial!.criadoEm,
          atualizadoEm: DateTime.now(),
        );

        sucesso = await capitalSocialServico.atualizarCapitalSocial(
          capitalSocialAtualizado,
        );
      }

      if (sucesso && mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.capitalSocial == null
                  ? 'Capital social criado com sucesso'
                  : 'Capital social atualizado com sucesso',
            ),
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              capitalSocialServico.erro ?? 'Erro ao salvar capital social',
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
      title: Row(
        children: [
          Icon(
            Icons.account_balance,
            color: Theme.of(context).primaryColor,
            size: 28,
          ),
          const SizedBox(width: 8),
          Text(
            widget.capitalSocial == null
                ? 'Novo Capital Social'
                : 'Editar Capital Social',
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
              children: [
                TextFormField(
                  controller: _valorTotalController,
                  decoration: const InputDecoration(
                    labelText: 'Valor Total *',
                    border: OutlineInputBorder(),
                    prefixText: 'R\$ ',
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'O valor total é obrigatório';
                    }
                    final valor = double.tryParse(value.trim());
                    if (valor == null || valor <= 0) {
                      return 'Digite um valor válido maior que zero';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _divisaoQuotasController,
                  decoration: const InputDecoration(
                    labelText: 'Divisão de Quotas *',
                    border: OutlineInputBorder(),
                    hintText: 'Ex: 1000 quotas de R\$ 1,00',
                    prefixIcon: Icon(Icons.pie_chart),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'A divisão de quotas é obrigatória';
                    }
                    return null;
                  },
                  maxLines: 2,
                  maxLength: 200,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _formasIntegralizacao.contains(
                    _formaIntegralizacaoController.text,
                  )
                      ? _formaIntegralizacaoController.text
                      : _formasIntegralizacao.first,
                  decoration: const InputDecoration(
                    labelText: 'Forma de Integralização *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.payments),
                  ),
                  items: _formasIntegralizacao.map((String forma) {
                    return DropdownMenuItem<String>(
                      value: forma,
                      child: Text(forma),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _formaIntegralizacaoController.text = newValue;
                      });
                    }
                  },
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'A forma de integralização é obrigatória';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Informe o valor total do capital social e como as quotas estão divididas.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue[900],
                          ),
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
          onPressed: _isCarregando ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isCarregando ? null : _salvar,
          child: _isCarregando
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              : Text(widget.capitalSocial == null ? 'Criar' : 'Salvar'),
        ),
      ],
    );
  }
}
