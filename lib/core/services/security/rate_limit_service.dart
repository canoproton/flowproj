/// ============================================
/// SERVIÇO DE RATE LIMITING
/// ============================================
/// Previne ataques de força bruta limitando
/// tentativas de login e ações repetitivas
/// ============================================

import 'dart:collection';

class RateLimitService {
  static final RateLimitService _instance = RateLimitService._internal();
  factory RateLimitService() => _instance;
  RateLimitService._internal();

  // ============================================
  // CONFIGURAÇÕES
  // ============================================
  static const int MAX_LOGIN_ATTEMPTS = 5;
  static const int MAX_ACTION_ATTEMPTS = 10;
  static const Duration BLOCK_DURATION = Duration(minutes: 15);
  static const Duration ACTION_WINDOW = Duration(minutes: 5);

  // ============================================
  // ESTRUTURAS DE DADOS
  // ============================================
  final Map<String, int> _loginAttempts = {};
  final Map<String, DateTime> _loginBlockedUntil = {};
  final Map<String, Queue<DateTime>> _actionTimestamps = {};

  // ============================================
  // 1. VERIFICAÇÃO DE LOGIN
  // ============================================
  /// Verifica se o usuário pode tentar login
  bool canAttemptLogin(String identifier) {
    // Verificar se está bloqueado
    if (_loginBlockedUntil.containsKey(identifier)) {
      if (DateTime.now().isBefore(_loginBlockedUntil[identifier]!)) {
        return false;
      }
      // Desbloquear se o tempo expirou
      _loginBlockedUntil.remove(identifier);
      _loginAttempts.remove(identifier);
    }
    return true;
  }

  // ============================================
  // 2. REGISTRO DE TENTATIVA DE LOGIN
  // ============================================
  /// Registra tentativa de login e bloqueia se exceder
  Map<String, dynamic> registerLoginAttempt(String identifier, bool success) {
    if (success) {
      // Sucesso - resetar contagem
      _loginAttempts.remove(identifier);
      _loginBlockedUntil.remove(identifier);
      return {
        'allowed': true,
        'message': 'Login realizado com sucesso',
        'blocked': false,
      };
    }

    // Incrementar tentativas
    _loginAttempts[identifier] = (_loginAttempts[identifier] ?? 0) + 1;
    final attempts = _loginAttempts[identifier]!;
    final remaining = MAX_LOGIN_ATTEMPTS - attempts;

    if (attempts >= MAX_LOGIN_ATTEMPTS) {
      // Bloquear
      _loginBlockedUntil[identifier] = DateTime.now().add(BLOCK_DURATION);
      return {
        'allowed': false,
        'message': 'Muitas tentativas falhas. Bloqueado por 15 minutos.',
        'blocked': true,
        'blocked_until': _loginBlockedUntil[identifier],
      };
    }

    return {
      'allowed': true,
      'message': 'Tentativa falha. $remaining tentativas restantes.',
      'blocked': false,
      'remaining': remaining,
    };
  }

  // ============================================
  // 3. VERIFICAÇÃO DE AÇÃO
  // ============================================
  /// Verifica se o usuário pode realizar uma ação
  bool canPerformAction(String userId, String action) {
    final key = '$userId:$action';

    if (!_actionTimestamps.containsKey(key)) {
      _actionTimestamps[key] = Queue<DateTime>();
    }

    final timestamps = _actionTimestamps[key]!;

    // Remover timestamps antigos
    final cutoff = DateTime.now().subtract(ACTION_WINDOW);
    while (timestamps.isNotEmpty && timestamps.first.isBefore(cutoff)) {
      timestamps.removeFirst();
    }

    // Verificar se excedeu o limite
    if (timestamps.length >= MAX_ACTION_ATTEMPTS) {
      return false;
    }

    // Adicionar novo timestamp
    timestamps.add(DateTime.now());
    return true;
  }

  // ============================================
  // 4. RESET DE CONTAGEM
  // ============================================
  /// Reseta contagens para um identificador
  void resetCounters(String identifier) {
    _loginAttempts.remove(identifier);
    _loginBlockedUntil.remove(identifier);
    _actionTimestamps.removeWhere((key, _) => key.startsWith(identifier));
  }

  // ============================================
  // 5. ESTATÍSTICAS DO RATE LIMITING
  // ============================================
  Map<String, dynamic> getStats() {
    return {
      'total_login_attempts': _loginAttempts.length,
      'total_blocked': _loginBlockedUntil.length,
      'total_actions': _actionTimestamps.length,
      'blocked_until': _loginBlockedUntil.map(
        (key, value) => MapEntry(key, value.toString())
      ),
    };
  }
}