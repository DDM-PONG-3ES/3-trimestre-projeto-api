import 'package:desafio/modelo/entidades/socio/socio.dart';
import 'package:desafio/servicos/socio_servico.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class SociosScreen extends StatefulWidget {
  const SociosScreen({Key? key}) : super(key: key);

  @override
  State<SociosScreen> createState() => _SociosScreenState();
}

class _SociosScreenState extends State<SociosScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nomeController;
  late TextEditingController _cpfController;
  late TextEditingController _dataNascimentoController;
  late TextEditingController _residenciaController;
  String _statusSocial = 'Ativo';

  String _searchQuery = '';
  Socio? _socioEditando;
  List<Socio> _sociosFiltrados = [];

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController();
    _cpfController = TextEditingController();
    _dataNascimentoController = TextEditingController();
    _residenciaController = TextEditingController();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SocioServico>(context, listen: false).carregarSocios();
    });
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _cpfController.dispose();
    _dataNascimentoController.dispose();
    _residenciaController.dispose();
    super.dispose();
  }

  Future<void> _buscarSocios(String query) async {
    setState(() => _searchQuery = query);
    if (query.isEmpty) {
      setState(() => _sociosFiltrados = []);
    } else {
      final servico = Provider.of<SocioServico>(context, listen: false);
      final resultados = await servico.buscarSociosPorNome(query);
      setState(() => _sociosFiltrados = resultados);
    }
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    final servico = Provider.of<SocioServico>(context, listen: false);
    
    final socio = Socio(
      id: _socioEditando?.id,
      nome: _nomeController.text.trim(),
      cpf: _cpfController.text.trim(),
      statusSocial: _statusSocial,
      dataNascimento: _dataNascimentoController.text.trim(),
      residencia: _residenciaController.text.trim(),
    );

    bool sucesso;
    if (_socioEditando == null) {
      sucesso = await servico.criarSocio(socio);
    } else {
      sucesso = await servico.atualizarSocio(socio);
    }

    if (sucesso) {
      _mostrarSucesso(
        _socioEditando == null ? 'Sócio criado com sucesso' : 'Sócio atualizado com sucesso'
      );
      _limparFormulario();
    } else if (servico.erro != null) {
      _mostrarErro(servico.erro!);
      servico.limparErro();
    }
  }

  void _editarSocio(Socio socio) {
    setState(() {
      _socioEditando = socio;
      _nomeController.text = socio.nome;
      _cpfController.text = socio.cpf;
      _dataNascimentoController.text = socio.dataNascimento;
      _residenciaController.text = socio.residencia;
      _statusSocial = socio.statusSocial;
    });
    Scrollable.ensureVisible(
      _formKey.currentContext!,
      duration: const Duration(milliseconds: 300),
    );
  }

  Future<void> _deletarSocio(int id) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: const Text('Deseja realmente excluir este sócio?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      final servico = Provider.of<SocioServico>(context, listen: false);
      final sucesso = await servico.deletarSocio(id);
      
      if (sucesso) {
        _mostrarSucesso('Sócio excluído com sucesso');
        if (_socioEditando?.id == id) {
          _limparFormulario();
        }
      } else if (servico.erro != null) {
        _mostrarErro(servico.erro!);
        servico.limparErro();
      }
    }
  }

  void _limparFormulario() {
    setState(() {
      _socioEditando = null;
      _nomeController.clear();
      _cpfController.clear();
      _dataNascimentoController.clear();
      _residenciaController.clear();
      _statusSocial = 'Ativo';
    });
  }

  void _mostrarErro(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem), backgroundColor: Colors.red),
    );
  }

  void _mostrarSucesso(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sócios'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Provider.of<SocioServico>(context, listen: false).carregarSocios();
            },
          ),
        ],
      ),
      body: Consumer<SocioServico>(
        builder: (context, servico, child) {
          final socios = _searchQuery.isEmpty ? servico.socios : _sociosFiltrados;
          
          return Column(
            children: [
              // FORMULÁRIO
              Container(
                color: Colors.blue.shade50,
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        _socioEditando == null ? 'Novo Sócio' : 'Editando Sócio',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _nomeController,
                        decoration: InputDecoration(
                          labelText: 'Nome *',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.person, size: 20),
                        ),
                        validator: (value) =>
                            value?.isEmpty ?? true ? 'Nome é obrigatório' : null,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: _cpfController,
                              decoration: InputDecoration(
                                labelText: 'CPF *',
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                prefixIcon: const Icon(Icons.badge, size: 20),
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(11),
                              ],
                              validator: (value) {
                                if (value?.isEmpty ?? true) {
                                  return 'CPF obrigatório';
                                }
                                if (!servico.validarCPF(value!)) {
                                  return 'CPF inválido';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: _dataNascimentoController,
                              decoration: InputDecoration(
                                labelText: 'Data Nasc.',
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                prefixIcon:
                                    const Icon(Icons.calendar_today, size: 20),
                                hintText: 'DD/MM/AAAA',
                              ),
                              keyboardType: TextInputType.datetime,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: DropdownButtonFormField<String>(
                              value: _statusSocial,
                              decoration: InputDecoration(
                                labelText: 'Status',
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                prefixIcon: const Icon(Icons.info, size: 20),
                              ),
                              items: [
                                'Ativo',
                                'Inativo',
                                'Sócio Administrador',
                                'Sócio Cotista'
                              ]
                                  .map((status) => DropdownMenuItem(
                                        value: status,
                                        child: Text(status),
                                      ))
                                  .toList(),
                              onChanged: (value) =>
                                  setState(() => _statusSocial = value!),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 3,
                            child: TextFormField(
                              controller: _residenciaController,
                              decoration: InputDecoration(
                                labelText: 'Residência',
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                prefixIcon: const Icon(Icons.home, size: 20),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: servico.isCarregando ? null : _salvar,
                              icon: Icon(
                                _socioEditando == null ? Icons.add : Icons.save,
                              ),
                              label: Text(
                                _socioEditando == null ? 'ADICIONAR' : 'ATUALIZAR',
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                          if (_socioEditando != null) ...[
                            const SizedBox(width: 12),
                            ElevatedButton.icon(
                              onPressed: _limparFormulario,
                              icon: const Icon(Icons.clear),
                              label: const Text('CANCELAR'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // BARRA DE BUSCA
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Buscar sócios...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: _buscarSocios,
                ),
              ),

              // LISTA
              Expanded(
                child: servico.isCarregando
                    ? const Center(child: CircularProgressIndicator())
                    : socios.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.people_outline,
                                    size: 64, color: Colors.grey[400]),
                                const SizedBox(height: 12),
                                Text(
                                  _searchQuery.isEmpty
                                      ? 'Nenhum sócio cadastrado'
                                      : 'Nenhum sócio encontrado',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            itemCount: socios.length,
                            itemBuilder: (context, index) {
                              final socio = socios[index];
                              final isEditando = _socioEditando?.id == socio.id;
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                elevation: isEditando ? 4 : 1,
                                color: isEditando
                                    ? Colors.blue.shade50
                                    : Colors.white,
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor:
                                        isEditando ? Colors.blue : Colors.blue[300],
                                    child: Text(
                                      socio.nome[0].toUpperCase(),
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  title: Text(
                                    socio.nome,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'CPF: ${socio.cpf} • ${socio.statusSocial}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.edit,
                                          color: Colors.blue,
                                          size: 20,
                                        ),
                                        onPressed: () => _editarSocio(socio),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                          size: 20,
                                        ),
                                        onPressed: () => _deletarSocio(socio.id!),
                                      ),
                                    ],
                                  ),
                                  onTap: () => _editarSocio(socio),
                                ),
                              );
                            },
                          ),
              ),
            ],
          );
        },
      ),
    );
  }
}
