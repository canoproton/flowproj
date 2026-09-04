/// ============================================
/// MODELO DE MÓDULO
/// ============================================
/// Tabela: public.modules
/// Representa cada aplicação do SocialFlow
/// ============================================

import 'package:equatable/equatable.dart';
import '../auth/profile_model.dart';

class ModuleModel extends Equatable {
  final String id;
  final String codigo;
  final String nome;
  final String? icone;
  final String? descricao;
  final int ordem;
  final NivelAcesso nivelMinimo;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ModuleModel({
    required this.id,
    required this.codigo,
    required this.nome,
    this.icone,
    this.descricao,
    this.ordem = 0,
    this.nivelMinimo = NivelAcesso.guest,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory ModuleModel.fromJson(Map<String, dynamic> json) {
    return ModuleModel(
      id: json['id']?.toString() ?? '',
      codigo: json['codigo']?.toString() ?? '',
      nome: json['nome']?.toString() ?? '',
      icone: json['icone']?.toString(),
      descricao: json['descricao']?.toString(),
      ordem: json['ordem']?.toInt() ?? 0,
      nivelMinimo: NivelAcesso.fromString(json['nivel_minimo']?.toString() ?? 'GUEST'),
      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'codigo': codigo,
      'nome': nome,
      'icone': icone,
      'descricao': descricao,
      'ordem': ordem,
      'nivel_minimo': nivelMinimo.name.toUpperCase(),
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  bool isAcessivelPor(NivelAcesso nivel) {
    return nivel.podeAcessar(nivelMinimo);
  }

  @override
  List<Object?> get props => [id, codigo, nome, ordem, isActive];
}

/// Módulos padrão do sistema
class ModuleConstants {
  static const String dashboard = 'DASHBOARD';
  static const String usuarios = 'USUARIOS';
  static const String projetos = 'PROJETOS';
  static const String tarefas = 'TAREFAS';
  static const String operacional = 'OPERACIONAL';
  static const String contabilidade = 'CONTABILIDADE';
  static const String financeiro = 'FINANCEIRO';
  static const String documentos = 'DOCUMENTOS';
  static const String ia = 'IA';
  static const String configuracoes = 'CONFIGURACOES';
  static const String logs = 'LOGS';

  static List<ModuleModel> get defaultModules {
    return [
      ModuleModel(
        id: '',
        codigo: dashboard,
        nome: 'Dashboard',
        icone: 'dashboard',
        descricao: 'Visão geral do sistema',
        ordem: 0,
        nivelMinimo: NivelAcesso.guest,
      ),
      ModuleModel(
        id: '',
        codigo: usuarios,
        nome: 'Usuários',
        icone: 'people',
        descricao: 'Gerenciamento de usuários',
        ordem: 1,
        nivelMinimo: NivelAcesso.admin,
      ),
      ModuleModel(
        id: '',
        codigo: projetos,
        nome: 'Projetos',
        icone: 'folder',
        descricao: 'Gestão de projetos',
        ordem: 2,
        nivelMinimo: NivelAcesso.user,
      ),
      ModuleModel(
        id: '',
        codigo: tarefas,
        nome: 'Tarefas',
        icone: 'checklist',
        descricao: 'Gestão de tarefas',
        ordem: 3,
        nivelMinimo: NivelAcesso.user,
      ),
      ModuleModel(
        id: '',
        codigo: operacional,
        nome: 'Operacional',
        icone: 'local_shipping',
        descricao: 'Gestão operacional',
        ordem: 4,
        nivelMinimo: NivelAcesso.supervisor,
      ),
      ModuleModel(
        id: '',
        codigo: contabilidade,
        nome: 'Contabilidade',
        icone: 'account_balance',
        descricao: 'Gestão contábil',
        ordem: 5,
        nivelMinimo: NivelAcesso.manager,
      ),
      ModuleModel(
        id: '',
        codigo: financeiro,
        nome: 'Financeiro',
        icone: 'attach_money',
        descricao: 'Gestão financeira',
        ordem: 6,
        nivelMinimo: NivelAcesso.manager,
      ),
      ModuleModel(
        id: '',
        codigo: documentos,
        nome: 'Documentos',
        icone: 'folder_open',
        descricao: 'Gestão de documentos',
        ordem: 7,
        nivelMinimo: NivelAcesso.user,
      ),
      ModuleModel(
        id: '',
        codigo: ia,
        nome: 'Inteligência Artificial',
        icone: 'psychology',
        descricao: 'Assistente IA',
        ordem: 8,
        nivelMinimo: NivelAcesso.supervisor,
      ),
      ModuleModel(
        id: '',
        codigo: configuracoes,
        nome: 'Configurações',
        icone: 'settings',
        descricao: 'Configurações do sistema',
        ordem: 9,
        nivelMinimo: NivelAcesso.admin,
      ),
      ModuleModel(
        id: '',
        codigo: logs,
        nome: 'Logs/Auditoria',
        icone: 'history',
        descricao: 'Histórico de ações',
        ordem: 10,
        nivelMinimo: NivelAcesso.admin,
      ),
    ];
  }

  static ModuleModel? getByCodigo(String codigo) {
    try {
      return defaultModules.firstWhere((m) => m.codigo == codigo);
    } catch (_) {
      return null;
    }
  }
}