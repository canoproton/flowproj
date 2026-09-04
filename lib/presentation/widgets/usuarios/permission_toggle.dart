/// ============================================
/// PERMISSION TOGGLE
/// ============================================
/// Widget para exibir e editar permissões
/// de um módulo específico
/// ============================================

import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/usuarios/module_model.dart';
import '../../../data/models/usuarios/permission_model.dart';

class PermissionToggle extends StatefulWidget {
  final ModuleModel module;
  final PermissionModel permissao;
  final Function(PermissionModel) onChanged;

  const PermissionToggle({
    super.key,
    required this.module,
    required this.permissao,
    required this.onChanged,
  });

  @override
  State<PermissionToggle> createState() => _PermissionToggleState();
}

class _PermissionToggleState extends State<PermissionToggle> {
  late PermissionModel _permissao;

  @override
  void initState() {
    super.initState();
    _permissao = widget.permissao;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade100),
        ),
      ),
      child: Row(
        children: [
          // Ícone do módulo
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withAlpha(13),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getIconData(widget.module.icone ?? ''),
              size: 20,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(width: 12),
          // Nome do módulo
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.module.nome,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimary,
                  ),
                ),
                if (widget.module.descricao != null)
                  Text(
                    widget.module.descricao!,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                    ),
                  ),
              ],
            ),
          ),
          // Toggles
          Expanded(
            flex: 3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildToggle('Ler', _permissao.canRead, (value) {
                  _atualizarPermissao(
                    _permissao.copyWith(canRead: value),
                  );
                }),
                const SizedBox(width: 4),
                _buildToggle('Criar', _permissao.canCreate, (value) {
                  _atualizarPermissao(
                    _permissao.copyWith(canCreate: value),
                  );
                }),
                const SizedBox(width: 4),
                _buildToggle('Editar', _permissao.canEdit, (value) {
                  _atualizarPermissao(
                    _permissao.copyWith(canEdit: value),
                  );
                }),
                const SizedBox(width: 4),
                _buildToggle('Excluir', _permissao.canDelete, (value) {
                  _atualizarPermissao(
                    _permissao.copyWith(canDelete: value),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggle(String label, bool value, Function(bool) onChanged) {
    return Column(
      children: [
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppTheme.primaryColor,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
          splashRadius: 16,
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: value ? AppTheme.primaryColor : Colors.grey.shade400,
            fontWeight: value ? FontWeight.w500 : FontWeight.w400,
          ),
        ),
      ],
    );
  }

  void _atualizarPermissao(PermissionModel novaPermissao) {
    setState(() {
      _permissao = novaPermissao;
    });
    widget.onChanged(novaPermissao);
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'dashboard':
        return Icons.dashboard;
      case 'people':
        return Icons.people;
      case 'folder':
        return Icons.folder;
      case 'checklist':
        return Icons.checklist;
      case 'local_shipping':
        return Icons.local_shipping;
      case 'account_balance':
        return Icons.account_balance;
      case 'attach_money':
        return Icons.attach_money;
      case 'folder_open':
        return Icons.folder_open;
      case 'psychology':
        return Icons.psychology;
      case 'settings':
        return Icons.settings;
      case 'history':
        return Icons.history;
      default:
        return Icons.grid_view;
    }
  }
}

extension PermissionModelCopyWith on PermissionModel {
  PermissionModel copyWith({
    String? id,
    String? profileId,
    String? moduleId,
    bool? canRead,
    bool? canCreate,
    bool? canEdit,
    bool? canDelete,
    bool? canExport,
    bool? isCustom,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PermissionModel(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      moduleId: moduleId ?? this.moduleId,
      canRead: canRead ?? this.canRead,
      canCreate: canCreate ?? this.canCreate,
      canEdit: canEdit ?? this.canEdit,
      canDelete: canDelete ?? this.canDelete,
      canExport: canExport ?? this.canExport,
      isCustom: isCustom ?? this.isCustom,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}