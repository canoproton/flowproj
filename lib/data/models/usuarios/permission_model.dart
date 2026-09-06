import '../../auth/profile_model.dart';

class PermissionModel {
  final String profileId;
  final String moduleId;
  final bool canRead;
  final bool canWrite;
  final bool canDelete;
  final bool isCustom;

  const PermissionModel({
    required this.profileId,
    required this.moduleId,
    this.canRead = false,
    this.canWrite = false,
    this.canDelete = false,
    this.isCustom = false,
  });

  PermissionModel copyWith({
    String? profileId,
    String? moduleId,
    bool? canRead,
    bool? canWrite,
    bool? canDelete,
    bool? isCustom,
  }) {
    return PermissionModel(
      profileId: profileId ?? this.profileId,
      moduleId: moduleId ?? this.moduleId,
      canRead: canRead ?? this.canRead,
      canWrite: canWrite ?? this.canWrite,
      canDelete: canDelete ?? this.canDelete,
      isCustom: isCustom ?? this.isCustom,
    );
  }

  factory PermissionModel.fromJson(Map<String, dynamic> json) {
    return PermissionModel(
      profileId: json['profile_id']?.toString() ?? '',
      moduleId: json['module_id']?.toString() ?? '',
      canRead: json['can_read'] ?? false,
      canWrite: json['can_write'] ?? false,
      canDelete: json['can_delete'] ?? false,
      isCustom: json['is_custom'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'profile_id': profileId,
      'module_id': moduleId,
      'can_read': canRead,
      'can_write': canWrite,
      'can_delete': canDelete,
      'is_custom': isCustom,
    };
  }

  // ============================================
  // MÉTODO: Criar permissão a partir do nível de acesso
  // ============================================
  factory PermissionModel.fromNivel({
    required String profileId,
    required String moduleId,
    required NivelAcesso nivel,
    bool isCustom = false,
  }) {
    // Definir permissões baseadas no nível de acesso
    bool canRead = true;
    bool canWrite = false;
    bool canDelete = false;

    switch (nivel) {
      case NivelAcesso.ADMIN:
        canRead = true;
        canWrite = true;
        canDelete = true;
        break;
      case NivelAcesso.MANAGER:
        canRead = true;
        canWrite = true;
        canDelete = false;
        break;
      case NivelAcesso.USER:
        canRead = true;
        canWrite = false;
        canDelete = false;
        break;
      case NivelAcesso.VIEWER:
        canRead = true;
        canWrite = false;
        canDelete = false;
        break;
    }

    return PermissionModel(
      profileId: profileId,
      moduleId: moduleId,
      canRead: canRead,
      canWrite: canWrite,
      canDelete: canDelete,
      isCustom: isCustom,
    );
  }
}