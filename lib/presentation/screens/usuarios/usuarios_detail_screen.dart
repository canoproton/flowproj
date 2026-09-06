import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/auth/profile_model.dart';
import '../../../data/models/usuarios/permission_model.dart';
import '../../providers/usuarios/usuarios_provider.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/usuarios/permission_toggle.dart';

class UsuariosDetailScreen extends StatefulWidget {
  final String id;

  const UsuariosDetailScreen({
    super.key,
    required this.id,
  });

  @override
  State<UsuariosDetailScreen> createState() => _UsuariosDetailScreenState();
}

class _UsuariosDetailScreenState extends State<UsuariosDetailScreen> {
  @override
  void initState() {
    super.initState();
    _carregarDetalhes();
  }

  void _carregarDetalhes() {
    final provider = context.read<UsuariosProvider>();
    provider.selecionarUsuario(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Usuário'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              context.push('/home/usuarios/form', extra: widget.id);
            },
          ),
        ],
      ),
      body: Consumer<UsuariosProvider>(
        builder: (context, provider, child) {
          if (provider.isLoadingDetail) {
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
                    'Erro ao carregar detalhes',
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
                    onPressed: () {
                      context.go('/home/usuarios');
                    },
                    child: const Text('Voltar para lista'),
                  ),
                ],
              ),
            );
          }

          final usuario = provider.usuarioSelecionado;
          if (usuario == null) {
            return const Center(
              child: Text('Usuário não encontrado'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoCard(context, usuario, provider),
                const SizedBox(height: 16),
                _buildPermissionsCard(context, provider),
                const SizedBox(height: 16),
                _buildModulesCard(context, provider),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      context.go('/home/usuarios');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade200,
                      foregroundColor: Colors.black,
                    ),
                    child: const Text('Voltar para lista'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ============================================
  // WIDGET: Card de informações
  // ============================================
  Widget _buildInfoCard(BuildContext context, ProfileModel usuario, UsuariosProvider provider) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: usuario.isActive ? Colors.green : Colors.grey,
                  child: Text(
                    usuario.nome.isNotEmpty ? usuario.nome[0].toUpperCase() : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        usuario.nome,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: usuario.isActive ? Colors.green : Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          usuario.isActive ? 'Ativo' : 'Inativo',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    usuario.isActive ? Icons.block : Icons.check_circle,
                    color: usuario.isActive ? Colors.red : Colors.green,
                  ),
                  onPressed: () {
                    _toggleStatus(context, usuario);
                  },
                  tooltip: usuario.isActive ? 'Desativar' : 'Ativar',
                ),
              ],
            ),
            const Divider(),
            _buildInfoRow('ID', usuario.userId),
            _buildInfoRow('Email', usuario.userId),
            if (usuario.cargo != null) _buildInfoRow('Cargo', usuario.cargo!),
            if (usuario.departamento != null) _buildInfoRow('Departamento', usuario.departamento!),
            if (usuario.telefone != null) _buildInfoRow('Telefone', usuario.telefone!),
            _buildInfoRow('Nível de Acesso', usuario.nivelAcesso.name),
            _buildInfoRow('Data de Criação', _formatDate(usuario.createdAt)),
            if (usuario.lastLogin != null)
              _buildInfoRow('Último Login', _formatDate(usuario.lastLogin!)),
          ],
        ),
      ),
    );
  }

  // ============================================
  // WIDGET: Linha de informação
  // ============================================
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  // ============================================
  // WIDGET: Card de permissões
  // ============================================
  Widget _buildPermissionsCard(BuildContext context, UsuariosProvider provider) {
    final permissoes = provider.permissoes;
    final modulos = provider.modulos;

    if (permissoes.isEmpty || modulos.isEmpty) {
      return Card(
        elevation: 2,
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: Text('Nenhuma permissão configurada'),
          ),
        ),
      );
    }

    return Card(
      elevation: 2,
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
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Gerencie as permissões de acesso do usuário',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            ...modulos.map((modulo) {
              final permissao = permissoes.firstWhere(
                (p) => p.moduleId == modulo.id,
                orElse: () => PermissionModel(
                  profileId: provider.usuarioSelecionado!.id,
                  moduleId: modulo.id,
                  canRead: false,
                  canWrite: false,
                  canDelete: false,
                  isCustom: false,
                ),
              );
              return PermissionToggle(
                module: modulo,  // ✅ CORRETO: 'module' em vez de 'modulo'
                permissao: permissao,
                onChanged: (updated) {
                  provider.atualizarPermissao(updated);
                },
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  // ============================================
  // WIDGET: Card de módulos
  // ============================================
  Widget _buildModulesCard(BuildContext context, UsuariosProvider provider) {
    final modulos = provider.modulos;

    if (modulos.isEmpty) {
      return Card(
        elevation: 2,
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: Text('Nenhum módulo disponível'),
          ),
        ),
      );
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Módulos Disponíveis',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Lista de módulos que o usuário pode acessar',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            ...modulos.map((modulo) {
              return ListTile(
                leading: Icon(
                  _getIconForModule(modulo.nome),
                  color: modulo.isActive ? Colors.blue : Colors.grey,
                ),
                title: Text(modulo.nome),
                subtitle: Text(modulo.descricao ?? ''),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: modulo.isActive ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    modulo.isActive ? 'Ativo' : 'Inativo',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                    ),
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  // ============================================
  // MÉTODO: Formatar data
  // ============================================
  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  // ============================================
  // MÉTODO: Alternar status
  // ============================================
  Future<void> _toggleStatus(BuildContext context, ProfileModel usuario) async {
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
      _carregarDetalhes();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao alterar status: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ============================================
  // MÉTODO: Buscar ícone para módulo
  // ============================================
  IconData _getIconForModule(String nome) {
    switch (nome.toLowerCase()) {
      case 'dashboard':
        return Icons.dashboard;
      case 'usuários':
        return Icons.people;
      case 'projetos':
        return Icons.folder;
      case 'tarefas':
        return Icons.task;
      case 'operacional':
        return Icons.build;
      case 'contabilidade':
        return Icons.account_balance;
      case 'financeiro':
        return Icons.attach_money;
      case 'documentos':
        return Icons.description;
      case 'ia':
        return Icons.psychology;
      default:
        return Icons.circle;
    }
  }
}