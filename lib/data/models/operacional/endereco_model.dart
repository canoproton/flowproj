/// ============================================
/// MODELO DE ENDEREÇO
/// ============================================
/// Tabela: tb_oender
/// Endereço vinculado a um Contato ou Empresa
/// (Polimórfico - origem_id + origem_type)
/// ============================================

import 'package:equatable/equatable.dart';

class EnderecoModel extends Equatable {
  final String id;
  final String origemId;
  final String origemType;  // 'contato' ou 'empresa'
  final String logradouro;
  final String? bairro;
  final String? cidade;
  final String? estado;
  final String? cep;
  final String? obs;
  
  // Auditoria
  final String? atuaPorId;
  final DateTime? atuaEm;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const EnderecoModel({
    required this.id,
    required this.origemId,
    required this.origemType,
    required this.logradouro,
    this.bairro,
    this.cidade,
    this.estado,
    this.cep,
    this.obs,
    this.atuaPorId,
    this.atuaEm,
    this.createdAt,
    this.updatedAt,
  });

  factory EnderecoModel.fromJson(Map<String, dynamic> json) {
    return EnderecoModel(
      id: json['id']?.toString() ?? '',
      origemId: json['origem_id']?.toString() ?? '',
      origemType: json['origem_type']?.toString() ?? '',
      logradouro: json['logradouro']?.toString() ?? '',
      bairro: json['bairro']?.toString(),
      cidade: json['cidade']?.toString(),
      estado: json['estado']?.toString(),
      cep: json['cep']?.toString(),
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
      'logradouro': logradouro,
      'bairro': bairro,
      'cidade': cidade,
      'estado': estado,
      'cep': cep,
      'obs': obs,
      'atua_por_id': atuaPorId,
      'atua_em': atuaEm?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Endereço completo formatado
  String get enderecoCompleto {
    final parts = <String>[];
    if (logradouro.isNotEmpty) parts.add(logradouro);
    if (bairro != null && bairro!.isNotEmpty) parts.add(bairro!);
    if (cidade != null && cidade!.isNotEmpty) {
      if (estado != null && estado!.isNotEmpty) {
        parts.add('$cidade - $estado');
      } else {
        parts.add(cidade!);
      }
    }
    if (cep != null && cep!.isNotEmpty) parts.add('CEP: $cepFormatado');
    return parts.join(', ');
  }

  /// CEP formatado
  String get cepFormatado {
    if (cep == null || cep!.length != 8) return cep ?? '';
    return '${cep!.substring(0, 5)}-${cep!.substring(5)}';
  }

  @override
  List<Object?> get props => [id, logradouro, cidade, estado, origemId];
}

/// Estados Brasileiros
class EstadoBrasileiro {
  static const Map<String, String> estados = {
    'AC': 'Acre',
    'AL': 'Alagoas',
    'AP': 'Amapá',
    'AM': 'Amazonas',
    'BA': 'Bahia',
    'CE': 'Ceará',
    'DF': 'Distrito Federal',
    'ES': 'Espírito Santo',
    'GO': 'Goiás',
    'MA': 'Maranhão',
    'MT': 'Mato Grosso',
    'MS': 'Mato Grosso do Sul',
    'MG': 'Minas Gerais',
    'PA': 'Pará',
    'PB': 'Paraíba',
    'PR': 'Paraná',
    'PE': 'Pernambuco',
    'PI': 'Piauí',
    'RJ': 'Rio de Janeiro',
    'RN': 'Rio Grande do Norte',
    'RS': 'Rio Grande do Sul',
    'RO': 'Rondônia',
    'RR': 'Roraima',
    'SC': 'Santa Catarina',
    'SP': 'São Paulo',
    'SE': 'Sergipe',
    'TO': 'Tocantins',
  };

  static List<String> get siglas => estados.keys.toList();

  static String getNome(String sigla) {
    return estados[sigla] ?? sigla;
  }
}