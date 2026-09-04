/// ============================================
/// MODELO DE CONTATO
/// ============================================
/// Tabela: tb_ocont
/// Representa uma pessoa de contato que pode
/// ser vinculada a uma empresa ou usuário
/// ============================================

import 'package:equatable/equatable.dart';

class ContatoModel extends Equatable {
  final String id;
  final String nome;
  final String tpVinc; // BANCO, INTERNO, EXTERNO, EMPRESA, PATROCINADOR, OPERACIONAL, VARIOS
  final String? funcaoId;
  final String? cpf;
  final String? rg;
  final String? genero; // FEMININO, MASCULINO, OUTROS
  final String? obs;
  
  // ⭐ Integração com Usuário
  final String? profileId;
  final bool isUser;
  
  // Auditoria
  final String? atuaPorId;
  final DateTime? atuaEm;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ContatoModel({
    required this.id,
    required this.nome,
    required this.tpVinc,
    this.funcaoId,
    this.cpf,
    this.rg,
    this.genero,
    this.obs,
    this.profileId,
    this.isUser = false,
    this.atuaPorId,
    this.atuaEm,
    this.createdAt,
    this.updatedAt,
  });

  factory ContatoModel.fromJson(Map<String, dynamic> json) {
    return ContatoModel(
      id: json['id']?.toString() ?? '',
      nome: json['nome']?.toString() ?? '',
      tpVinc: json['tp_vinc']?.toString() ?? 'VARIOS',
      funcaoId: json['funcao_id']?.toString(),
      cpf: json['cpf']?.toString(),
      rg: json['rg']?.toString(),
      genero: json['genero']?.toString(),
      obs: json['obs']?.toString(),
      profileId: json['profile_id']?.toString(),
      isUser: json['is_user'] ?? false,
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
      'tp_vinc': tpVinc,
      'funcao_id': funcaoId,
      'cpf': cpf,
      'rg': rg,
      'genero': genero,
      'obs': obs,
      'profile_id': profileId,
      'is_user': isUser,
      'atua_por_id': atuaPorId,
      'atua_em': atuaEm?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Iniciais do nome
  String get initials {
    final names = nome.split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    }
    return nome.substring(0, 2).toUpperCase();
  }

  /// Primeiro nome
  String get firstName => nome.split(' ').first;

  /// Verifica se o CPF é válido
  bool get isCpfValid {
    if (cpf == null || cpf!.length != 11) return false;
    // Implementar validação de CPF
    return true;
  }

  /// CPF formatado
  String get cpfFormatado {
    if (cpf == null || cpf!.length != 11) return cpf ?? '';
    return '${cpf!.substring(0, 3)}.${cpf!.substring(3, 6)}.${cpf!.substring(6, 9)}-${cpf!.substring(9)}';
  }

  @override
  List<Object?> get props => [id, nome, tpVinc, cpf, isUser];
}

/// Tipos de Vínculo
class TipoVinculo {
  static const String banco = 'BANCO';
  static const String interno = 'INTERNO';
  static const String externo = 'EXTERNO';
  static const String empresa = 'EMPRESA';
  static const String patrocinador = 'PATROCINADOR';
  static const String operacional = 'OPERACIONAL';
  static const String varios = 'VARIOS';

  static List<String> get valores => [
    banco, interno, externo, empresa, patrocinador, operacional, varios
  ];

  static String getLabel(String value) {
    switch (value) {
      case banco: return 'Banco';
      case interno: return 'Interno';
      case externo: return 'Externo';
      case empresa: return 'Empresa';
      case patrocinador: return 'Patrocinador';
      case operacional: return 'Operacional';
      case varios: return 'Vários';
      default: return value;
    }
  }
}

/// Gêneros
class Genero {
  static const String feminino = 'FEMININO';
  static const String masculino = 'MASCULINO';
  static const String outros = 'OUTROS';

  static List<String> get valores => [feminino, masculino, outros];

  static String getLabel(String value) {
    switch (value) {
      case feminino: return 'Feminino';
      case masculino: return 'Masculino';
      case outros: return 'Outros';
      default: return value;
    }
  }
}