import 'package:flutter/material.dart';
import '../../../data/models/usuarios/module_model.dart';
import '../../../data/models/usuarios/permission_model.dart';

class PermissionToggle extends StatelessWidget {
  final ModuleModel module;  // ← Mudar de 'modulo' para 'module'
  final PermissionModel permissao;
  final Function(PermissionModel) onChanged;

  const PermissionToggle({
    super.key,
    required this.module,
    required this.permissao,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getIconForModule(module.nome),
                  color: module.isActive ? Colors.blue : Colors.grey,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        module.nome,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (module.descricao != null)
                        Text(
                          module.descricao!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: module.isActive ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    module.isActive ? 'Ativo' : 'Inativo',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
            if (module.isActive) ...[
              const Divider(),
              Row(
                children: [
                  _buildPermissionChip(
                    label: 'Ler',
                    value: permissao.canRead,
                    onChanged: (value) {
                      onChanged(permissao.copyWith(canRead: value));
                    },
                  ),
                  const SizedBox(width: 8),
                  _buildPermissionChip(
                    label: 'Escrever',
                    value: permissao.canWrite,
                    onChanged: (value) {
                      onChanged(permissao.copyWith(canWrite: value));
                    },
                  ),
                  const SizedBox(width: 8),
                  _buildPermissionChip(
                    label: 'Deletar',
                    value: permissao.canDelete,
                    onChanged: (value) {
                      onChanged(permissao.copyWith(canDelete: value));
                    },
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionChip({
    required String label,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return FilterChip(
      label: Text(label),
      selected: value,
      onSelected: onChanged,
      selectedColor: Colors.blue.shade100,
      backgroundColor: Colors.grey.shade200,
      checkmarkColor: Colors.blue,
    );
  }

  IconData _getIconForModule(String nome) {
    switch (nome.toLowerCase()) {
      case 'dashboard':
        return Icons.dashboard;
      case 'usuários':
        return Icons.people;
      case 'projetos':
        return Icons.folder;
      case 'tarefas':
        return Icons.task;
      case 'operacional':
        return Icons.build;
      case 'contabilidade':
        return Icons.account_balance;
      case 'financeiro':
        return Icons.attach_money;
      case 'documentos':
        return Icons.description;
      case 'ia':
        return Icons.psychology;
      default:
        return Icons.circle;
    }
  }
}