/// ============================================
/// MODELO DE USUÁRIO
/// ============================================
/// Representa o usuário autenticado no sistema
/// ============================================

import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String id;
  final String email;
  final String? name;
  final String? avatarUrl;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>? metadata;

  const UserModel({
    required this.id,
    required this.email,
    this.name,
    this.avatarUrl,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
    this.metadata,
  });

  /// Cria uma instância a partir de um mapa JSON
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
    );
  }

  /// Converte para mapa JSON
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

  @override
  List<Object?> get props => [id, email, name, isActive];
}