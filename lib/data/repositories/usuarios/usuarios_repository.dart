/// ============================================
/// REPOSITÓRIO DE USUÁRIOS
/// ============================================
/// Gerencia CRUD de usuários, integração com
/// contatos e gerenciamento de permissões
/// ============================================

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/auth/profile_model.dart';
import '../../models/operacional/contato_model.dart';
import '../../models/usuarios/permission_model.dart';
import '../../models/usuarios/module_model.dart';
import '../../../core/middleware/security_middleware.dart';

class UsuariosRepository {
  final SupabaseClient _supabase = Supabase.instance.client;
  final SecurityMiddleware _security = SecurityMiddleware();

  // ============================================
  // 1. LISTAR USUÁRIOS
  // ============================================
  Future<List<ProfileModel>> listarUsuarios({
    String? search,
    bool? ativo,
    NivelAcesso? nivel,
  }) async {
    try {
      var query = _supabase
          .from('profiles')
          .select('*, auth_users!user_id(email)');

      if (search != null && search.isNotEmpty) {
        final safeSearch = _security.sanitizeInput(search);
        query = query.or(
          'nome.ilike.%$safeSearch%,'
          'auth_users.email.ilike.%$safeSearch%'
        );
      }

      if (ativo != null) {
        query = query.eq('is_active', ativo);
      }

      if (nivel != null) {
        query = query.eq('nivel_acesso', nivel.name.toUpperCase());
      }

      final response = await query.order('nome', ascending: true);

      return (response as List)
          .map((item) => ProfileModel.fromJson(item))
          .toList();
    } catch (e) {
      throw Exception('Erro ao listar usuários: $e');
    }
  }

