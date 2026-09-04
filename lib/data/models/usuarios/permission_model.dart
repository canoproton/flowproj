/// ============================================
/// MODELO DE PERMISSÃO
/// ============================================
/// Tabela: public.permissions
/// Permissões granulares por usuário e módulo
/// ============================================

import 'package:equatable/equatable.dart';
import '../auth/profile_model.dart';

enum PermissaoAction {
  read,
  create,
  edit,
  delete,
  export,
}

class PermissionModel extends Equatable {
  final String id;
  final String profileId;
  final String moduleId;
  final bool canRead;
  final bool canCreate;
  final bool canEdit;
  final bool canDelete;
  final bool canExport;
  final bool isCustom;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const PermissionModel({
    required this.id,
    required this.profileId,
    required this.moduleId,
    this.canRead = false,
    this.canCreate = false,
    this.canEdit = false,
    this.canDelete = false,
    this.canExport = false,
    this.isCustom = false,
    this.createdAt,
    this.updatedAt,
  });

  factory PermissionModel.fromJson(Map<String, dynamic> json) {
    return PermissionModel(
      id: json['id']?.toString() ?? '',
      profileId: json['profile_id']?.toString() ?? '',
      moduleId: json['module_id']?.toString() ?? '',
      canRead: json['can_read'] ?? false,
      canCreate: json['can_create'] ?? false,
      canEdit: json['can_edit'] ?? false,
      canDelete: json['can_delete'] ?? false,
      canExport: json['can_export'] ?? false,
      isCustom: json['is_custom'] ?? false,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'profile_id': profileId,
      'module_id': moduleId,
      'can_read': canRead,
      'can_create': canCreate,
      'can_edit': canEdit,
      'can_delete': canDelete,
      'can_export': canExport,
      'is_custom': isCustom,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  bool hasPermission(PermissaoAction action) {
    switch (action) {
      case PermissaoAction.read:
        return canRead;
      case PermissaoAction.create:
        return canCreate;
      case PermissaoAction.edit:
        return canEdit;
      case PermissaoAction.delete:
        return canDelete;
      case PermissaoAction.export:
        return canExport;
    }
  }

  /// Cria permissão padrão baseada no nível de acesso
  factory PermissionModel.fromNivel({
    required String profileId,
    required String moduleId,
    required NivelAcesso nivel,
    bool isCustom = false,
  }) {
    switch (nivel) {
      case NivelAcesso.hyper:
      case NivelAcesso.admin:
        return PermissionModel(
          id: '',
          profileId: profileId,
          moduleId: moduleId,
          canRead: true,
          canCreate: true,
          canEdit: true,
          canDelete: true,
          canExport: true,
          isCustom: isCustom,
        );
      case NivelAcesso.manager:
        return PermissionModel(
          id: '',
          profileId: profileId,
          moduleId: moduleId,
          canRead: true,
          canCreate: true,
          canEdit: true,
          canDelete: true,
          canExport: true,
          isCustom: isCustom,
        );
      case NivelAcesso.supervisor:
        return PermissionModel(
          id: '',
          profileId: profileId,
          moduleId: moduleId,
          canRead: true,
          canCreate: true,
          canEdit: true,
          canDelete: false,
          canExport: true,
          isCustom: isCustom,
        );
      case NivelAcesso.user:
        return PermissionModel(
          id: '',
          profileId: profileId,
          moduleId: moduleId,
          canRead: true,
          canCreate: false,
          canEdit: false,
          canDelete: false,
          canExport: false,
          isCustom: isCustom,
        );
      case NivelAcesso.guest:
        return PermissionModel(
          id: '',
          profileId: profileId,
          moduleId: moduleId,
          canRead: true,
          canCreate: false,
          canEdit: false,
          canDelete: false,
          canExport: false,
          isCustom: isCustom,
        );
    }
  }

  /// Combinações comuns de permissões
  static PermissionModel readonly({
    required String profileId,
    required String moduleId,
  }) {
    return PermissionModel(
      id: '',
      profileId: profileId,
      moduleId: moduleId,
      canRead: true,
      canCreate: false,
      canEdit: false,
      canDelete: false,
      canExport: true,
    );
  }

  static PermissionModel fullAccess({
    required String profileId,
    required String moduleId,
  }) {
    return PermissionModel(
      id: '',
      profileId: profileId,
      moduleId: moduleId,
      canRead: true,
      canCreate: true,
      canEdit: true,
      canDelete: true,
      canExport: true,
    );
  }

  static PermissionModel editor({
    required String profileId,
    required String moduleId,
  }) {
    return PermissionModel(
      id: '',
      profileId: profileId,
      moduleId: moduleId,
      canRead: true,
      canCreate: true,
      canEdit: true,
      canDelete: false,
      canExport: true,
    );
  }

  @override
  List<Object?> get props => [id, profileId, moduleId, canRead, canCreate, canEdit, canDelete];
}