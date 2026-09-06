import 'package:flutter/material.dart';
import '../../../data/models/auth/profile_model.dart';
import '../../../data/models/usuarios/permission_model.dart';
import '../../../data/models/usuarios/module_model.dart';
import '../../../data/repositories/usuarios/usuarios_repository.dart';

class UsuariosProvider extends ChangeNotifier {
  final UsuariosRepository _repository = UsuariosRepository();
  
  // Estado
  List<ProfileModel> _usuarios = [];
  List<PermissionModel> _permissoes = [];
  List<ModuleModel> _modulos = [];
  ProfileModel? _usuarioSelecionado;
  bool _isLoading = false;
  bool _isLoadingDetail = false;
  String? _error;
  String? _searchQuery;
  bool _mostrarInativos = false;
  NivelAcesso? _nivelFiltro;  // ✅ ADICIONADO

  // Getters
  List<ProfileModel> get usuarios => _usuarios;
  List<ProfileModel> get usuariosFiltrados {
    var list = _usuarios;
    if (!_mostrarInativos) {
      list = list.where((u) => u.isActive).toList();
    }
    if (_searchQuery != null && _searchQuery!.isNotEmpty) {
      final query = _searchQuery!.toLowerCase();
      list = list.where((u) => 
        u.nome.toLowerCase().contains(query) ||
        u.userId.toLowerCase().contains(query)
      ).toList();
    }
    return list;
  }
  List<PermissionModel> get permissoes => _permissoes;
  List<ModuleModel> get modulos => _modulos;
  ProfileModel? get usuarioSelecionado => _usuarioSelecionado;
  bool get isLoading => _isLoading;
  bool get isLoadingDetail => _isLoadingDetail;
  String? get error => _error;
  bool get mostrarInativos => _mostrarInativos;
  String? get searchQuery => _searchQuery;
  NivelAcesso? get nivelFiltro => _nivelFiltro;

  // ============================================
  // MÉTODOS DE CARREGAMENTO
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
      // Atualizar filtros se fornecidos
      if (search != null) _searchQuery = search;
      if (ativo != null) _mostrarInativos = !ativo;
      if (nivel != null) _nivelFiltro = nivel;

      _usuarios = await _repository.listarUsuarios(
        search: _searchQuery,
        ativo: _mostrarInativos ? null : true,
        nivel: _nivelFiltro,
      );
      _error = null;
    } catch (e) {
      _error = e.toString();
      _usuarios = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> selecionarUsuario(String id) async {
    _isLoadingDetail = true;
    _error = null;
    _usuarioSelecionado = null;
    _permissoes = [];
    notifyListeners();

    try {
      // Buscar usuário
      _usuarioSelecionado = await _repository.buscarUsuarioPorId(id);
      
      if (_usuarioSelecionado != null) {
        // Buscar permissões
        _permissoes = await _repository.listarPermissoes(_usuarioSelecionado!.id);
        // Buscar módulos
        _modulos = await _repository.buscarModules();
      }
      
      _error = null;
    } catch (e) {
      _error = e.toString();
      _usuarioSelecionado = null;
      _permissoes = [];
    } finally {
      _isLoadingDetail = false;
      notifyListeners();
    }
  }

  // ============================================
  // MÉTODOS DE CRUD
  // ============================================

  Future<void> criarUsuario({
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
      await _repository.criarUsuario(
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
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> atualizarUsuario({
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
      await _repository.atualizarUsuario(
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
        await selecionarUsuario(id);
      }
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> desativarUsuario(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.desativarUsuario(id);
      await carregarUsuarios();
      if (_usuarioSelecionado?.id == id) {
        await selecionarUsuario(id);
      }
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> ativarUsuario(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.ativarUsuario(id);
      await carregarUsuarios();
      if (_usuarioSelecionado?.id == id) {
        await selecionarUsuario(id);
      }
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============================================
  // MÉTODOS DE PERMISSÕES
  // ============================================

  Future<void> atualizarPermissao(PermissionModel permissao) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.atualizarPermissao(permissao);
      // Recarregar permissões
      if (_usuarioSelecionado != null) {
        _permissoes = await _repository.listarPermissoes(_usuarioSelecionado!.id);
      }
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============================================
  // MÉTODOS DE FILTRO E BUSCA
  // ============================================

  void setSearchQuery(String? query) {
    _searchQuery = query;
    notifyListeners();
    carregarUsuarios();
  }

  void setNivelFiltro(NivelAcesso? nivel) {
    _nivelFiltro = nivel;
    notifyListeners();
    carregarUsuarios();
  }

  void toggleMostrarInativos() {
    _mostrarInativos = !_mostrarInativos;
    notifyListeners();
    carregarUsuarios();
  }

  void limparFiltros() {
    _searchQuery = null;
    _mostrarInativos = false;
    _nivelFiltro = null;
    notifyListeners();
    carregarUsuarios();
  }

  void limparErro() {
    _error = null;
    notifyListeners();
  }

  // ============================================
  // MÉTODO DE RECARREGAR
  // ============================================

  Future<void> recarregar() async {
    await carregarUsuarios();
  }
}