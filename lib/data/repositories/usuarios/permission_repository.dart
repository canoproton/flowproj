/// ============================================
/// REPOSITÓRIO DE PERMISSÕES
/// ============================================
/// Gerencia permissões granulares por usuário
/// e módulo
/// ============================================

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/usuarios/permission_model.dart';
import '../../models/usuarios/module_model.dart';
import '../../models/auth/profile_model.dart';

class PermissionRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ============================================
  // 1. BUSCAR PERMISSÕES DO USUÁRIO
  // ============================================
  Future<List<PermissionModel>> buscarPermissoesPorUsuario(String profileId) async {
    try {
      final response = await _supabase
          .from('permissions')
          .select('*, modules!module_id(*)')
          .eq('profile_id', profileId);

      return (response as List)
          .map((item) => PermissionModel.fromJson(item))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // ============================================
  // 2. BUSCAR PERMISSÃO ESPECÍFICA
  // ============================================
  Future<PermissionModel?> buscarPermissao({
    required String profileId,
    required String moduleId,
  }) async {
    try {
      final response = await _supabase
          .from('permissions')
          .select()
          .eq('profile_id', profileId)
          .eq('module_id', moduleId)
          .maybeSingle();

      if (response == null) return null;
      return PermissionModel.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  // ============================================
  // 3. CRIAR/ATUALIZAR PERMISSÃO
  // ============================================
  Future<PermissionModel> salvarPermissao(PermissionModel permissao) async {
    try {
      final data = permissao.toJson();
      data['updated_at'] = DateTime.now().toIso8601String();

      final response = await _supabase
          .from('permissions')
          .upsert(data)
          .select()
          .single();

      return PermissionModel.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao salvar permissão: $e');
    }
  }

  // ============================================
  // 4. ATUALIZAR VÁRIAS PERMISSÕES
  // ============================================
  Future<void> atualizarMultiplasPermissoes(
    String profileId,
    List<PermissionModel> permissoes,
  ) async {
    try {
      // Remover permissões antigas
      await _supabase
          .from('permissions')
          .delete()
          .eq('profile_id', profileId);

      // Inserir novas
      for (var permissao in permissoes) {
        await _supabase.from('permissions').insert(permissao.toJson());
      }
    } catch (e) {
      throw Exception('Erro ao atualizar permissões: $e');
    }
  }

  // ============================================
  // 5. VERIFICAR PERMISSÃO
  // ============================================
  Future<bool> verificarPermissao({
    required String profileId,
    required String moduleCode,
    required PermissaoAction action,
  }) async {
    try {
      // Buscar módulo pelo código
      final moduleResponse = await _supabase
          .from('modules')
          .select('id')
          .eq('codigo', moduleCode)
          .maybeSingle();

      if (moduleResponse == null) return false;

      final moduleId = moduleResponse['id'];

      // Buscar permissão
      final permissao = await buscarPermissao(
        profileId: profileId,
        moduleId: moduleId,
      );

      if (permissao == null) return false;
      return permissao.hasPermission(action);
    } catch (e) {
      return false;
    }
  }

  // ============================================
  // 6. LISTAR MÓDULOS ACESSÍVEIS
  // ============================================
  Future<List<ModuleModel>> listarModulosAcessiveis(ProfileModel usuario) async {
    try {
      // Se for Hyper ou Admin, tem acesso a tudo
      if (usuario.isHyper || usuario.isAdmin) {
        final response = await _supabase
            .from('modules')
            .select()
            .eq('is_active', true)
            .order('ordem', ascending: true);

        return (response as List)
            .map((item) => ModuleModel.fromJson(item))
            .toList();
      }

      // Buscar módulos com permissão de leitura
      final response = await _supabase
          .from('permissions')
          .select('modules!module_id(*)')
          .eq('profile_id', usuario.id)
          .eq('can_read', true);

      return (response as List)
          .map((item) => ModuleModel.fromJson(item['modules']))
          .toList();
    } catch (e) {
      return ModuleConstants.defaultModules
          .where((m) => m.isAcessivelPor(usuario.nivelAcesso))
          .toList();
    }
  }
}