  // ============================================
  // 2. BUSCAR USUÁRIO POR ID
  // ============================================
  Future<ProfileModel?> buscarUsuarioPorId(String id) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select('*, auth_users!user_id(email)')
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;
      return ProfileModel.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao buscar usuário: $e');
    }
  }

  // ============================================
  // 3. BUSCAR USUÁRIO POR USER_ID (auth.users)
  // ============================================
  Future<ProfileModel?> buscarUsuarioPorUserId(String userId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select('*, auth_users!user_id(email)')
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) return null;
      return ProfileModel.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao buscar usuário: $e');
    }
  }

  // ============================================
  // 4. CRIAR USUÁRIO (com ou sem contato)
  // ============================================
  Future<ProfileModel> criarUsuario({
    required String email,
    required String password,
    required String nome,
    required NivelAcesso nivelAcesso,
    String? cargo,
    String? departamento,
    String? telefone,
    String? avatarUrl,
    String? contatoId, // Opcional: vincular a contato existente
  }) async {
    try {
      // 1. Sanitizar entradas
      final safeEmail = _security.validateAndSanitizeEmail(email);
      final safeNome = _security.sanitizeInput(nome);

      // 2. Criar usuário no auth.users
      final authResponse = await _supabase.auth.admin.createUser(
        AdminUserAttributes(
          email: safeEmail,
          password: password,
          emailConfirm: true,
          userMetadata: {'name': safeNome},
        ),
      );

      if (authResponse.user == null) {
        throw Exception('Erro ao criar usuário no sistema de autenticação');
      }

      final userId = authResponse.user!.id;

      // 3. Criar perfil
      final profileData = {
        'user_id': userId,
        'nome': safeNome,
        'cargo': cargo,
        'departamento': departamento,
        'telefone': telefone,
        'avatar_url': avatarUrl,
        'nivel_acesso': nivelAcesso.name.toUpperCase(),
        'is_active': true,
        'contato_id': contatoId,
        'is_contato': contatoId != null,
      };

      final profileResponse = await _supabase
          .from('profiles')
          .insert(profileData)
          .select()
          .single();

      final profile = ProfileModel.fromJson(profileResponse);

      // 4. Se vinculou a um contato, atualizar o contato
      if (contatoId != null) {
        await _supabase
            .from('tb_ocont')
            .update({
              'profile_id': profile.id,
              'is_user': true,
            })
            .eq('id', contatoId);
      }

      // 5. Criar permissões padrão
      await _criarPermissoesPadrao(profile.id, nivelAcesso);

      return profile;
    } catch (e) {
      throw Exception('Erro ao criar usuário: $e');
    }
  }

  // ============================================
  // 5. ATUALIZAR USUÁRIO
  // ============================================
  Future<ProfileModel> atualizarUsuario({
    required String id,
    String? nome,
    String? cargo,
    String? departamento,
    String? telefone,
    String? avatarUrl,
    NivelAcesso? nivelAcesso,
    bool? isActive,
  }) async {
    try {
      final updateData = <String, dynamic>{};

      if (nome != null) updateData['nome'] = _security.sanitizeInput(nome);
      if (cargo != null) updateData['cargo'] = _security.sanitizeInput(cargo);
      if (departamento != null) {
        updateData['departamento'] = _security.sanitizeInput(departamento);
      }
      if (telefone != null) updateData['telefone'] = telefone;
      if (avatarUrl != null) updateData['avatar_url'] = avatarUrl;
      if (nivelAcesso != null) {
        updateData['nivel_acesso'] = nivelAcesso.name.toUpperCase();
      }
      if (isActive != null) updateData['is_active'] = isActive;

      updateData['updated_at'] = DateTime.now().toIso8601String();

      final response = await _supabase
          .from('profiles')
          .update(updateData)
          .eq('id', id)
          .select()
          .single();

      // Se o nível de acesso mudou, atualizar permissões
      if (nivelAcesso != null) {
        await _atualizarPermissoesPorNivel(id, nivelAcesso);
      }

      return ProfileModel.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao atualizar usuário: $e');
    }
  }

  // ============================================
  // 6. DESATIVAR USUÁRIO
  // ============================================
  Future<void> desativarUsuario(String id) async {
    try {
      await _supabase
          .from('profiles')
          .update({
            'is_active': false,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id);
    } catch (e) {
      throw Exception('Erro ao desativar usuário: $e');
    }
  }

  // ============================================
  // 7. ATIVAR USUÁRIO
  // ============================================
  Future<void> ativarUsuario(String id) async {
    try {
      await _supabase
          .from('profiles')
          .update({
            'is_active': true,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id);
    } catch (e) {
      throw Exception('Erro ao ativar usuário: $e');
    }
  }

  // ============================================
  // 8. VINCULAR USUÁRIO A CONTATO
  // ============================================
  Future<void> vincularContato(String profileId, String contatoId) async {
    try {
      // Atualizar perfil
      await _supabase
          .from('profiles')
          .update({
            'contato_id': contatoId,
            'is_contato': true,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', profileId);

      // Atualizar contato
      await _supabase
          .from('tb_ocont')
          .update({
            'profile_id': profileId,
            'is_user': true,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', contatoId);
    } catch (e) {
      throw Exception('Erro ao vincular contato: $e');
    }
  }

  // ============================================
  // 9. CRIAR PERMISSÕES PADRÃO
  // ============================================
  Future<void> _criarPermissoesPadrao(String profileId, NivelAcesso nivel) async {
    try {
      final modules = await _buscarModules();

      for (var module in modules) {
        final permissao = PermissionModel.fromNivel(
          profileId: profileId,
          moduleId: module.id,
          nivel: nivel,
        );

        await _supabase.from('permissions').insert(permissao.toJson());
      }
    } catch (e) {
      print('Erro ao criar permissões padrão: $e');
    }
  }

  // ============================================
  // 10. ATUALIZAR PERMISSÕES POR NÍVEL
  // ============================================
  Future<void> _atualizarPermissoesPorNivel(String profileId, NivelAcesso nivel) async {
    try {
      final modules = await _buscarModules();

      for (var module in modules) {
        final permissao = PermissionModel.fromNivel(
          profileId: profileId,
          moduleId: module.id,
          nivel: nivel,
          isCustom: true,
        );

        await _supabase
            .from('permissions')
            .upsert(permissao.toJson())
            .eq('profile_id', profileId)
            .eq('module_id', module.id);
      }
    } catch (e) {
      print('Erro ao atualizar permissões: $e');
    }
  }

  // ============================================
  // 11. BUSCAR MÓDULOS
  // ============================================
  Future<List<ModuleModel>> _buscarModules() async {
    try {
      final response = await _supabase
          .from('modules')
          .select()
          .eq('is_active', true)
          .order('ordem', ascending: true);

      return (response as List)
          .map((item) => ModuleModel.fromJson(item))
          .toList();
    } catch (e) {
      // Se não existir tabela, usar módulos padrão
      return ModuleConstants.defaultModules;
    }
  }

  // ============================================
  // 12. LISTAR PERMISSÕES DO USUÁRIO
  // ============================================
  Future<List<PermissionModel>> listarPermissoes(String profileId) async {
    try {
      final response = await _supabase
          .from('permissions')
          .select()
          .eq('profile_id', profileId);

      return (response as List)
          .map((item) => PermissionModel.fromJson(item))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // ============================================
  // 13. ATUALIZAR PERMISSÃO ESPECÍFICA
  // ============================================
  Future<void> atualizarPermissao(PermissionModel permissao) async {
    try {
      await _supabase
          .from('permissions')
          .upsert(permissao.toJson())
          .eq('profile_id', permissao.profileId)
          .eq('module_id', permissao.moduleId);
    } catch (e) {
      throw Exception('Erro ao atualizar permissão: $e');
    }
  }

  // ============================================
  // 14. CONTAGEM DE USUÁRIOS
  // ============================================
  Future<int> contarUsuarios({bool? ativo}) async {
    try {
      var query = _supabase.from('profiles').select('id');

      if (ativo != null) {
        query = query.eq('is_active', ativo);
      }

      final response = await query;
      return response.length;
    } catch (e) {
      return 0;
    }
  }
}