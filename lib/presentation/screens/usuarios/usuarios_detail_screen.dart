/// ============================================
/// DETALHES DO USUÁRIO
/// ============================================
/// Exibe informações detalhadas do usuário
/// e permite gerenciar permissões
/// ============================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/usuarios/usuarios_provider.dart';
import '../../providers/auth/auth_provider.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/usuarios/permission_toggle.dart';
import '../auth/login_screen.dart';

class UsuariosDetailScreen extends StatefulWidget {
  final String id;

  const UsuariosDetailScreen({super.key, required this.id});

  @override
  State<UsuariosDetailScreen> createState() => _UsuariosDetailScreenState();
}

class _UsuariosDetailScreenState extends State<UsuariosDetailScreen> {
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    setState(() => _isLoading = true);
    await context.read<UsuariosProvider>().selecionarUsuario(widget.id);
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UsuariosProvider>();
    final usuario = provider.usuarioSelecionado;
    final authProvider = context.watch<AuthProvider>();
    final podeGerenciar = authProvider.currentUser?.isAdmin ?? false;

    if (_isLoading || provider.isLoading) {
      return const Scaffold(
        body: LoadingWidget(message: 'Carregando...'),
      );
    }

    if (usuario == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Usuário não encontrado'),
          backgroundColor: AppTheme.dangerColor,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_off, size: 64, color: AppTheme.dangerColor),
              SizedBox(height: 16),
              Text('Usuário não encontrado'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text(usuario.nome),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          if (podeGerenciar)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                context.push('/usuarios/form', extra: usuario);
              },
              tooltip: 'Editar',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Card do Perfil
            _buildPerfilCard(usuario),
            const SizedBox(height: 16),

            // Estatísticas
            _buildStatsCard(usuario),
            const SizedBox(height: 16),

            // Permissões (apenas para admin)
            if (podeGerenciar) _buildPermissoesCard(provider),
          ],
        ),
      ),
    );
  }

  Widget _buildPerfilCard(ProfileModel usuario) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Avatar
            CircleAvatar(
              radius: 50,
              backgroundColor: _getNivelCor(usuario.nivelAcesso).withAlpha(26),
              child: Text(
                usuario.initials,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: _getNivelCor(usuario.nivelAcesso),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              usuario.nome,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            if (usuario.cargo != null) ...[
              const SizedBox(height: 4),
              Text(
                usuario.cargo!,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
            const SizedBox(height: 8),
            _buildNivelBadge(usuario.nivelAcesso),
            const SizedBox(height: 8),
            _buildStatusBadge(usuario.isActive),
            const Divider(height: 24),
            // Informações
            _buildInfoRow(Icons.email, 'Email', usuario.email ?? 'Não informado'),
            if (usuario.departamento != null)
              _buildInfoRow(Icons.business, 'Departamento', usuario.departamento!),
            if (usuario.telefone != null)
              _buildInfoRow(Icons.phone, 'Telefone', usuario.telefone!),
            if (usuario.isContato)
              _buildInfoRow(Icons.link, 'Contato', 'Vinculado a um contato'),
            _buildInfoRow(
              Icons.calendar_today,
              'Criado em',
              usuario.createdAt != null
                  ? _formatDate(usuario.createdAt!)
                  : 'Não informado',
            ),
            if (usuario.lastLogin != null)
              _buildInfoRow(
                Icons.login,
                'Último acesso',
                _formatDate(usuario.lastLogin!),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard(ProfileModel usuario) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            _buildStatItem(
              'Acessos',
              '12',
              Icons.history,
              AppTheme.primaryColor,
            ),
            const VerticalDivider(),
            _buildStatItem(
              'Módulos',
              '${context.watch<UsuariosProvider>().permissoes.where((p) => p.canRead).length}',
              Icons.grid_view,
              AppTheme.successColor,
            ),
            const VerticalDivider(),
            _buildStatItem(
              'Criado há',
              _getTimeAgo(usuario.createdAt!),
              Icons.calendar_today,
              AppTheme.warningColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissoesCard(UsuariosProvider provider) {
    if (provider.permissoes.isEmpty) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Permissões',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Nenhuma permissão configurada'),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Agrupar permissões
    final modules = provider.modulos;
    final permissoes = provider.permissoes;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Permissões por Módulo',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                if (_isSaving)
                  const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            ...modules.map((module) {
              final permissao = permissoes.firstWhere(
                (p) => p.moduleId == module.id,
                orElse: () => PermissionModel(
                  id: '',
                  profileId: provider.usuarioSelecionado!.id,
                  moduleId: module.id,
                ),
              );
              return PermissionToggle(
                module: module,
                permissao: permissao,
                onChanged: (updatedPermissao) {
                  _atualizarPermissao(updatedPermissao, provider);
                },
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Future<void> _atualizarPermissao(PermissionModel permissao, UsuariosProvider provider) async {
    setState(() => _isSaving = true);
    await provider.atualizarPermissao(permissao);
    setState(() => _isSaving = false);
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textPrimary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? AppTheme.successColor.withAlpha(26) : AppTheme.dangerColor.withAlpha(26),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isActive ? 'Ativo' : 'Inativo',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: isActive ? AppTheme.successColor : AppTheme.dangerColor,
        ),
      ),
    );
  }

  Widget _buildNivelBadge(NivelAcesso nivel) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: _getNivelCor(nivel).withAlpha(26),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        nivel.label,
        style: TextStyle(
          fontSize: 12,
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays > 0) {
      return '${diff.inDays} dia${diff.inDays > 1 ? 's' : ''} atrás';
    } else if (diff.inHours > 0) {
      return '${diff.inHours} hora${diff.inHours > 1 ? 's' : ''} atrás';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes} minuto${diff.inMinutes > 1 ? 's' : ''} atrás';
    } else {
      return 'Agora mesmo';
    }
  }

  String _getTimeAgo(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays > 30) {
      return '${(diff.inDays / 30).floor()} mês${(diff.inDays / 30).floor() > 1 ? 'es' : ''}';
    } else if (diff.inDays > 0) {
      return '${diff.inDays} dia${diff.inDays > 1 ? 's' : ''}';
    } else if (diff.inHours > 0) {
      return '${diff.inHours} hora${diff.inHours > 1 ? 's' : ''}';
    } else {
      return 'Hoje';
    }
  }
}