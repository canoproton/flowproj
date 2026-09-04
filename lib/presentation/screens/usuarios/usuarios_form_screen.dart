/// ============================================
/// FORMULÁRIO DE USUÁRIO
/// ============================================
/// Criação e edição de usuários com
/// seleção de nível de acesso
/// ============================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/usuarios/usuarios_provider.dart';
import '../../providers/auth/auth_provider.dart';
import '../../widgets/common/loading_widget.dart';

class UsuariosFormScreen extends StatefulWidget {
  final ProfileModel? usuario;

  const UsuariosFormScreen({super.key, this.usuario});

  @override
  State<UsuariosFormScreen> createState() => _UsuariosFormScreenState();
}

class _UsuariosFormScreenState extends State<UsuariosFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();
  final _cargoController = TextEditingController();
  final _departamentoController = TextEditingController();
  final _telefoneController = TextEditingController();

  NivelAcesso _nivelSelecionado = NivelAcesso.user;
  bool _isActive = true;
  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.usuario != null;
    if (_isEditing) {
      _preencherDados();
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
    _cargoController.dispose();
    _departamentoController.dispose();
    _telefoneController.dispose();
    super.dispose();
  }

  void _preencherDados() {
    final usuario = widget.usuario!;
    _nomeController.text = usuario.nome;
    _emailController.text = usuario.email ?? '';
    _cargoController.text = usuario.cargo ?? '';
    _departamentoController.text = usuario.departamento ?? '';
    _telefoneController.text = usuario.telefone ?? '';
    _nivelSelecionado = usuario.nivelAcesso;
    _isActive = usuario.isActive;
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final provider = context.read<UsuariosProvider>();

      if (_isEditing) {
        await provider.atualizarUsuario(
          id: widget.usuario!.id,
          nome: _nomeController.text,
          cargo: _cargoController.text.isEmpty ? null : _cargoController.text,
          departamento: _departamentoController.text.isEmpty ? null : _departamentoController.text,
          telefone: _telefoneController.text.isEmpty ? null : _telefoneController.text,
          nivelAcesso: _nivelSelecionado,
          isActive: _isActive,
        );
      } else {
        await provider.criarUsuario(
          email: _emailController.text,
          password: _senhaController.text,
          nome: _nomeController.text,
          nivelAcesso: _nivelSelecionado,
          cargo: _cargoController.text.isEmpty ? null : _cargoController.text,
          departamento: _departamentoController.text.isEmpty ? null : _departamentoController.text,
          telefone: _telefoneController.text.isEmpty ? null : _telefoneController.text,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing ? 'Usuário atualizado!' : 'Usuário criado!'),
            backgroundColor: AppTheme.successColor,
          ),
        );
        context.go('/usuarios');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro: ${e.toString().replaceFirst('Exception: ', '')}'),
          backgroundColor: AppTheme.dangerColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final podeGerenciar = authProvider.currentUser?.isAdmin ?? false;

    if (!podeGerenciar) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Acesso Negado'),
          backgroundColor: AppTheme.dangerColor,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock, size: 64, color: AppTheme.dangerColor),
              SizedBox(height: 16),
              Text(
                'Você não tem permissão para acessar esta tela.',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    if (_isLoading) {
      return const Scaffold(
        body: LoadingWidget(message: 'Salvando...'),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Usuário' : 'Novo Usuário'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _salvar,
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            child: const Text('Salvar', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nome
                  _buildTextField(
                    controller: _nomeController,
                    label: 'Nome Completo',
                    hint: 'Digite o nome completo',
                    icon: Icons.person,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'O nome é obrigatório';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Email
                  if (!_isEditing)
                    _buildTextField(
                      controller: _emailController,
                      label: 'Email',
                      hint: 'Digite o email do usuário',
                      icon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'O email é obrigatório';
                        }
                        final regex = RegExp(
                          r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                        );
                        if (!regex.hasMatch(value)) {
                          return 'Digite um email válido';
                        }
                        return null;
                      },
                    ),
                  const SizedBox(height: 16),

                  // Senha
                  if (!_isEditing) ...[
                    _buildTextField(
                      controller: _senhaController,
                      label: 'Senha',
                      hint: 'Mínimo 8 caracteres',
                      icon: Icons.lock,
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'A senha é obrigatória';
                        }
                        if (value.length < 8) {
                          return 'A senha deve ter pelo menos 8 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _confirmarSenhaController,
                      label: 'Confirmar Senha',
                      hint: 'Digite a senha novamente',
                      icon: Icons.lock_outline,
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Confirme a senha';
                        }
                        if (value != _senhaController.text) {
                          return 'As senhas não coincidem';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Cargo
                  _buildTextField(
                    controller: _cargoController,
                    label: 'Cargo',
                    hint: 'Ex: Administrador, Gerente',
                    icon: Icons.work_outline,
                  ),
                  const SizedBox(height: 16),

                  // Departamento
                  _buildTextField(
                    controller: _departamentoController,
                    label: 'Departamento',
                    hint: 'Ex: TI, Financeiro, RH',
                    icon: Icons.business_outline,
                  ),
                  const SizedBox(height: 16),

                  // Telefone
                  _buildTextField(
                    controller: _telefoneController,
                    label: 'Telefone',
                    hint: '(00) 00000-0000',
                    icon: Icons.phone,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),

                  // Nível de Acesso
                  _buildNivelSelector(),
                  const SizedBox(height: 16),

                  // Status
                  if (_isEditing)
                    _buildStatusToggle(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }

  Widget _buildNivelSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nível de Acesso',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: NivelAcesso.values.map((nivel) {
            final isSelected = _nivelSelecionado == nivel;
            return ChoiceChip(
              label: Text(nivel.label),
              selected: isSelected,
              onSelected: (_) {
                setState(() {
                  _nivelSelecionado = nivel;
                });
              },
              selectedColor: _getNivelCor(nivel).withAlpha(51),
              labelStyle: TextStyle(
                color: isSelected ? _getNivelCor(nivel) : Colors.grey.shade700,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
              avatar: isSelected
                  ? Icon(Icons.check, size: 16, color: _getNivelCor(nivel))
                  : null,
            );
          }).toList(),
        ),
        const SizedBox(height: 4),
        Text(
          _getNivelDescricao(_nivelSelecionado),
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusToggle() {
    return Row(
      children: [
        Switch(
          value: _isActive,
          onChanged: (value) {
            setState(() {
              _isActive = value;
            });
          },
          activeColor: AppTheme.successColor,
        ),
        const SizedBox(width: 8),
        Text(
          _isActive ? 'Usuário Ativo' : 'Usuário Inativo',
          style: TextStyle(
            fontSize: 16,
            color: _isActive ? AppTheme.successColor : AppTheme.dangerColor,
          ),
        ),
      ],
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

  String _getNivelDescricao(NivelAcesso nivel) {
    switch (nivel) {
      case NivelAcesso.hyper:
        return 'Acesso total e irrestrito a todos os módulos do sistema.';
      case NivelAcesso.admin:
        return 'Acesso administrativo total. Pode gerenciar usuários e permissões.';
      case NivelAcesso.manager:
        return 'Acesso a módulos operacionais. Pode delegar tarefas e gerenciar equipes.';
      case NivelAcesso.supervisor:
        return 'Acesso intermediário. Pode criar/editar recursos com limites.';
      case NivelAcesso.user:
        return 'Acesso básico. Pode visualizar e interagir com recursos atribuídos.';
      case NivelAcesso.guest:
        return 'Acesso mínimo. Apenas visualização de informações públicas.';
    }
  }
}