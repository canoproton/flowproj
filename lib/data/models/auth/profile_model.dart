/// ============================================
/// MODELO DE PERFIL DO USUÁRIO
/// ============================================
/// Tabela: public.profiles
/// Dados adicionais do usuário com nível de acesso
/// ============================================

import 'package:equatable/equatable.dart';

/// Níveis de Acesso do Sistema
enum NivelAcesso {
  hyper('HYPER', 100),
  admin('ADMINISTRADOR', 80),
  manager('GERENTE', 60),
  supervisor('SUPERVISOR', 40),
  user('USUÁRIO', 20),
  guest('CONVIDADO', 0);

  final String label;
  final int prioridade;

  const NivelAcesso(this.label, this.prioridade);

  static NivelAcesso fromString(String value) {
    return NivelAcesso.values.firstWhere(
      (e) => e.name == value.toLowerCase(),
      orElse: () => NivelAcesso.user,
    );
  }

  bool get isHyper => this == NivelAcesso.hyper;
  bool get isAdmin => this == NivelAcesso.admin || isHyper;
  bool get isManager => this == NivelAcesso.manager || isAdmin;
  bool get isSupervisor => this == NivelAcesso.supervisor || isManager;
  bool get isUser => this == NivelAcesso.user || isSupervisor;
  bool get isGuest => this == NivelAcesso.guest || isUser;

  bool podeAcessar(NivelAcesso nivelMinimo) {
    return prioridade >= nivelMinimo.prioridade;
  }

  /// Níveis que este nível pode gerenciar
  List<NivelAcesso> get podeGerenciar {
    switch (this) {
      case NivelAcesso.hyper:
        return [NivelAcesso.hyper];
      case NivelAcesso.admin:
        return [NivelAcesso.hyper, NivelAcesso.admin];
      case NivelAcesso.manager:
        return [NivelAcesso.hyper, NivelAcesso.admin, NivelAcesso.manager];
      case NivelAcesso.supervisor:
        return [NivelAcesso.hyper, NivelAcesso.admin, NivelAcesso.manager, NivelAcesso.supervisor];
      case NivelAcesso.user:
        return [NivelAcesso.hyper, NivelAcesso.admin, NivelAcesso.manager, NivelAcesso.supervisor, NivelAcesso.user];
      case NivelAcesso.guest:
        return NivelAcesso.values;
    }
  }

  String get nome => label;
}

class ProfileModel extends Equatable {
  final String id;
  final String userId;
  final String email;
  final String nome;
  final String? cargo;
  final String? departamento;
  final String? telefone;
  final String? avatarUrl;
  final bool isActive;
  final DateTime? lastLogin;

  // ⭐ NÍVEL DE ACESSO
  final NivelAcesso nivelAcesso;
  final Map<String, dynamic>? permissoesCustomizadas;

  // ⭐ Integração com Contato
  final String? contatoId;
  final bool isContato;

  // Auditoria
  final String? atuaPorId;
  final DateTime? atuaEm;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ProfileModel({
    required this.id,
    required this.userId,
    required this.nome,
    this.cargo,
    this.departamento,
    this.telefone,
    this.avatarUrl,
    this.isActive = true,
    this.lastLogin,
    this.nivelAcesso = NivelAcesso.user,
    this.permissoesCustomizadas,
    this.contatoId,
    this.isContato = false,
    this.atuaPorId,
    this.atuaEm,
    this.createdAt,
    this.updatedAt,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      nome: json['nome']?.toString() ?? '',
      cargo: json['cargo']?.toString(),
      departamento: json['departamento']?.toString(),
      telefone: json['telefone']?.toString(),
      avatarUrl: json['avatar_url']?.toString(),
      isActive: json['is_active'] ?? true,
      lastLogin: json['last_login'] != null
          ? DateTime.parse(json['last_login'])
          : null,
      nivelAcesso: NivelAcesso.fromString(json['nivel_acesso']?.toString() ?? 'USER'),
      permissoesCustomizadas: json['permissoes_customizadas'] as Map<String, dynamic>?,
      contatoId: json['contato_id']?.toString(),
      isContato: json['is_contato'] ?? false,
      atuaPorId: json['atua_por_id']?.toString(),
      atuaEm: json['atua_em'] != null ? DateTime.parse(json['atua_em']) : null,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'nome': nome,
      'cargo': cargo,
      'departamento': departamento,
      'telefone': telefone,
      'avatar_url': avatarUrl,
      'is_active': isActive,
      'last_login': lastLogin?.toIso8601String(),
      'nivel_acesso': nivelAcesso.name.toUpperCase(),
      'permissoes_customizadas': permissoesCustomizadas,
      'contato_id': contatoId,
      'is_contato': isContato,
      'atua_por_id': atuaPorId,
      'atua_em': atuaEm?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // Getters
  bool get isHyper => nivelAcesso.isHyper;
  bool get isAdmin => nivelAcesso.isAdmin;
  bool get isManager => nivelAcesso.isManager;
  bool get isSupervisor => nivelAcesso.isSupervisor;
  bool get isUser => nivelAcesso.isUser;
  bool get isGuest => nivelAcesso.isGuest;

  String get nivelLabel => nivelAcesso.label;

  String get initials {
    final names = nome.split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    }
    return nome.substring(0, 2).toUpperCase();
  }

  String get firstName => nome.split(' ').first;

  @override
  List<Object?> get props => [id, userId, nome, nivelAcesso, isActive];
}