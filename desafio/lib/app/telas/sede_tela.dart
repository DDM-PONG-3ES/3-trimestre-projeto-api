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
  final TextEditingController _pesquisaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SedeServico>(
        context,
        listen: false,
      ).carregarSedesPorClausula(widget.clausula.id!);
    });
  }

  @override
  void dispose() {
    _pesquisaController.dispose();
    super.dispose();
  }

  void _mostrarDialogoSede({Sede? sede}) {
    showDialog(
      context: context,
      builder: (context) => _SedeDialog(
        sede: sede,
        clausulaId: widget.clausula.id!,
      ),
    );
  }

  void _excluirSede(Sede sede) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: const Text(
          'Tem certeza que deseja excluir esta sede?',
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
      final sedeServico = Provider.of<SedeServico>(
        context,
        listen: false,
      );
      final sucesso = await sedeServico.excluirSede(sede.id!);

      if (sucesso && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sede excluída com sucesso')),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(sedeServico.erro ?? 'Erro ao excluir sede'),
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
            const Text('Sedes'),
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
                labelText: 'Pesquisar sedes',
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
            child: _buildSedesList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarDialogoSede(),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSedesList() {
    return Consumer<SedeServico>(
      builder: (context, sedeServico, child) {
        if (sedeServico.isCarregando) {
          return const Center(child: CircularProgressIndicator());
        }

        List<Sede> sedes = sedeServico.sedes
            .where((s) => s.clausulaId == widget.clausula.id)
            .toList();

        if (_pesquisaController.text.isNotEmpty) {
          sedes = sedes.where((s) =>
            s.enderecoCompleto?.toLowerCase().contains(
              _pesquisaController.text.toLowerCase(),
            ) == true
          ).toList();
        }

        if (sedes.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.location_on, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  _pesquisaController.text.isNotEmpty
                      ? 'Nenhuma sede encontrada para "${_pesquisaController.text}"'
                      : 'Nenhuma sede encontrada',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                if (_pesquisaController.text.isEmpty) ...[
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _mostrarDialogoSede(),
                    icon: const Icon(Icons.add),
                    label: const Text('Criar primeira sede'),
                  ),
                ],
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => sedeServico.carregarSedesPorClausula(
            widget.clausula.id!,
          ),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sedes.length,
            itemBuilder: (context, index) {
              final sede = sedes[index];
              return _buildSedeCard(sede);
            },
          ),
        );
      },
    );
  }

  Widget _buildSedeCard(Sede sede) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor,
          child: const Icon(Icons.location_on, color: Colors.white),
        ),
        title: Text(
          sede.enderecoCompleto ?? 'Endereço não informado',
          style: const TextStyle(fontWeight: FontWeight.bold),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'Criado em ${_formatarData(sede.criadoEm)}',
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
                _mostrarDialogoSede(sede: sede);
                break;
              case 'excluir':
                _excluirSede(sede);
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
        onTap: () => _mostrarDialogoSede(sede: sede),
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

class _SedeDialog extends StatefulWidget {
  final Sede? sede;
  final int clausulaId;

  const _SedeDialog({this.sede, required this.clausulaId});

  @override
  State<_SedeDialog> createState() => _SedeDialogState();
}

class _SedeDialogState extends State<_SedeDialog> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers para cada campo do endereço
  late TextEditingController _ruaController;
  late TextEditingController _numeroController;
  late TextEditingController _complementoController;
  late TextEditingController _bairroController;
  late TextEditingController _cidadeController;
  late TextEditingController _estadoController;
  late TextEditingController _cepController;
  
  bool _isCarregando = false;

  final List<String> _estadosBrasil = [
    'AC', 'AL', 'AP', 'AM', 'BA', 'CE', 'DF', 'ES', 'GO', 'MA',
    'MT', 'MS', 'MG', 'PA', 'PB', 'PR', 'PE', 'PI', 'RJ', 'RN',
    'RS', 'RO', 'RR', 'SC', 'SP', 'SE', 'TO'
  ];

  @override
  void initState() {
    super.initState();
    
    // Se está editando, parsear o endereço completo
    if (widget.sede?.enderecoCompleto != null) {
      _parseEndereco(widget.sede!.enderecoCompleto!);
    } else {
      _ruaController = TextEditingController();
      _numeroController = TextEditingController();
      _complementoController = TextEditingController();
      _bairroController = TextEditingController();
      _cidadeController = TextEditingController();
      _estadoController = TextEditingController(text: 'SP');
      _cepController = TextEditingController();
    }
  }

  void _parseEndereco(String enderecoCompleto) {
    // Tenta extrair as partes do endereço
    // Formato esperado: "Rua X, 123, Complemento, Bairro, Cidade - UF, CEP: 12345-678"
    
    final partes = enderecoCompleto.split(',').map((e) => e.trim()).toList();
    
    _ruaController = TextEditingController(
      text: partes.isNotEmpty ? partes[0] : '',
    );
    _numeroController = TextEditingController(
      text: partes.length > 1 ? partes[1] : '',
    );
    _complementoController = TextEditingController(
      text: partes.length > 2 ? partes[2] : '',
    );
    _bairroController = TextEditingController(
      text: partes.length > 3 ? partes[3] : '',
    );
    
    // Cidade e Estado
    if (partes.length > 4) {
      final cidadeEstado = partes[4].split('-').map((e) => e.trim()).toList();
      _cidadeController = TextEditingController(
        text: cidadeEstado.isNotEmpty ? cidadeEstado[0] : '',
      );
      _estadoController = TextEditingController(
        text: cidadeEstado.length > 1 ? cidadeEstado[1] : 'SP',
      );
    } else {
      _cidadeController = TextEditingController();
      _estadoController = TextEditingController(text: 'SP');
    }
    
    // CEP
    if (partes.length > 5) {
      final cepParte = partes[5].replaceAll('CEP:', '').trim();
      _cepController = TextEditingController(text: cepParte);
    } else {
      _cepController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _ruaController.dispose();
    _numeroController.dispose();
    _complementoController.dispose();
    _bairroController.dispose();
    _cidadeController.dispose();
    _estadoController.dispose();
    _cepController.dispose();
    super.dispose();
  }

  String _montarEnderecoCompleto() {
    // Monta o endereço completo a partir dos campos
    final partes = <String>[];
    
    if (_ruaController.text.trim().isNotEmpty) {
      partes.add(_ruaController.text.trim());
    }
    if (_numeroController.text.trim().isNotEmpty) {
      partes.add(_numeroController.text.trim());
    }
    if (_complementoController.text.trim().isNotEmpty) {
      partes.add(_complementoController.text.trim());
    }
    if (_bairroController.text.trim().isNotEmpty) {
      partes.add(_bairroController.text.trim());
    }
    
    String cidadeEstado = '';
    if (_cidadeController.text.trim().isNotEmpty) {
      cidadeEstado = _cidadeController.text.trim();
    }
    if (_estadoController.text.trim().isNotEmpty) {
      cidadeEstado += ' - ${_estadoController.text.trim()}';
    }
    if (cidadeEstado.isNotEmpty) {
      partes.add(cidadeEstado);
    }
    
    if (_cepController.text.trim().isNotEmpty) {
      partes.add('CEP: ${_cepController.text.trim()}');
    }
    
    return partes.join(', ');
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isCarregando = true);

    final sedeServico = Provider.of<SedeServico>(
      context,
      listen: false,
    );
    bool sucesso = false;

    try {
      final enderecoCompleto = _montarEnderecoCompleto();
      
      if (enderecoCompleto.length < 10) {
        throw Exception('Preencha pelo menos os campos principais do endereço');
      }

      if (widget.sede == null) {
        sucesso = await sedeServico.criarSede(
          enderecoCompleto: enderecoCompleto,
          clausulaId: widget.clausulaId,
        );
      } else {
        final sedeAtualizada = Sede(
          id: widget.sede!.id,
          enderecoCompleto: enderecoCompleto,
          clausulaId: widget.clausulaId,
          criadoEm: widget.sede!.criadoEm,
          atualizadoEm: DateTime.now(),
        );

        sucesso = await sedeServico.atualizarSede(sedeAtualizada);
      }

      if (sucesso && mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.sede == null
                  ? 'Sede criada com sucesso'
                  : 'Sede atualizada com sucesso',
            ),
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(sedeServico.erro ?? 'Erro ao salvar sede'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
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
            Icons.location_on,
            color: Theme.of(context).primaryColor,
            size: 28,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              widget.sede == null ? 'Nova Sede' : 'Editar Sede',
            ),
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
                // Rua
                TextFormField(
                  controller: _ruaController,
                  decoration: const InputDecoration(
                    labelText: 'Rua/Avenida *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.signpost),
                    hintText: 'Ex: Rua das Flores',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'A rua é obrigatória';
                    }
                    return null;
                  },
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 12),
                
                // Número e Complemento
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: TextFormField(
                        controller: _numeroController,
                        decoration: const InputDecoration(
                          labelText: 'Número *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.pin),
                          hintText: '123',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Obrigatório';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.text,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _complementoController,
                        decoration: const InputDecoration(
                          labelText: 'Complemento *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.add_home),
                          hintText: 'Apto 101',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Obrigatório';
                          }
                          return null;
                        },
                        textCapitalization: TextCapitalization.words,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Bairro
                TextFormField(
                  controller: _bairroController,
                  decoration: const InputDecoration(
                    labelText: 'Bairro *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.home_work),
                    hintText: 'Ex: Centro',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'O bairro é obrigatório';
                    }
                    return null;
                  },
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 12),
                
                // Cidade
                TextFormField(
                  controller: _cidadeController,
                  decoration: const InputDecoration(
                    labelText: 'Cidade *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.location_city),
                    hintText: 'Ex: São Paulo',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'A cidade é obrigatória';
                    }
                    return null;
                  },
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 12),
                
                // Estado
                DropdownButtonFormField<String>(
                  value: _estadosBrasil.contains(_estadoController.text) 
                      ? _estadoController.text 
                      : 'SP',
                  decoration: const InputDecoration(
                    labelText: 'Estado *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.map),
                  ),
                  items: _estadosBrasil.map((String estado) {
                    return DropdownMenuItem<String>(
                      value: estado,
                      child: Text(estado),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _estadoController.text = newValue;
                      });
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'O estado é obrigatório';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                
                // CEP
                TextFormField(
                  controller: _cepController,
                  decoration: const InputDecoration(
                    labelText: 'CEP *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.markunread_mailbox),
                    hintText: '12345-678',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'O CEP é obrigatório';
                    }
                    // Validação simples de CEP
                    final cepLimpo = value.replaceAll(RegExp(r'[^0-9]'), '');
                    if (cepLimpo.length != 8) {
                      return 'CEP inválido';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(8),
                    _CepInputFormatter(),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Box informativo
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
                          'Todos os campos marcados com * são obrigatórios.',
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
              : Text(widget.sede == null ? 'Criar' : 'Salvar'),
        ),
      ],
    );
  }
}

// Formatador para CEP (00000-000)
class _CepInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    
    if (text.length > 8) {
      return oldValue;
    }
    
    if (text.length <= 5) {
      return newValue;
    }
    
    final formatted = '${text.substring(0, 5)}-${text.substring(5)}';
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
