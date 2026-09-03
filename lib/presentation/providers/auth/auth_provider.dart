/// ============================================
/// PROVIDER DE AUTENTICAÇÃO
/// ============================================
/// Gerencia o estado de autenticação do usuário
/// ============================================

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/repositories/auth/auth_repository.dart';
import '../../../data/models/auth/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository = AuthRepository();

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;
  bool _isBlocked = false;
  int _remainingAttempts = 5;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isBlocked => _isBlocked;
  int get remainingAttempts => _remainingAttempts;
  bool get isAuthenticated => _repository.isAuthenticated();
  String get currentName => _currentUser?.displayName ?? _repository.getCurrentName();
  String get currentEmail => _currentUser?.email ?? _repository.getCurrentEmail();

  Future<bool> login({
    required String email,
    required String password,
    String? ipAddress,
  }) async {
    print('🔍 [PROVIDER] Login iniciado para: $email');
    _isLoading = true;
    _error = null;
    _isBlocked = false;
    _remainingAttempts = 5;
    notifyListeners();

    try {
      print('🔍 [PROVIDER] Chamando repository.login...');
      _currentUser = await _repository.login(
        email: email,
        password: password,
        ipAddress: ipAddress,
      );
      print('✅ [PROVIDER] Login bem-sucedido! User: ${_currentUser?.email}');
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();

      if (_error?.contains('15 minutos') == true) {
        _isBlocked = true;
        _remainingAttempts = 0;
      } else if (_error?.contains('incorretos') == true) {
        _remainingAttempts = _remainingAttempts - 1;
        if (_remainingAttempts < 0) _remainingAttempts = 0;
      }

      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _repository.logout();
      _currentUser = null;
      _error = null;
      _isBlocked = false;
      _remainingAttempts = 5;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> initialize() async {
    final user = _repository.getCurrentUser();
    if (user != null) {
      try {
        final supabase = Supabase.instance.client;
        final response = await supabase
            .from('profiles')
            .select()
            .eq('user_id', user.id)
            .maybeSingle();

        _currentUser = UserModel(
          id: user.id,
          email: user.email ?? '',
          name: response?['nome']?.toString() ?? user.email?.split('@').first,
          avatarUrl: response?['avatar_url']?.toString(),
          isActive: response?['is_active'] ?? true,
          createdAt: user.createdAt != null ? DateTime.parse(user.createdAt!) : null,
          updatedAt: user.updatedAt != null ? DateTime.parse(user.updatedAt!) : null,
          metadata: user.userMetadata,
        );
        notifyListeners();
      } catch (e) {
        print('Erro ao carregar perfil: $e');
      }
    }
  }

  void resetState() {
    _currentUser = null;
    _isLoading = false;
    _error = null;
    _isBlocked = false;
    _remainingAttempts = 5;
    _repository.resetRateLimit(_repository.getCurrentEmail());
    notifyListeners();
  }
}