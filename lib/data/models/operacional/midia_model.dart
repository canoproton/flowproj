/// ============================================
/// MODELO DE MÍDIA SOCIAL
/// ============================================
/// Tabela: tb_omidia
/// Mídias sociais vinculadas a um Contato ou Empresa
/// (Polimórfico - origem_id + origem_type)
/// ============================================

import 'package:equatable/equatable.dart';

class MidiaModel extends Equatable {
  final String id;
  final String origemId;
  final String origemType;  // 'contato' ou 'empresa'
  final String uso;         // CORPORATIVO, PARTICULAR, COMUNITÁRIO
  final String tipo;        // APLICATIVO, SITE, MENSAGERIA
  final String descricao;
  final String? obs;
  
  // Auditoria
  final String? atuaPorId;
  final DateTime? atuaEm;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const MidiaModel({
    required this.id,
    required this.origemId,
    required this.origemType,
    required this.uso,
    required this.tipo,
    required this.descricao,
    this.obs,
    this.atuaPorId,
    this.atuaEm,
    this.createdAt,
    this.updatedAt,
  });

  factory MidiaModel.fromJson(Map<String, dynamic> json) {
    return MidiaModel(
      id: json['id']?.toString() ?? '',
      origemId: json['origem_id']?.toString() ?? '',
      origemType: json['origem_type']?.toString() ?? '',
      uso: json['uso']?.toString() ?? 'PARTICULAR',
      tipo: json['tipo']?.toString() ?? 'APLICATIVO',
      descricao: json['descricao']?.toString() ?? '',
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
      'tipo': tipo,
      'descricao': descricao,
      'obs': obs,
      'atua_por_id': atuaPorId,
      'atua_em': atuaEm?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, tipo, descricao, origemId];
}

/// Tipos de Mídia
class TipoMidia {
  static const String aplicativo = 'APLICATIVO';
  static const String site = 'SITE';
  static const String mensageria = 'MENSAGERIA';

  static List<String> get valores => [aplicativo, site, mensageria];

  static String getLabel(String value) {
    switch (value) {
      case aplicativo: return 'Aplicativo';
      case site: return 'Site';
      case mensageria: return 'Mensageria';
      default: return value;
    }
  }
}

/// Aplicativos de Mensageria
class AppMensageria {
  static const String whatsapp = 'Whatsapp';
  static const String telegram = 'Telegram';
  static const String signal = 'Signal';
  static const String discord = 'Discord';
  static const String slack = 'Slack';
  static const String teams = 'Teams';

  static List<String> get valores => [whatsapp, telegram, signal, discord, slack, teams];
}