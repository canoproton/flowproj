/// ============================================
/// REPOSITÓRIO DE EMPRESAS
/// ============================================
/// Gerencia CRUD de empresas e relacionamento
/// com contatos
/// ============================================

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/operacional/empresa_model.dart';
import '../../models/operacional/contato_model.dart';
import '../../../core/middleware/security_middleware.dart';

class EmpresasRepository {
  final SupabaseClient _supabase = Supabase.instance.client;
  final SecurityMiddleware _security = SecurityMiddleware();

  // ============================================
  // 1. LISTAR EMPRESAS
  // ============================================
  Future<List<EmpresaModel>> listarEmpresas({
    String? search,
    String? qualif,
  }) async {
    try {
      var query = _supabase.from('tb_oemp').select('*');

      if (search != null && search.isNotEmpty) {
        final safeSearch = _security.sanitizeInput(search);
        query = query.or(
          'nome.ilike.%$safeSearch%,'
          'razao_social.ilike.%$safeSearch%,'
          'cnpj.ilike.%$safeSearch%'
        );
      }

      if (qualif != null) {
        query = query.eq('qualif', qualif);
      }

      final response = await query.order('nome', ascending: true);

      return (response as List)
          .map((item) => EmpresaModel.fromJson(item))
          .toList();
    } catch (e) {
      throw Exception('Erro ao listar empresas: $e');
    }
  }

  // ============================================
  // 2. BUSCAR EMPRESA POR ID
  // ============================================
  Future<EmpresaModel?> buscarEmpresaPorId(String id) async {
    try {
      final response = await _supabase
          .from('tb_oemp')
          .select('*')
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;
      return EmpresaModel.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao buscar empresa: $e');
    }
  }

  // ============================================
  // 3. BUSCAR EMPRESA COM CONTATOS
  // ============================================
  Future<Map<String, dynamic>> buscarEmpresaComContatos(String id) async {
    try {
      final empresa = await buscarEmpresaPorId(id);
      if (empresa == null) throw Exception('Empresa não encontrada');

      // Buscar contatos vinculados
      final response = await _supabase
          .from('tb_oemp_contato')
          .select('contato_id, tb_ocont(*)')
          .eq('empresa_id', id);

      final contatos = (response as List)
          .map((item) => ContatoModel.fromJson(item['tb_ocont']))
          .toList();

      return {
        'empresa': empresa,
        'contatos': contatos,
      };
    } catch (e) {
      throw Exception('Erro ao buscar empresa com contatos: $e');
    }
  }

  // ============================================
  // 4. CRIAR EMPRESA
  // ============================================
  Future<EmpresaModel> criarEmpresa({
    required String nome,
    required String qualif,
    required String razaoSocial,
    required String tipoContr,
    String? cnpj,
    String? ie,
    String? obs,
  }) async {
    try {
      final safeNome = _security.sanitizeInput(nome);
      final safeRazao = _security.sanitizeInput(razaoSocial);
      final safeCnpj = cnpj != null ? cnpj.replaceAll(RegExp(r'\D'), '') : null;

      final data = {
        'nome': safeNome,
        'qualif': qualif,
        'razao_social': safeRazao,
        'tipo_contr': tipoContr,
        'cnpj': safeCnpj,
        'ie': ie,
        'obs': obs,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await _supabase
          .from('tb_oemp')
          .insert(data)
          .select()
          .single();

      return EmpresaModel.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao criar empresa: $e');
    }
  }

  // ============================================
  // 5. ATUALIZAR EMPRESA
  // ============================================
  Future<EmpresaModel> atualizarEmpresa({
    required String id,
    String? nome,
    String? qualif,
    String? razaoSocial,
    String? tipoContr,
    String? cnpj,
    String? ie,
    String? obs,
  }) async {
    try {
      final updateData = <String, dynamic>{};

      if (nome != null) updateData['nome'] = _security.sanitizeInput(nome);
      if (qualif != null) updateData['qualif'] = qualif;
      if (razaoSocial != null) {
        updateData['razao_social'] = _security.sanitizeInput(razaoSocial);
      }
      if (tipoContr != null) updateData['tipo_contr'] = tipoContr;
      if (cnpj != null) {
        updateData['cnpj'] = cnpj.replaceAll(RegExp(r'\D'), '');
      }
      if (ie != null) updateData['ie'] = ie;
      if (obs != null) updateData['obs'] = obs;

      updateData['updated_at'] = DateTime.now().toIso8601String();

      final response = await _supabase
          .from('tb_oemp')
          .update(updateData)
          .eq('id', id)
          .select()
          .single();

      return EmpresaModel.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao atualizar empresa: $e');
    }
  }

  // ============================================
  // 6. DELETAR EMPRESA
  // ============================================
  Future<void> deletarEmpresa(String id) async {
    try {
      // Remover relações com contatos
      await _supabase.from('tb_oemp_contato').delete().eq('empresa_id', id);

      // Remover empresa
      await _supabase.from('tb_oemp').delete().eq('id', id);
    } catch (e) {
      throw Exception('Erro ao deletar empresa: $e');
    }
  }

  // ============================================
  // 7. ADICIONAR CONTATO À EMPRESA
  // ============================================
  Future<void> adicionarContatoEmpresa({
    required String empresaId,
    required String contatoId,
  }) async {
    try {
      await _supabase
          .from('tb_oemp_contato')
          .insert({
            'empresa_id': empresaId,
            'contato_id': contatoId,
          });
    } catch (e) {
      throw Exception('Erro ao adicionar contato à empresa: $e');
    }
  }

  // ============================================
  // 8. REMOVER CONTATO DA EMPRESA
  // ============================================
  Future<void> removerContatoEmpresa({
    required String empresaId,
    required String contatoId,
  }) async {
    try {
      await _supabase
          .from('tb_oemp_contato')
          .delete()
          .eq('empresa_id', empresaId)
          .eq('contato_id', contatoId);
    } catch (e) {
      throw Exception('Erro ao remover contato da empresa: $e');
    }
  }

  // ============================================
  // 9. CONTAGEM DE EMPRESAS
  // ============================================
  Future<int> contarEmpresas() async {
    try {
      final response = await _supabase
          .from('tb_oemp')
          .select('id', count: 'exact');

      return response.count ?? 0;
    } catch (e) {
      return 0;
    }
  }
}