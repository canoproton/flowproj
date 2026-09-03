/// ============================================
/// SERVIÇO DE CRIPTOGRAFIA
/// ============================================
/// Protege dados sensíveis em trânsito e em repouso
/// Usa AES-256 para criptografia simétrica
/// ============================================

import 'dart:convert';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:crypto/crypto.dart';

class EncryptionService {
  static final EncryptionService _instance = EncryptionService._internal();
  factory EncryptionService() => _instance;
  EncryptionService._internal();

  // Chaves de criptografia (carregadas do .env)
  late final encrypt.Key _key;
  late final encrypt.IV _iv;

  // ============================================
  // 1. INICIALIZAÇÃO
  // ============================================
  /// Inicializa o serviço com chaves do .env
  void initialize(String keyString, String ivString) {
    _key = encrypt.Key.fromBase64(keyString);
    _iv = encrypt.IV.fromBase64(ivString);
  }

  // ============================================
  // 2. CRIPTOGRAFAR DADOS
  // ============================================
  /// Criptografa dados sensíveis
  String encrypt(String text) {
    try {
      final encrypter = encrypt.Encrypter(encrypt.AES(_key));
      final encrypted = encrypter.encrypt(text, iv: _iv);
      return encrypted.base64;
    } catch (e) {
      throw Exception('Erro ao criptografar dados: $e');
    }
  }

  // ============================================
  // 3. DESCRIPTOGRAFAR DADOS
  // ============================================
  /// Descriptografa dados criptografados
  String decrypt(String encrypted) {
    try {
      final encrypter = encrypt.Encrypter(encrypt.AES(_key));
      final decrypted = encrypter.decrypt(
        encrypt.Encrypted.fromBase64(encrypted),
        iv: _iv,
      );
      return decrypted;
    } catch (e) {
      throw Exception('Erro ao descriptografar dados: $e');
    }
  }

  // ============================================
  // 4. HASH DE SENHA (SHA-256)
  // ============================================
  /// Gera hash seguro de senha
  String hashPassword(String password, {String? salt}) {
    final bytes = utf8.encode(password + (salt ?? ''));
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  // ============================================
  // 5. VERIFICAR SENHA
  // ============================================
  /// Verifica se a senha corresponde ao hash
  bool verifyPassword(String password, String hash, {String? salt}) {
    final computedHash = hashPassword(password, salt: salt);
    return computedHash == hash;
  }

  // ============================================
  // 6. GERAR TOKEN SEGURO
  // ============================================
  /// Gera token aleatório seguro
  String generateSecureToken(int length) {
    final random = encrypt.Random.secure();
    final bytes = random.nextBytes(length);
    return base64Url.encode(bytes).substring(0, length);
  }

  // ============================================
  // 7. CRIPTOGRAFAR MAPA DE DADOS
  // ============================================
  /// Criptografa um mapa de dados para armazenamento
  String encryptMap(Map<String, dynamic> data) {
    final jsonString = jsonEncode(data);
    return encrypt(jsonString);
  }

  // ============================================
  // 8. DESCRIPTOGRAFAR PARA MAPA
  // ============================================
  /// Descriptografa e converte para mapa
  Map<String, dynamic> decryptMap(String encrypted) {
    final jsonString = decrypt(encrypted);
    return jsonDecode(jsonString) as Map<String, dynamic>;
  }

  // ============================================
  // 9. GERAR CHAVE ALEATÓRIA
  // ============================================
  /// Gera chave aleatória para criptografia
  String generateKey() {
    final random = encrypt.Random.secure();
    final key = encrypt.Key.fromSecureRandom(32);
    return key.base64;
  }

  // ============================================
  // 10. GERAR IV ALEATÓRIO
  // ============================================
  /// Gera IV aleatório para criptografia
  String generateIV() {
    final random = encrypt.Random.secure();
    final iv = encrypt.IV.fromSecureRandom(16);
    return iv.base64;
  }
}