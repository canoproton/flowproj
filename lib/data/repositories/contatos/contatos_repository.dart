/// ============================================
/// REPOSITÓRIO DE CONTATOS
/// ============================================
/// Gerencia CRUD de contatos, telefones,
/// emails, endereços e mídias
/// ============================================

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/operacional/contato_model.dart';
import '../../models/operacional/telefone_model.dart';
import '../../models/operacional/email_model.dart';
import '../../models/operacional/endereco_model.dart';
import '../../models/operacional/midia_model.dart';
import '../../../core/middleware/security_middleware.dart';

class ContatosRepository {
  final SupabaseClient _supabase = Supabase.instance.client;
  final SecurityMiddleware _security = SecurityMiddleware();

  // ============================================
  // 1. LISTAR CONTATOS
  // ============================================
  Future<List<ContatoModel>> listarContatos({
    String? search,
    String? tpVinc,
    bool? isUser,
  }) async {
    try {
      var query = _supabase.from('tb_ocont').select('*');

      if (search != null && search.isNotEmpty) {
        final safeSearch = _security.sanitizeInput(search);
        query = query.or(
          'nome.ilike.%$safeSearch%,'
          'cpf.ilike.%$safeSearch%,'
          'rg.ilike.%$safeSearch%'
        );
      }

      if (tpVinc != null) {
        query = query.eq('tp_vinc', tpVinc);
      }

      if (isUser != null) {
        query = query.eq('is_user', isUser);
      }

      final response = await query.order('nome', ascending: true);

      return (response as List)
          .map((item) => ContatoModel.fromJson(item))
          .toList();
    } catch (e) {
      throw Exception('Erro ao listar contatos: $e');
    }
  }

  // ============================================
  // 2. BUSCAR CONTATO POR ID
  // ============================================
  Future<ContatoModel?> buscarContatoPorId(String id) async {
    try {
      final response = await _supabase
          .from('tb_ocont')
          .select('*')
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;
      return ContatoModel.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao buscar contato: $e');
    }
  }

  // ============================================
  // 3. BUSCAR CONTATO COMPLETO (com telefones, emails, etc.)
  // ============================================
  Future<Map<String, dynamic>> buscarContatoCompleto(String id) async {
    try {
      final contato = await buscarContatoPorId(id);
      if (contato == null) throw Exception('Contato não encontrado');

      final telefones = await _buscarTelefones('contato', id);
      final emails = await _buscarEmails('contato', id);
      final enderecos = await _buscarEnderecos('contato', id);
      final midias = await _buscarMidias('contato', id);

      return {
        'contato': contato,
        'telefones': telefones,
        'emails': emails,
        'enderecos': enderecos,
        'midias': midias,
      };
    } catch (e) {
      throw Exception('Erro ao buscar contato completo: $e');
    }
  }

