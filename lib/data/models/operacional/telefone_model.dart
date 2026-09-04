/// ============================================
/// MODELO DE TELEFONE
/// ============================================
/// Tabela: tb_otelef
/// Telefone vinculado a um Contato ou Empresa
/// (Polimórfico - origem_id + origem_type)
/// ============================================

import 'package:equatable/equatable.dart';

class TelefoneModel extends Equatable {
  final String id;
  final String origemId;    // ID da entidade (contato ou empresa)
  final String origemType;  // 'contato' ou 'empresa'
  final String uso;         // CORPORATIVO, PARTICULAR, COMUNITÁRIO
  final String numero;
  final String? obs;
  
  // Auditoria
  final String? atuaPorId;
  final DateTime? atuaEm;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const TelefoneModel({
    required this.id,
    required this.origemId,
    required this.origemType,
    required this.uso,
    required this.numero,
    this.obs,
    this.atuaPorId,
    this.atuaEm,
    this.createdAt,
    this.updatedAt,
  });

  factory TelefoneModel.fromJson(Map<String, dynamic> json) {
    return TelefoneModel(
      id: json['id']?.toString() ?? '',
      origemId: json['origem_id']?.toString() ?? '',
      origemType: json['origem_type']?.toString() ?? '',
      uso: json['uso']?.toString() ?? 'PARTICULAR',
      numero: json['numero']?.toString() ?? '',
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
      'origem_id': origemId,
      'origem_type': origemType,
      'uso': uso,
      'numero': numero,
      'obs': obs,
      'atua_por_id': atuaPorId,
      'atua_em': atuaEm?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Número formatado para exibição
  String get numeroFormatado {
    final digits = numero.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 11) {
      return '(${digits.substring(0, 2)}) ${digits.substring(2, 7)}-${digits.substring(7)}';
    } else if (digits.length == 10) {
      return '(${digits.substring(0, 2)}) ${digits.substring(2, 6)}-${digits.substring(6)}';
    }
    return numero;
  }

  @override
  List<Object?> get props => [id, numero, uso, origemId];
}

/// Tipos de Uso do Telefone
class UsoTelefone {
  static const String corporativo = 'CORPORATIVO';
  static const String particular = 'PARTICULAR';
  static const String comunitario = 'COMUNITÁRIO';

  static List<String> get valores => [corporativo, particular, comunitario];

  static String getLabel(String value) {
    switch (value) {
      case corporativo: return 'Corporativo';
      case particular: return 'Particular';
      case comunitario: return 'Comunitário';
      default: return value;
    }
  }
}