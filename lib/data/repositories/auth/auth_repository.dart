/// ============================================
/// REPOSITÓRIO DE AUTENTICAÇÃO
/// ============================================
/// Gerencia login, logout e sessão do usuário
/// ============================================

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/middleware/security_middleware.dart';
import '../../../core/services/security/rate_limit_service.dart';
import '../../models/auth/user_model.dart';

class AuthRepository {
  final SupabaseClient _supabase = Supabase.instance.client;
  final SecurityMiddleware _security = SecurityMiddleware();
  final RateLimitService _rateLimit = RateLimitService();

  Future<UserModel> login({
    required String email,
    required String password,
    String? ipAddress,
  }) async {
    final safeEmail = _security.validateAndSanitizeEmail(email);

    final identifier = ipAddress ?? safeEmail;
    if (!_rateLimit.canAttemptLogin(identifier)) {
      throw Exception('Muitas tentativas falhas. Tente novamente em 15 minutos.');
    }

    try {
      final response = await _supabase.auth.signInWithPassword(
        email: safeEmail,
        password: password,
      );

      if (response.user == null) {
        throw Exception('Usuário não encontrado');
      }

      _rateLimit.registerLoginAttempt(identifier, true);

      final profile = await _getProfile(response.user!.id);

      return UserModel(
        id: response.user!.id,
        email: response.user!.email ?? '',
        name: profile['nome']?.toString() ?? response.user!.email?.split('@').first,
        avatarUrl: profile['avatar_url']?.toString(),
        isActive: profile['is_active'] ?? true,
        createdAt: response.user!.createdAt != null ? DateTime.parse(response.user!.createdAt!) : null,
        updatedAt: response.user!.updatedAt != null ? DateTime.parse(response.user!.updatedAt!) : null,
        metadata: response.user!.userMetadata,
      );
    } catch (e) {
      _rateLimit.registerLoginAttempt(identifier, false);
      throw Exception('Email ou senha incorretos');
    }
  }

  Future<Map<String, dynamic>> _getProfile(String userId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('user_id', userId)
          .maybeSingle();
      return response as Map<String, dynamic>? ?? {};
    } catch (e) {
      return {};
    }
  }

  Future<void> logout() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      throw Exception('Erro ao fazer logout: $e');
    }
  }

  User? getCurrentUser() {
    return _supabase.auth.currentUser;
  }

  bool isAuthenticated() {
    return _supabase.auth.currentUser != null;
  }

  String getCurrentEmail() {
    return _supabase.auth.currentUser?.email ?? '';
  }

  String getCurrentName() {
    final user = _supabase.auth.currentUser;
    if (user == null) return 'Usuário';
    return user.userMetadata?['name']?.toString() ??
        user.email?.split('@').first ??
        'Usuário';
  }

  void resetRateLimit(String identifier) {
    _rateLimit.resetCounters(identifier);
  }
}