  // ============================================
  // 4. CRIAR CONTATO
  // ============================================
  Future<ContatoModel> criarContato({
    required String nome,
    required String tpVinc,
    String? funcaoId,
    String? cpf,
    String? rg,
    String? genero,
    String? obs,
    String? profileId,
  }) async {
    try {
      final safeNome = _security.sanitizeInput(nome);
      final safeCpf = cpf != null ? cpf.replaceAll(RegExp(r'\D'), '') : null;

      final data = {
        'nome': safeNome,
        'tp_vinc': tpVinc,
        'funcao_id': funcaoId,
        'cpf': safeCpf,
        'rg': rg,
        'genero': genero,
        'obs': obs,
        'profile_id': profileId,
        'is_user': profileId != null,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await _supabase
          .from('tb_ocont')
          .insert(data)
          .select()
          .single();

      return ContatoModel.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao criar contato: $e');
    }
  }

  // ============================================
  // 5. ATUALIZAR CONTATO
  // ============================================
  Future<ContatoModel> atualizarContato({
    required String id,
    String? nome,
    String? tpVinc,
    String? funcaoId,
    String? cpf,
    String? rg,
    String? genero,
    String? obs,
    String? profileId,
    bool? isUser,
  }) async {
    try {
      final updateData = <String, dynamic>{};

      if (nome != null) updateData['nome'] = _security.sanitizeInput(nome);
      if (tpVinc != null) updateData['tp_vinc'] = tpVinc;
      if (funcaoId != null) updateData['funcao_id'] = funcaoId;
      if (cpf != null) {
        updateData['cpf'] = cpf.replaceAll(RegExp(r'\D'), '');
      }
      if (rg != null) updateData['rg'] = rg;
      if (genero != null) updateData['genero'] = genero;
      if (obs != null) updateData['obs'] = obs;
      if (profileId != null) updateData['profile_id'] = profileId;
      if (isUser != null) updateData['is_user'] = isUser;

      updateData['updated_at'] = DateTime.now().toIso8601String();

      final response = await _supabase
          .from('tb_ocont')
          .update(updateData)
          .eq('id', id)
          .select()
          .single();

      return ContatoModel.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao atualizar contato: $e');
    }
  }

  // ============================================
  // 6. DELETAR CONTATO (soft delete)
  // ============================================
  Future<void> deletarContato(String id) async {
    try {
      // Verificar se contato está vinculado a um usuário
      final contato = await buscarContatoPorId(id);
      if (contato != null && contato.isUser) {
        throw Exception('Não é possível excluir um contato que é usuário do sistema');
      }

      // Remover relações
      await _supabase.from('tb_oemp_contato').delete().eq('contato_id', id);

      // Remover telefones, emails, endereços, mídias
      await _supabase.from('tb_otelef').delete().eq('origem_id', id).eq('origem_type', 'contato');
      await _supabase.from('tb_oemail').delete().eq('origem_id', id).eq('origem_type', 'contato');
      await _supabase.from('tb_oender').delete().eq('origem_id', id).eq('origem_type', 'contato');
      await _supabase.from('tb_omidia').delete().eq('origem_id', id).eq('origem_type', 'contato');

      // Remover contato
      await _supabase.from('tb_ocont').delete().eq('id', id);
    } catch (e) {
      throw Exception('Erro ao deletar contato: $e');
    }
  }

  // ============================================
  // TELEFONES
  // ============================================
  Future<List<TelefoneModel>> _buscarTelefones(String origemType, String origemId) async {
    try {
      final response = await _supabase
          .from('tb_otelef')
          .select()
          .eq('origem_type', origemType)
          .eq('origem_id', origemId);

      return (response as List)
          .map((item) => TelefoneModel.fromJson(item))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<TelefoneModel> adicionarTelefone({
    required String origemId,
    required String origemType,
    required String uso,
    required String numero,
    String? obs,
  }) async {
    try {
      final response = await _supabase
          .from('tb_otelef')
          .insert({
            'origem_id': origemId,
            'origem_type': origemType,
            'uso': uso,
            'numero': numero.replaceAll(RegExp(r'\D'), ''),
            'obs': obs,
          })
          .select()
          .single();

      return TelefoneModel.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao adicionar telefone: $e');
    }
  }

  Future<void> removerTelefone(String id) async {
    try {
      await _supabase.from('tb_otelef').delete().eq('id', id);
    } catch (e) {
      throw Exception('Erro ao remover telefone: $e');
    }
  }

  // ============================================
  // EMAILS
  // ============================================
  Future<List<EmailModel>> _buscarEmails(String origemType, String origemId) async {
    try {
      final response = await _supabase
          .from('tb_oemail')
          .select()
          .eq('origem_type', origemType)
          .eq('origem_id', origemId);

      return (response as List)
          .map((item) => EmailModel.fromJson(item))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<EmailModel> adicionarEmail({
    required String origemId,
    required String origemType,
    required String uso,
    required String endereco,
    String? obs,
  }) async {
    try {
      final response = await _supabase
          .from('tb_oemail')
          .insert({
            'origem_id': origemId,
            'origem_type': origemType,
            'uso': uso,
            'endereco': _security.validateAndSanitizeEmail(endereco),
            'obs': obs,
          })
          .select()
          .single();

      return EmailModel.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao adicionar email: $e');
    }
  }

  Future<void> removerEmail(String id) async {
    try {
      await _supabase.from('tb_oemail').delete().eq('id', id);
    } catch (e) {
      throw Exception('Erro ao remover email: $e');
    }
  }

  // ============================================
  // ENDEREÇOS
  // ============================================
  Future<List<EnderecoModel>> _buscarEnderecos(String origemType, String origemId) async {
    try {
      final response = await _supabase
          .from('tb_oender')
          .select()
          .eq('origem_type', origemType)
          .eq('origem_id', origemId);

      return (response as List)
          .map((item) => EnderecoModel.fromJson(item))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<EnderecoModel> adicionarEndereco({
    required String origemId,
    required String origemType,
    required String logradouro,
    String? bairro,
    String? cidade,
    String? estado,
    String? cep,
    String? obs,
  }) async {
    try {
      final response = await _supabase
          .from('tb_oender')
          .insert({
            'origem_id': origemId,
            'origem_type': origemType,
            'logradouro': logradouro,
            'bairro': bairro,
            'cidade': cidade,
            'estado': estado,
            'cep': cep?.replaceAll(RegExp(r'\D'), ''),
            'obs': obs,
          })
          .select()
          .single();

      return EnderecoModel.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao adicionar endereço: $e');
    }
  }

  Future<void> removerEndereco(String id) async {
    try {
      await _supabase.from('tb_oender').delete().eq('id', id);
    } catch (e) {
      throw Exception('Erro ao remover endereço: $e');
    }
  }

  // ============================================
  // MÍDIAS SOCIAIS
  // ============================================
  Future<List<MidiaModel>> _buscarMidias(String origemType, String origemId) async {
    try {
      final response = await _supabase
          .from('tb_omidia')
          .select()
          .eq('origem_type', origemType)
          .eq('origem_id', origemId);

      return (response as List)
          .map((item) => MidiaModel.fromJson(item))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<MidiaModel> adicionarMidia({
    required String origemId,
    required String origemType,
    required String uso,
    required String tipo,
    required String descricao,
    String? obs,
  }) async {
    try {
      final response = await _supabase
          .from('tb_omidia')
          .insert({
            'origem_id': origemId,
            'origem_type': origemType,
            'uso': uso,
            'tipo': tipo,
            'descricao': descricao,
            'obs': obs,
          })
          .select()
          .single();

      return MidiaModel.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao adicionar mídia: $e');
    }
  }

  Future<void> removerMidia(String id) async {
    try {
      await _supabase.from('tb_omidia').delete().eq('id', id);
    } catch (e) {
      throw Exception('Erro ao remover mídia: $e');
    }
  }

  // ============================================
  // 7. CONTAGEM DE CONTATOS
  // ============================================
  Future<int> contarContatos({bool? isUser}) async {
    try {
      var query = _supabase.from('tb_ocont').select('id', count: 'exact');

      if (isUser != null) {
        query = query.eq('is_user', isUser);
      }

      final response = await query;
      return response.count ?? 0;
    } catch (e) {
      return 0;
    }
  }
}