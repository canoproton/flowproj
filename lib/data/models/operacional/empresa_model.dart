/// ============================================
/// MODELO DE EMPRESA
/// ============================================
/// Tabela: tb_oemp
/// Representa uma empresa que pode ser
/// proponente, executor, fornecedor, etc.
/// ============================================

import 'package:equatable/equatable.dart';

class EmpresaModel extends Equatable {
  final String id;
  final String nome;
  final String qualif; // INTERNA, COLIGADA, OPERACIONAL, PESSOA_FÍSICA, FORNECEDOR
  final String razaoSocial;
  final String tipoContr; // RPA, CNPJ, MEI, ADH
  final String? cnpj;
  final String? ie;
  final List<String> contatoIds;
  final String? obs;
  
  // Auditoria
  final String? atuaPorId;
  final DateTime? atuaEm;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const EmpresaModel({
    required this.id,
    required this.nome,
    required this.qualif,
    required this.razaoSocial,
    required this.tipoContr,
    this.cnpj,
    this.ie,
    this.contatoIds = const [],
    this.obs,
    this.atuaPorId,
    this.atuaEm,
    this.createdAt,
    this.updatedAt,
  });

  factory EmpresaModel.fromJson(Map<String, dynamic> json) {
    return EmpresaModel(
      id: json['id']?.toString() ?? '',
      nome: json['nome']?.toString() ?? '',
      qualif: json['qualif']?.toString() ?? 'INTERNA',
      razaoSocial: json['razao_social']?.toString() ?? '',
      tipoContr: json['tipo_contr']?.toString() ?? 'CNPJ',
      cnpj: json['cnpj']?.toString(),
      ie: json['ie']?.toString(),
      contatoIds: (json['contato_ids'] as List?)?.map((e) => e.toString()).toList() ?? [],
      obs: json['obs']?.toString(),
      atuaPorId: json['atua_por_id']?.toString(),
      atuaEm: json['atua_em'] != null ? DateTime.parse(json['atua_em']) : null,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'qualif': qualif,
      'razao_social': razaoSocial,
      'tipo_contr': tipoContr,
      'cnpj': cnpj,
      'ie': ie,
      'contato_ids': contatoIds,
      'obs': obs,
      'atua_por_id': atuaPorId,
      'atua_em': atuaEm?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Verifica se o CNPJ é válido
  bool get isCnpjValid {
    if (cnpj == null || cnpj!.length != 14) return false;
    // Implementar validação de CNPJ
    return true;
  }

  /// CNPJ formatado
  String get cnpjFormatado {
    if (cnpj == null || cnpj!.length != 14) return cnpj ?? '';
    return '${cnpj!.substring(0, 2)}.${cnpj!.substring(2, 5)}.${cnpj!.substring(5, 8)}/${cnpj!.substring(8, 12)}-${cnpj!.substring(12)}';
  }

  @override
  List<Object?> get props => [id, nome, qualif, cnpj];
}

/// Qualificações da Empresa
class QualificacaoEmpresa {
  static const String interna = 'INTERNA';
  static const String coligada = 'COLIGADA';
  static const String operacional = 'OPERACIONAL';
  static const String pessoaFisica = 'PESSOA_FÍSICA';
  static const String fornecedor = 'FORNECEDOR';

  static List<String> get valores => [
    interna, coligada, operacional, pessoaFisica, fornecedor
  ];

  static String getLabel(String value) {
    switch (value) {
      case interna: return 'Interna';
      case coligada: return 'Coligada';
      case operacional: return 'Operacional';
      case pessoaFisica: return 'Pessoa Física';
      case fornecedor: return 'Fornecedor';
      default: return value;
    }
  }
}

/// Tipos de Contratação
class TipoContratacao {
  static const String rpa = 'RPA';
  static const String cnpj = 'CNPJ';
  static const String mei = 'MEI';
  static const String adh = 'ADH';

  static List<String> get valores => [rpa, cnpj, mei, adh];

  static String getLabel(String value) {
    switch (value) {
      case rpa: return 'RPA';
      case cnpj: return 'CNPJ';
      case mei: return 'MEI';
      case adh: return 'Ad-Hoc';
      default: return value;
    }
  }
}