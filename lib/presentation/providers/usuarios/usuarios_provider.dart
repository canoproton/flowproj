/// ============================================
/// PROVIDER DE USUÁRIOS
/// ============================================
/// Gerencia o estado do módulo de usuários
/// ============================================

import 'package:flutter/material.dart';
import 'package:flowproj/data/repositories/usuarios/usuarios_repository.dart';
import 'package:flowproj/data/repositories/usuarios/permission_repository.dart';
import 'package:flowproj/data/models/auth/profile_model.dart';
import 'package:flowproj/data/models/usuarios/permission_model.dart';
import 'package:flowproj/data/models/usuarios/module_model.dart';

class UsuariosProvider extends ChangeNotifier {
  final UsuariosRepository _repository = UsuariosRepository();
  final PermissionRepository _permissionRepository = PermissionRepository();

  List<ProfileModel> _usuarios = [];
  ProfileModel? _usuarioSelecionado;
  List<PermissionModel> _permissoes = [];
  List<ModuleModel> _modulos = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<ProfileModel> get usuarios => _usuarios;
  ProfileModel? get usuarioSelecionado => _usuarioSelecionado;
  List<PermissionModel> get permissoes => _permissoes;
  List<ModuleModel> get modulos => _modulos;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get totalUsuarios => _usuarios.length;
  int get usuariosAtivos => _usuarios.where((u) => u.isActive).length;

  // ============================================
  // 1. CARREGAR USUÁRIOS
  // ============================================
  Future<void> carregarUsuarios({
    String? search,
    bool? ativo,
    NivelAcesso? nivel,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _usuarios = await _repository.listarUsuarios(
        search: search,
        ativo: ativo,
        nivel: nivel,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  // ============================================
  // 2. SELECIONAR USUÁRIO
  // ============================================
  Future<void> selecionarUsuario(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _usuarioSelecionado = await _repository.buscarUsuarioPorId(id);
      if (_usuarioSelecionado != null) {
        await _carregarPermissoes(_usuarioSelecionado!.id);
        await _carregarModulos();
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  // ============================================
  // 3. CRIAR USUÁRIO
  // ============================================
  Future<ProfileModel?> criarUsuario({
    required String email,
    required String password,
    required String nome,
    required NivelAcesso nivelAcesso,
    String? cargo,
    String? departamento,
    String? telefone,
    String? avatarUrl,
    String? contatoId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final usuario = await _repository.criarUsuario(
        email: email,
        password: password,
        nome: nome,
        nivelAcesso: nivelAcesso,
        cargo: cargo,
        departamento: departamento,
        telefone: telefone,
        avatarUrl: avatarUrl,
        contatoId: contatoId,
      );

      await carregarUsuarios();
      _isLoading = false;
      notifyListeners();
      return usuario;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  // ============================================
  // 4. ATUALIZAR USUÁRIO
  // ============================================
  Future<ProfileModel?> atualizarUsuario({
    required String id,
    String? nome,
    String? cargo,
    String? departamento,
    String? telefone,
    String? avatarUrl,
    NivelAcesso? nivelAcesso,
    bool? isActive,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final usuario = await _repository.atualizarUsuario(
        id: id,
        nome: nome,
        cargo: cargo,
        departamento: departamento,
        telefone: telefone,
        avatarUrl: avatarUrl,
        nivelAcesso: nivelAcesso,
        isActive: isActive,
      );

      await carregarUsuarios();

      if (_usuarioSelecionado?.id == id) {
        _usuarioSelecionado = usuario;
      }

      _isLoading = false;
      notifyListeners();
      return usuario;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  // ============================================
  // 5. DESATIVAR USUÁRIO
  // ============================================
  Future<bool> desativarUsuario(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.desativarUsuario(id);
      await carregarUsuarios();

      if (_usuarioSelecionado?.id == id) {
        _usuarioSelecionado = null;
        _permissoes = [];
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ============================================
  // 6. ATIVAR USUÁRIO
  // ============================================
  Future<bool> ativarUsuario(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.ativarUsuario(id);
      await carregarUsuarios();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ============================================
  // 7. CARREGAR PERMISSÕES
  // ============================================
  Future<void> _carregarPermissoes(String profileId) async {
    try {
      _permissoes = await _permissionRepository.buscarPermissoesPorUsuario(profileId);
    } catch (e) {
      _permissoes = [];
    }
  }

  // ============================================
  // 8. CARREGAR MÓDULOS
  // ============================================
  Future<void> _carregarModulos() async {
    try {
      final response = await Supabase.instance.client
          .from('modules')
          .select()
          .eq('is_active', true)
          .order('ordem', ascending: true);

      _modulos = (response as List)
          .map((item) => ModuleModel.fromJson(item))
          .toList();
    } catch (e) {
      _modulos = ModuleConstants.defaultModules;
    }
  }

  // ============================================
  // 9. ATUALIZAR PERMISSÃO
  // ============================================
  Future<bool> atualizarPermissao(PermissionModel permissao) async {
    try {
      await _permissionRepository.salvarPermissao(permissao);

      // Atualizar lista local
      final index = _permissoes.indexWhere((p) => p.id == permissao.id);
      if (index != -1) {
        _permissoes[index] = permissao;
      } else {
        _permissoes.add(permissao);
      }

      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ============================================
  // 10. BUSCAR USUÁRIOS POR NÍVEL
  // ============================================
  List<ProfileModel> getUsuariosPorNivel(NivelAcesso nivel) {
    return _usuarios.where((u) => u.nivelAcesso == nivel).toList();
  }

  // ============================================
  // 11. LIMPAR SELEÇÃO
  // ============================================
  void limparSelecao() {
    _usuarioSelecionado = null;
    _permissoes = [];
    notifyListeners();
  }

  // ============================================
  // 12. RESETAR ESTADO
  // ============================================
  void resetState() {
    _usuarios = [];
    _usuarioSelecionado = null;
    _permissoes = [];
    _modulos = [];
    _isLoading = false;
    _error = null;
    notifyListeners();
  }
}