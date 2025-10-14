import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:desafio/servicos/sede_servico.dart';
import 'package:desafio/modelo/entidades/sede/sede.dart';
import 'package:desafio/modelo/entidades/clausula/clausula.dart';

class SedeTela extends StatefulWidget {
  final Clausula clausula;
  const SedeTela({super.key, required this.clausula});

  @override
  State<SedeTela> createState() => _SedeTelaState();
}

class _SedeTelaState extends State<SedeTela> {
  final _pesquisaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SedeServico>().carregarSedesPorClausula(widget.clausula.id!);
    });
  }

  @override
  void dispose() {
    _pesquisaController.dispose();
    super.dispose();
  }

  void _mostrarDialog({Sede? sede}) => showDialog(
    context: context,
    builder: (context) => _SedeDialog(sede: sede, clausulaId: widget.clausula.id!),
  );

  Future<void> _excluir(Sede sede) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: const Text('Tem certeza que deseja excluir esta sede?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Excluir', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmar == true && mounted) {
      final servico = context.read<SedeServico>();
      final sucesso = await servico.excluirSede(sede.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(sucesso ? 'Sede excluída com sucesso' : servico.erro ?? 'Erro ao excluir'),
            backgroundColor: sucesso ? null : Colors.red,
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
            const Text('Sedes'),
            Text(widget.clausula.tipo ?? 'Sem tipo', style: const TextStyle(fontSize: 14)),
          ],
        ),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tipo: ${widget.clausula.tipo ?? 'Não informado'}', style: const TextStyle(fontWeight: FontWeight.bold)),
                if (widget.clausula.status != null) Text('Status: ${widget.clausula.status}'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _pesquisaController,
              decoration: InputDecoration(
                labelText: 'Pesquisar sedes',
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
    return Consumer<SedeServico>(
      builder: (context, servico, _) {
        if (servico.isCarregando) return const Center(child: CircularProgressIndicator());

        var sedes = servico.sedes.where((s) => s.clausulaId == widget.clausula.id).toList();
        
        if (_pesquisaController.text.isNotEmpty) {
          sedes = sedes.where((s) => s.enderecoCompleto?.toLowerCase().contains(_pesquisaController.text.toLowerCase()) ?? false).toList();
        }

        if (sedes.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.location_on, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(_pesquisaController.text.isNotEmpty ? 'Nenhuma sede encontrada' : 'Nenhuma sede cadastrada', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                if (_pesquisaController.text.isEmpty) ...[
                  const SizedBox(height: 16),
                  ElevatedButton.icon(onPressed: () => _mostrarDialog(), icon: const Icon(Icons.add), label: const Text('Criar primeira sede')),
                ],
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => servico.carregarSedesPorClausula(widget.clausula.id!),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sedes.length,
            itemBuilder: (context, index) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(backgroundColor: Theme.of(context).primaryColor, child: const Icon(Icons.location_on, color: Colors.white)),
                title: Text(sedes[index].enderecoCompleto ?? 'Endereço não informado', style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
                subtitle: Text('Criado ${_formatarData(sedes[index].criadoEm)}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) => value == 'editar' ? _mostrarDialog(sede: sedes[index]) : _excluir(sedes[index]),
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 'editar', child: ListTile(leading: Icon(Icons.edit), title: Text('Editar'), contentPadding: EdgeInsets.zero)),
                    const PopupMenuItem(value: 'excluir', child: ListTile(leading: Icon(Icons.delete, color: Colors.red), title: Text('Excluir', style: TextStyle(color: Colors.red)), contentPadding: EdgeInsets.zero)),
                  ],
                ),
                onTap: () => _mostrarDialog(sede: sedes[index]),
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatarData(DateTime? data) {
    if (data == null) return 'Data não informada';
    final diff = DateTime.now().difference(data);
    if (diff.inDays > 7) return '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}';
    if (diff.inDays > 0) return 'há ${diff.inDays} dia${diff.inDays == 1 ? '' : 's'}';
    if (diff.inHours > 0) return 'há ${diff.inHours} hora${diff.inHours == 1 ? '' : 's'}';
    if (diff.inMinutes > 0) return 'há ${diff.inMinutes} minuto${diff.inMinutes == 1 ? '' : 's'}';
    return 'Agora';
  }
}

class _SedeDialog extends StatefulWidget {
  final Sede? sede;
  final int clausulaId;
  const _SedeDialog({this.sede, required this.clausulaId});

  @override
  State<_SedeDialog> createState() => _SedeDialogState();
}

class _SedeDialogState extends State<_SedeDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _controllers = {
    'rua': TextEditingController(),
    'numero': TextEditingController(),
    'complemento': TextEditingController(),
    'bairro': TextEditingController(),
    'cidade': TextEditingController(),
    'estado': TextEditingController(text: 'SP'),
    'cep': TextEditingController(),
  };
  
  bool _isCarregando = false;
  
  static const _estados = ['AC','AL','AP','AM','BA','CE','DF','ES','GO','MA','MT','MS','MG','PA','PB','PR','PE','PI','RJ','RN','RS','RO','RR','SC','SP','SE','TO'];

  @override
  void initState() {
    super.initState();
    if (widget.sede?.enderecoCompleto != null) _parseEndereco(widget.sede!.enderecoCompleto!);
  }

  void _parseEndereco(String end) {
    final partes = end.split(',').map((e) => e.trim()).toList();
    if (partes.isNotEmpty) _controllers['rua']!.text = partes[0];
    if (partes.length > 1) _controllers['numero']!.text = partes[1];
    if (partes.length > 2) _controllers['complemento']!.text = partes[2];
    if (partes.length > 3) _controllers['bairro']!.text = partes[3];
    if (partes.length > 4) {
      final ce = partes[4].split('-').map((e) => e.trim()).toList();
      if (ce.isNotEmpty) _controllers['cidade']!.text = ce[0];
      if (ce.length > 1) _controllers['estado']!.text = ce[1];
    }
    if (partes.length > 5) _controllers['cep']!.text = partes[5].replaceAll('CEP:', '').trim();
  }

  String _montarEndereco() {
    final p = <String>[];
    _controllers.forEach((k, v) {
      if (k != 'estado' && v.text.trim().isNotEmpty) {
        p.add(v.text.trim());
      }
    });
    if (p.length >= 4 && _controllers['estado']!.text.isNotEmpty) {
      p[3] = '${p[3]} - ${_controllers['estado']!.text}';
    }
    if (_controllers['cep']!.text.isNotEmpty) {
      p.add('CEP: ${_controllers['cep']!.text}');
    }
    return p.join(', ');
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isCarregando = true);

    try {
      final endereco = _montarEndereco();
      if (endereco.length < 10) throw Exception('Preencha os campos principais');

      final servico = context.read<SedeServico>();
      final sucesso = widget.sede == null
          ? await servico.criarSede(enderecoCompleto: endereco, clausulaId: widget.clausulaId)
          : await servico.atualizarSede(Sede(id: widget.sede!.id, enderecoCompleto: endereco, clausulaId: widget.clausulaId, criadoEm: widget.sede!.criadoEm, atualizadoEm: DateTime.now()));

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(sucesso ? '${widget.sede == null ? 'Criada' : 'Atualizada'} com sucesso' : servico.erro ?? 'Erro'), backgroundColor: sucesso ? null : Colors.red));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isCarregando = false);
    }
  }

  @override
  void dispose() {
    _controllers.values.forEach((c) => c.dispose());
    super.dispose();
  }

  Widget _buildField(String key, String label, {IconData? icon, String? hint, TextInputType? keyboard, List<TextInputFormatter>? formatters, int flex = 1}) {
    return Expanded(
      flex: flex,
      child: TextFormField(
        controller: _controllers[key],
        decoration: InputDecoration(labelText: '$label *', border: const OutlineInputBorder(), prefixIcon: icon != null ? Icon(icon) : null, hintText: hint),
        validator: (v) => v == null || v.trim().isEmpty ? 'Obrigatório' : (key == 'cep' && v.replaceAll(RegExp(r'[^0-9]'), '').length != 8 ? 'CEP inválido' : null),
        textCapitalization: key != 'cep' && key != 'numero' ? TextCapitalization.words : TextCapitalization.none,
        keyboardType: keyboard,
        inputFormatters: formatters,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(children: [Icon(Icons.location_on, color: Theme.of(context).primaryColor), const SizedBox(width: 8), Text(widget.sede == null ? 'Nova Sede' : 'Editar Sede')]),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildField('rua', 'Rua/Avenida', icon: Icons.signpost, hint: 'Ex: Rua das Flores'),
                const SizedBox(height: 12),
                Row(children: [_buildField('numero', 'Número', icon: Icons.pin, hint: '123'), const SizedBox(width: 8), _buildField('complemento', 'Complemento', icon: Icons.add_home, hint: 'Apto 101', flex: 2)]),
                const SizedBox(height: 12),
                _buildField('bairro', 'Bairro', icon: Icons.home_work, hint: 'Centro'),
                const SizedBox(height: 12),
                _buildField('cidade', 'Cidade', icon: Icons.location_city, hint: 'São Paulo'),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _estados.contains(_controllers['estado']!.text) ? _controllers['estado']!.text : 'SP',
                  decoration: const InputDecoration(labelText: 'Estado *', border: OutlineInputBorder(), prefixIcon: Icon(Icons.map)),
                  items: _estados.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (v) => setState(() => _controllers['estado']!.text = v!),
                ),
                const SizedBox(height: 12),
                _buildField('cep', 'CEP', icon: Icons.markunread_mailbox, hint: '12345-678', keyboard: TextInputType.number, formatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(8), _CepFormatter()]),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: _isCarregando ? null : () => Navigator.pop(context), child: const Text('Cancelar')),
        ElevatedButton(onPressed: _isCarregando ? null : _salvar, child: _isCarregando ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : Text(widget.sede == null ? 'Criar' : 'Salvar')),
      ],
    );
  }
}

class _CepFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue old, TextEditingValue novo) {
    final text = novo.text;
    if (text.length > 8) return old;
    if (text.length <= 5) return novo;
    final formatted = '${text.substring(0, 5)}-${text.substring(5)}';
    return TextEditingValue(text: formatted, selection: TextSelection.collapsed(offset: formatted.length));
  }
}