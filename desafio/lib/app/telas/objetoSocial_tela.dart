import 'package:desafio/modelo/entidades/objetoSocial/objetoSocial.dart';
import 'package:desafio/servicos/objetoSocial_servico.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ObjetosSociaisScreen extends StatefulWidget {
  const ObjetosSociaisScreen({Key? key}) : super(key: key);

  @override
  State<ObjetosSociaisScreen> createState() => _ObjetosSociaisScreenState();
}

class _ObjetosSociaisScreenState extends State<ObjetosSociaisScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _atividadesEconomicasController;
  late TextEditingController _atividadesExercidasController;

  String _searchQuery = '';
  ObjetoSocial? _objetoEditando;
  List<ObjetoSocial> _objetosFiltrados = [];

  @override
  void initState() {
    super.initState();
    _atividadesEconomicasController = TextEditingController();
    _atividadesExercidasController = TextEditingController();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ObjetoSocialServico>(context, listen: false).carregarObjetosSociais();
    });
  }

  @override
  void dispose() {
    _atividadesEconomicasController.dispose();
    _atividadesExercidasController.dispose();
    super.dispose();
  }

  Future<void> _buscarObjetosSociais(String query) async {
    setState(() => _searchQuery = query);
    if (query.isEmpty) {
      setState(() => _objetosFiltrados = []);
    } else {
      final servico = Provider.of<ObjetoSocialServico>(context, listen: false);
      final resultados = await servico.buscarPorAtividade(query);
      setState(() => _objetosFiltrados = resultados);
    }
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    final servico = Provider.of<ObjetoSocialServico>(context, listen: false);
    
    final objetoSocial = ObjetoSocial(
      id: _objetoEditando?.id,
      atividadesEconomicas: _atividadesEconomicasController.text.trim(),
      atividadesExercidas: _atividadesExercidasController.text.trim(),
    );

    bool sucesso;
    if (_objetoEditando == null) {
      sucesso = await servico.criarObjetoSocial(objetoSocial);
    } else {
      sucesso = await servico.atualizarObjetoSocial(objetoSocial);
    }

    if (sucesso) {
      _mostrarSucesso(
        _objetoEditando == null 
          ? 'Objeto social criado com sucesso' 
          : 'Objeto social atualizado com sucesso'
      );
      _limparFormulario();
    } else if (servico.erro != null) {
      _mostrarErro(servico.erro!);
      servico.limparErro();
    }
  }

  void _editarObjetoSocial(ObjetoSocial objetoSocial) {
    setState(() {
      _objetoEditando = objetoSocial;
      _atividadesEconomicasController.text = objetoSocial.atividadesEconomicas;
      _atividadesExercidasController.text = objetoSocial.atividadesExercidas;
    });
    Scrollable.ensureVisible(
      _formKey.currentContext!,
      duration: const Duration(milliseconds: 300),
    );
  }

  Future<void> _deletarObjetoSocial(int id) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: const Text('Deseja realmente excluir este objeto social?'),
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
      final servico = Provider.of<ObjetoSocialServico>(context, listen: false);
      final sucesso = await servico.deletarObjetoSocial(id);
      
      if (sucesso) {
        _mostrarSucesso('Objeto social excluído com sucesso');
        if (_objetoEditando?.id == id) {
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
      _objetoEditando = null;
      _atividadesEconomicasController.clear();
      _atividadesExercidasController.clear();
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
        title: const Text('Objetos Sociais'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Provider.of<ObjetoSocialServico>(context, listen: false)
                  .carregarObjetosSociais();
            },
          ),
        ],
      ),
      body: Consumer<ObjetoSocialServico>(
        builder: (context, servico, child) {
          final objetosSociais = _searchQuery.isEmpty 
              ? servico.objetosSociais 
              : _objetosFiltrados;
          
          return Column(
            children: [
              // FORMULÁRIO
              Container(
                color: Colors.green.shade50,
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        _objetoEditando == null
                            ? 'Novo Objeto Social'
                            : 'Editando Objeto Social',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _atividadesEconomicasController,
                        decoration: InputDecoration(
                          labelText: 'Atividades Econômicas *',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon:
                              const Icon(Icons.business_center, size: 20),
                          hintText: 'Descreva as atividades econômicas',
                        ),
                        maxLines: 3,
                        validator: (value) => value?.isEmpty ?? true
                            ? 'Atividades econômicas são obrigatórias'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _atividadesExercidasController,
                        decoration: InputDecoration(
                          labelText: 'Atividades Exercidas *',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.work, size: 20),
                          hintText: 'Descreva as atividades exercidas',
                        ),
                        maxLines: 3,
                        validator: (value) => value?.isEmpty ?? true
                            ? 'Atividades exercidas são obrigatórias'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: servico.isCarregando ? null : _salvar,
                              icon: Icon(
                                _objetoEditando == null ? Icons.add : Icons.save,
                              ),
                              label: Text(
                                _objetoEditando == null
                                    ? 'ADICIONAR'
                                    : 'ATUALIZAR',
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                          if (_objetoEditando != null) ...[
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
                    hintText: 'Buscar atividades...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: _buscarObjetosSociais,
                ),
              ),

              // LISTA
              Expanded(
                child: servico.isCarregando
                    ? const Center(child: CircularProgressIndicator())
                    : objetosSociais.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.business_outlined,
                                    size: 64, color: Colors.grey[400]),
                                const SizedBox(height: 12),
                                Text(
                                  _searchQuery.isEmpty
                                      ? 'Nenhum objeto social cadastrado'
                                      : 'Nenhum objeto social encontrado',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            itemCount: objetosSociais.length,
                            itemBuilder: (context, index) {
                              final objetoSocial = objetosSociais[index];
                              final isEditando =
                                  _objetoEditando?.id == objetoSocial.id;
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                elevation: isEditando ? 4 : 1,
                                color: isEditando
                                    ? Colors.green.shade50
                                    : Colors.white,
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: isEditando
                                        ? Colors.green
                                        : Colors.green[300],
                                    child: const Icon(Icons.business,
                                        color: Colors.white),
                                  ),
                                  title: Text(
                                    objetoSocial.atividadesEconomicas,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  subtitle: Text(
                                    objetoSocial.atividadesExercidas,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.edit,
                                          color: Colors.green,
                                          size: 20,
                                        ),
                                        onPressed: () =>
                                            _editarObjetoSocial(objetoSocial),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                          size: 20,
                                        ),
                                        onPressed: () =>
                                            _deletarObjetoSocial(objetoSocial.id!),
                                      ),
                                    ],
                                  ),
                                  onTap: () => _editarObjetoSocial(objetoSocial),
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
              
