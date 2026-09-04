/// ============================================
/// LISTA DE USUÁRIOS
/// ============================================
/// Tela principal do módulo de usuários com
/// lista, busca e ações rápidas
/// ============================================

import 'package:flowproj/data/models/auth/profile_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/usuarios/usuarios_provider.dart';
import '../../providers/auth/auth_provider.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../auth/login_screen.dart';

class UsuariosListScreen extends StatefulWidget {
  const UsuariosListScreen({super.key});

  @override
  State<UsuariosListScreen> createState() => _UsuariosListScreenState();
}

class _UsuariosListScreenState extends State<UsuariosListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _filtroNivel;
  bool _filtroAtivo = true;

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

  void _carregarUsuarios() {
    final provider = context.read<UsuariosProvider>();
    provider.carregarUsuarios(
      search: _searchController.text.isEmpty ? null : _searchController.text,
      ativo: _filtroAtivo ? true : null,
      nivel: _filtroNivel != null ? NivelAcesso.fromString(_filtroNivel!) : null,
    );
  }

  void _abrirFormulario({ProfileModel? usuario}) {
    context.push('/usuarios/form', extra: usuario);
  }

  void _verDetalhes(String id) {
    context.push('/usuarios/detalhes/$id');
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UsuariosProvider>();
    final authProvider = context.watch<AuthProvider>();

    // Verificar permissão para gerenciar usuários
    final podeGerenciar = authProvider.currentUser?.isAdmin ?? false;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Usuários'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          if (podeGerenciar)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _abrirFormulario(),
              tooltip: 'Novo Usuário',
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _carregarUsuarios,
            tooltip: 'Atualizar',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtros
          _buildFiltros(podeGerenciar),

          // Conteúdo
          Expanded(
            child: _buildConteudo(provider),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltros(bool podeGerenciar) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Buscar por nome ou email...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  onSubmitted: (_) => _carregarUsuarios(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  _carregarUsuarios();
                },
                tooltip: 'Limpar busca',
              ),
              ElevatedButton(
                onPressed: _carregarUsuarios,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                child: const Text('Buscar'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              // Filtro por status
              ChoiceChip(
                label: const Text('Ativos'),
                selected: _filtroAtivo == true,
                onSelected: (_) {
                  setState(() {
                    _filtroAtivo = _filtroAtivo == true ? false : true;
                  });
                  _carregarUsuarios();
                },
                selectedColor: AppTheme.successColor.withAlpha(51),
                labelStyle: TextStyle(
                  color: _filtroAtivo == true ? AppTheme.successColor : Colors.grey.shade600,
                ),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Inativos'),
                selected: _filtroAtivo == false,
                onSelected: (_) {
                  setState(() {
                    _filtroAtivo = _filtroAtivo == false ? null : false;
                  });
                  _carregarUsuarios();
                },
                selectedColor: AppTheme.dangerColor.withAlpha(51),
                labelStyle: TextStyle(
                  color: _filtroAtivo == false ? AppTheme.dangerColor : Colors.grey.shade600,
                ),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Todos'),
                selected: _filtroAtivo == null,
                onSelected: (_) {
                  setState(() {
                    _filtroAtivo = null;
                  });
                  _carregarUsuarios();
                },
                selectedColor: Colors.grey.shade300,
              ),
              const Spacer(),
              // Filtro por nível
              if (podeGerenciar)
                DropdownButton<String>(
                  value: _filtroNivel,
                  hint: const Text('Nível'),
                  isDense: true,
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Todos')),
                    ...NivelAcesso.values.map((nivel) {
                      return DropdownMenuItem(
                        value: nivel.name.toUpperCase(),
                        child: Text(nivel.label),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _filtroNivel = value;
                    });
                    _carregarUsuarios();
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConteudo(UsuariosProvider provider) {
    if (provider.isLoading) {
      return const LoadingWidget();
    }

    if (provider.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: AppTheme.dangerColor),
            const SizedBox(height: 16),
            Text(
              provider.error!,
              style: TextStyle(color: AppTheme.dangerColor),
              textAlign: TextAlign.center,
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
      return const EmptyStateWidget(
        icon: Icons.people_outline,
        title: 'Nenhum usuário encontrado',
        subtitle: 'Crie um novo usuário para começar',
      );
    }

    return RefreshIndicator(
      onRefresh: () async => _carregarUsuarios(),
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: provider.usuarios.length,
        itemBuilder: (context, index) {
          final usuario = provider.usuarios[index];
          return _buildUsuarioCard(usuario);
        },
      ),
    );
  }

  Widget _buildUsuarioCard(ProfileModel usuario) {
    final podeGerenciar = context.read<AuthProvider>().currentUser?.isAdmin ?? false;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getNivelCor(usuario.nivelAcesso).withAlpha(26),
          child: Text(
            usuario.initials,
            style: TextStyle(
              color: _getNivelCor(usuario.nivelAcesso),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        title: Text(
          usuario.nome,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: usuario.isActive ? AppTheme.textPrimary : Colors.grey.shade500,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(usuario.email ?? usuario.userId),
            if (usuario.cargo != null)
              Text(
                usuario.cargo!,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatusBadge(usuario.isActive),
            const SizedBox(width: 8),
            _buildNivelBadge(usuario.nivelAcesso),
            const SizedBox(width: 8),
            if (podeGerenciar)
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) {
                  switch (value) {
                    case 'editar':
                      _abrirFormulario(usuario: usuario);
                      break;
                    case 'detalhes':
                      _verDetalhes(usuario.id);
                      break;
                    case 'desativar':
                      _confirmarDesativar(usuario);
                      break;
                    case 'ativar':
                      _confirmarAtivar(usuario);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'detalhes',
                    child: Row(
                      children: [
                        Icon(Icons.visibility, size: 20),
                        SizedBox(width: 8),
                        Text('Detalhes'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'editar',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 20),
                        SizedBox(width: 8),
                        Text('Editar'),
                      ],
                    ),
                  ),
                  if (usuario.isActive)
                    const PopupMenuItem(
                      value: 'desativar',
                      child: Row(
                        children: [
                          Icon(Icons.block, size: 20, color: AppTheme.dangerColor),
                          SizedBox(width: 8),
                          Text('Desativar', style: TextStyle(color: AppTheme.dangerColor)),
                        ],
                      ),
                    )
                  else
                    const PopupMenuItem(
                      value: 'ativar',
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, size: 20, color: AppTheme.successColor),
                          SizedBox(width: 8),
                          Text('Ativar', style: TextStyle(color: AppTheme.successColor)),
                        ],
                      ),
                    ),
                ],
              ),
          ],
        ),
        onTap: () => _verDetalhes(usuario.id),
      ),
    );
  }

  Widget _buildStatusBadge(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? AppTheme.successColor.withAlpha(26) : AppTheme.dangerColor.withAlpha(26),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isActive ? 'Ativo' : 'Inativo',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: isActive ? AppTheme.successColor : AppTheme.dangerColor,
        ),
      ),
    );
  }

  Widget _buildNivelBadge(NivelAcesso nivel) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getNivelCor(nivel).withAlpha(26),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        nivel.label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: _getNivelCor(nivel),
        ),
      ),
    );
  }

  Color _getNivelCor(NivelAcesso nivel) {
    switch (nivel) {
      case NivelAcesso.hyper:
        return Colors.red.shade700;
      case NivelAcesso.admin:
        return AppTheme.primaryColor;
      case NivelAcesso.manager:
        return AppTheme.successColor;
      case NivelAcesso.supervisor:
        return AppTheme.warningColor;
      case NivelAcesso.user:
        return Colors.grey.shade700;
      case NivelAcesso.guest:
        return Colors.grey.shade500;
    }
  }

  void _confirmarDesativar(ProfileModel usuario) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Desativar Usuário'),
        content: Text('Deseja realmente desativar o usuário "${usuario.nome}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await context.read<UsuariosProvider>().desativarUsuario(usuario.id);
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.dangerColor),
            child: const Text('Desativar'),
          ),
        ],
      ),
    );
  }

  void _confirmarAtivar(ProfileModel usuario) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ativar Usuário'),
        content: Text('Deseja reativar o usuário "${usuario.nome}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await context.read<UsuariosProvider>().ativarUsuario(usuario.id);
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.successColor),
            child: const Text('Ativar'),
          ),
        ],
      ),
    );
  }
}