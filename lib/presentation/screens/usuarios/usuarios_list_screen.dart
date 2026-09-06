import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/auth/profile_model.dart';
import '../../providers/usuarios/usuarios_provider.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/usuarios/permission_toggle.dart';

class UsuariosListScreen extends StatefulWidget {
  const UsuariosListScreen({super.key});

  @override
  State<UsuariosListScreen> createState() => _UsuariosListScreenState();
}

class _UsuariosListScreenState extends State<UsuariosListScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool? _filtroAtivo;
  String? _filtroNivel;

  @override
  void initState() {
    super.initState();
    _carregarUsuarios();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ============================================
  // MÉTODO: Carregar usuários
  // ============================================
  void _carregarUsuarios() {
    final provider = context.read<UsuariosProvider>();
    provider.carregarUsuarios();
  }

  // ============================================
  // MÉTODO: Abrir formulário (criar/editar)
  // ============================================
  void _abrirFormulario({ProfileModel? usuario}) {
    context.push('/home/usuarios/form', extra: usuario);
  }

  // ============================================
  // MÉTODO: Ver detalhes do usuário
  // ============================================
  void _verDetalhes(String id) {
    context.push('/home/usuarios/detalhes/$id');
  }

  // ============================================
  // MÉTODO: Alternar status (ativo/inativo)
  // ============================================
  Future<void> _toggleStatus(ProfileModel usuario) async {
    final provider = context.read<UsuariosProvider>();
    try {
      if (usuario.isActive) {
        await provider.desativarUsuario(usuario.id);
      } else {
        await provider.ativarUsuario(usuario.id);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            usuario.isActive
                ? 'Usuário desativado com sucesso!'
                : 'Usuário ativado com sucesso!',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao alterar status: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Usuários'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _carregarUsuarios,
            tooltip: 'Recarregar',
          ),
        ],
      ),
      body: Consumer<UsuariosProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const LoadingWidget();
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Erro ao carregar usuários',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    provider.error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _carregarUsuarios,
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            );
          }

          if (provider.usuarios.isEmpty) {
            return EmptyStateWidget(
              title: 'Nenhum usuário cadastrado',
              subtitle: 'Clique no botão abaixo para criar um novo usuário.',
              icon: Icons.people_outline,
              buttonText: 'Novo Usuário',
              onPressed: () => _abrirFormulario(),
            );
          }

          return Column(
            children: [
              // Barra de busca e filtros
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Buscar por nome ou email...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _carregarUsuarios();
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onChanged: (value) {
                        // Atualizar search no provider
                        context.read<UsuariosProvider>().setSearchQuery(
                              value.isEmpty ? null : value,
                            );
                      },
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        // Filtro de status
                        ChoiceChip(
                          label: const Text('Ativos'),
                          selected: _filtroAtivo == true,
                          onSelected: (selected) {
                            setState(() {
                              _filtroAtivo = selected ? true : null;
                              _filtroNivel = null;
                            });
                            _carregarUsuarios();
                          },
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: const Text('Inativos'),
                          selected: _filtroAtivo == false,
                          onSelected: (selected) {
                            setState(() {
                              _filtroAtivo = selected ? false : null;
                              _filtroNivel = null;
                            });
                            _carregarUsuarios();
                          },
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: const Text('Todos'),
                          selected: _filtroAtivo == null,
                          onSelected: (selected) {
                            setState(() {
                              _filtroAtivo = null;
                              _filtroNivel = null;
                            });
                            _carregarUsuarios();
                          },
                        ),
                        const Spacer(),
                        // Botão novo usuário
                        FloatingActionButton.small(
                          onPressed: () => _abrirFormulario(),
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          child: const Icon(Icons.add),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Lista de usuários
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: provider.usuarios.length,
                  itemBuilder: (context, index) {
                    final usuario = provider.usuarios[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: usuario.isActive
                              ? Colors.green
                              : Colors.grey,
                          child: Text(
                            usuario.nome.isNotEmpty
                                ? usuario.nome[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          usuario.nome,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ID: ${usuario.userId.substring(0, 8)}...',
                              style: const TextStyle(fontSize: 12),
                            ),
                            if (usuario.cargo != null)
                              Text(
                                'Cargo: ${usuario.cargo}',
                                style: const TextStyle(fontSize: 12),
                              ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Status
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: usuario.isActive
                                    ? Colors.green
                                    : Colors.red,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                usuario.isActive ? 'Ativo' : 'Inativo',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Botão detalhes
                            IconButton(
                              icon: const Icon(Icons.visibility),
                              onPressed: () => _verDetalhes(usuario.id),
                              tooltip: 'Ver detalhes',
                            ),
                            // Botão editar
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () =>
                                  _abrirFormulario(usuario: usuario),
                              tooltip: 'Editar',
                            ),
                            // Botão status
                            IconButton(
                              icon: Icon(
                                usuario.isActive
                                    ? Icons.block
                                    : Icons.check_circle,
                                color: usuario.isActive ? Colors.red : Colors.green,
                              ),
                              onPressed: () => _toggleStatus(usuario),
                              tooltip: usuario.isActive
                                  ? 'Desativar'
                                  : 'Ativar',
                            ),
                          ],
                        ),
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