/// ============================================
/// MODELO DE EMAIL
/// ============================================
/// Tabela: tb_oemail
/// Email vinculado a um Contato ou Empresa
/// (Polimórfico - origem_id + origem_type)
/// ============================================

import 'package:equatable/equatable.dart';

class EmailModel extends Equatable {
  final String id;
  final String origemId;
  final String origemType;  // 'contato' ou 'empresa'
  final String uso;         // CORPORATIVO, PARTICULAR, COMUNITÁRIO
  final String endereco;
  final String? obs;
  
  // Auditoria
  final String? atuaPorId;
  final DateTime? atuaEm;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const EmailModel({
    required this.id,
    required this.origemId,
    required this.origemType,
    required this.uso,
    required this.endereco,
    this.obs,
    this.atuaPorId,
    this.atuaEm,
    this.createdAt,
    this.updatedAt,
  });

  factory EmailModel.fromJson(Map<String, dynamic> json) {
    return EmailModel(
      id: json['id']?.toString() ?? '',
      origemId: json['origem_id']?.toString() ?? '',
      origemType: json['origem_type']?.toString() ?? '',
      uso: json['uso']?.toString() ?? 'PARTICULAR',
      endereco: json['endereco']?.toString() ?? '',
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
      'endereco': endereco,
      'obs': obs,
      'atua_por_id': atuaPorId,
      'atua_em': atuaEm?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Verifica se o email é válido
  bool get isValid {
    final regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return regex.hasMatch(endereco);
  }

  @override
  List<Object?> get props => [id, endereco, uso, origemId];
}

/// Tipos de Uso do Email
class UsoEmail {
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