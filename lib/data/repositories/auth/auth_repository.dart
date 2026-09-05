/// ============================================
/// REPOSITÓRIO DE AUTENTICAÇÃO COM LOGS
/// ============================================

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/middleware/security_middleware.dart';
import '../../../core/services/security/rate_limit_service.dart';
import '../../models/auth/user_model.dart';
import '../../models/auth/profile_model.dart';

class AuthRepository {
  final SupabaseClient _supabase = Supabase.instance.client;
  final SecurityMiddleware _security = SecurityMiddleware();
  final RateLimitService _rateLimit = RateLimitService();

  Future<UserModel> login({
    required String email,
    required String password,
    String? ipAddress,
  }) async {
    // 🔍 LOG 1: Tentativa de login
    print('🔍 [LOGIN] Iniciando tentativa para email: $email');

    try {
      // 1. Sanitizar email
      final safeEmail = _security.validateAndSanitizeEmail(email);
      print('🔍 [LOGIN] Email sanitizado: $safeEmail');

      // 2. Verificar rate limiting
      final identifier = ipAddress ?? safeEmail;
      print('🔍 [LOGIN] Identifier: $identifier');

      if (!_rateLimit.canAttemptLogin(identifier)) {
        print('❌ [LOGIN] Bloqueado por rate limiting');
        throw Exception('Muitas tentativas falhas. Tente novamente em 15 minutos.');
      }

      // 3. Tentar login
      print('🔍 [LOGIN] Chamando Supabase Auth...');
      
      final response = await _supabase.auth.signInWithPassword(
        email: safeEmail,
        password: password,
      );

      print('🔍 [LOGIN] Resposta recebida!');
      print('🔍 [LOGIN] User: ${response.user}');
      print('🔍 [LOGIN] Session: ${response.session}');

      if (response.user == null) {
        print('❌ [LOGIN] Usuário não encontrado');
        throw Exception('Usuário não encontrado');
      }

      print('✅ [LOGIN] Autenticação bem-sucedida!');
      print('🔍 [LOGIN] User ID: ${response.user!.id}');

      // 4. Registrar sucesso
      _rateLimit.registerLoginAttempt(identifier, true);

      // 5. Garantir que o perfil existe
      final profile = await _ensureProfileExists(response.user!);
      print('🔍 [LOGIN] Perfil: $profile');

      // 6. Atualizar last_login
      await _updateLastLogin(response.user!.id);

      final user = UserModel(
        id: response.user!.id,
        email: response.user!.email ?? '',
        name: profile?.nome ?? response.user!.email?.split('@').first ?? 'Usuário',
        avatarUrl: profile?.avatarUrl,
        isActive: profile?.isActive ?? true,
        createdAt: response.user!.createdAt != null 
            ? DateTime.parse(response.user!.createdAt!) 
            : null,
        updatedAt: response.user!.updatedAt != null 
            ? DateTime.parse(response.user!.updatedAt!) 
            : null,
        metadata: response.user!.userMetadata,
      );

      print('✅ [LOGIN] Login concluído com sucesso!');
      return user;

    } catch (e) {
      // Registrar falha
      print('❌ [LOGIN] ERRO: $e');
      print('❌ [LOGIN] Tipo de erro: ${e.runtimeType}');
      
      final identifier = ipAddress ?? email;
      _rateLimit.registerLoginAttempt(identifier, false);

      // Verificar se foi bloqueado
      final result = _rateLimit.registerLoginAttempt(identifier, false);
      if (result['blocked'] == true) {
        print('❌ [LOGIN] Usuário bloqueado!');
        throw Exception('Muitas tentativas falhas. Tente novamente em 15 minutos.');
      }

      throw Exception('Email ou senha incorretos');
    }
  }

  // ============================================================
  // MÉTODO: Verificar e criar perfil se não existir
  // ============================================================
  Future<ProfileModel?> _ensureProfileExists(User user) async {
    try {
      print('🔍 [PROFILE] Verificando perfil para usuário: ${user.id}');
      
      // Verificar se o perfil existe
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('user_id', user.id);
      
      if (response.isEmpty) {
        print('🔍 [PROFILE] Criando perfil para usuário: ${user.email}');
        
        // Criar perfil
        final profileData = {
          'user_id': user.id,
          'email': user.email,
          'nome': user.userMetadata?['nome'] ?? 
                  user.email?.split('@').first ?? 'Usuário',
          'is_active': true,
          'created_at': DateTime.now().toIso8601String(),
        };
        
        await _supabase
            .from('profiles')
            .insert(profileData);
        
        // Buscar o perfil criado
        final newProfile = await _supabase
            .from('profiles')
            .select()
            .eq('user_id', user.id)
            .single();
        
        print('✅ [PROFILE] Perfil criado com sucesso!');
        return ProfileModel.fromJson(newProfile);
      }
      
      print('✅ [PROFILE] Perfil já existe para o usuário');
      return ProfileModel.fromJson(response[0]);
    } catch (e) {
      print('❌ [PROFILE] Erro ao garantir perfil: $e');
      return null;
    }
  }

  Future<ProfileModel?> _getProfile(String userId) async {
    try {
      print('🔍 [LOGIN] Buscando perfil para user_id: $userId');
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('user_id', userId)
          .maybeSingle();
      print('🔍 [LOGIN] Perfil encontrado: $response');
      return response != null ? ProfileModel.fromJson(response) : null;
    } catch (e) {
      print('❌ [LOGIN] Erro ao buscar perfil: $e');
      return null;
    }
  }

  Future<void> _updateLastLogin(String userId) async {
    try {
      print('🔍 [LOGIN] Atualizando last_login para: $userId');
      await _supabase
          .from('profiles')
          .update({
            'last_login': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId);
      print('✅ [LOGIN] last_login atualizado');
    } catch (e) {
      print('❌ [LOGIN] Erro ao atualizar last_login: $e');
    }
  }

  Future<void> logout() async {
    try {
      print('🔍 [LOGOUT] Saindo...');
      await _supabase.auth.signOut();
      print('✅ [LOGOUT] Logout concluído');
    } catch (e) {
      print('❌ [LOGOUT] Erro: $e');
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