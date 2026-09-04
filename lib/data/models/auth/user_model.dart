/// ============================================
/// MODELO DE USUÁRIO
/// ============================================
/// Representa o usuário autenticado no sistema
/// ============================================

import 'package:equatable/equatable.dart';
import 'profile_model.dart';

class UserModel extends Equatable {
  final String id;
  final String email;
  final String? name;
  final String? avatarUrl;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>? metadata;
  
  // ✅ NOVO: Nível de acesso do usuário
  final NivelAcesso? nivelAcesso;

  const UserModel({
    required this.id,
    required this.email,
    this.name,
    this.avatarUrl,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
    this.metadata,
    this.nivelAcesso,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      name: json['name']?.toString() ?? json['full_name']?.toString(),
      avatarUrl: json['avatar_url']?.toString(),
      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'].toString())
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
      nivelAcesso: json['nivel_acesso'] != null
          ? NivelAcesso.fromString(json['nivel_acesso'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'avatar_url': avatarUrl,
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'metadata': metadata,
      'nivel_acesso': nivelAcesso?.name.toUpperCase(),
    };
  }

  /// Iniciais do nome do usuário
  String get initials {
    if (name == null || name!.isEmpty) {
      return email.substring(0, 1).toUpperCase();
    }
    final names = name!.split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    }
    return name!.substring(0, 2).toUpperCase();
  }

  /// Nome de exibição (primeiro nome)
  String get displayName {
    if (name == null || name!.isEmpty) {
      return email.split('@').first;
    }
    return name!;
  }

  // ✅ NOVOS GETTERS DE PERMISSÃO
  bool get isHyper => nivelAcesso == NivelAcesso.hyper;
  bool get isAdmin => nivelAcesso == NivelAcesso.admin || isHyper;
  bool get isManager => nivelAcesso == NivelAcesso.manager || isAdmin;
  bool get isSupervisor => nivelAcesso == NivelAcesso.supervisor || isManager;
  bool get isUser => nivelAcesso == NivelAcesso.user || isSupervisor;
  bool get isGuest => nivelAcesso == NivelAcesso.guest || isUser;

  @override
  List<Object?> get props => [id, email, name, isActive, nivelAcesso];
}