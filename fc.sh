#!/bin/bash

# ============================================
# SCRIPT DE COMPILAÇÃO E EXECUÇÃO DO FLUTTER
# ============================================

# Define o diretório de destino dos logs
LOG_DIR="/Users/khambay/Documents/0_z/logsFlutter"

# Cria o diretório se ele não existir
mkdir -p "$LOG_DIR"

# Obtém a data e hora atual no formato YYYYMMDD_HHMMSS
DATA_HORA=$(date +"%Y%m%d_%H%M%S")

# Nome do arquivo de log com caminho completo
LOG_FILE="${LOG_DIR}/flutter_log_completo_${DATA_HORA}.txt"

echo "========================================="
echo "🚀 COMPILANDO FLOWPROJ"
echo "========================================="
echo "📁 Log será salvo em: $LOG_FILE"
echo ""

# 1. Matar processos do Flutter e Dart
echo "🛑 1. Matando processos do Flutter/Dart..."
killall flutter 2>/dev/null
killall dart 2>/dev/null
killall frontend_server 2>/dev/null
killall dartaotruntime 2>/dev/null
killall dartdevc 2>/dev/null
echo "✅ Processos finalizados."
echo ""

# 2. Limpar cache do Flutter
echo "🧹 2. Executando flutter clean..."
flutter clean >> "$LOG_FILE" 2>&1
echo "✅ flutter clean concluído."
echo ""

# 3. Remover pastas de cache
echo "🗑️  3. Removendo pastas de cache..."
rm -rf .dart_tool >> "$LOG_FILE" 2>&1
rm -rf build >> "$LOG_FILE" 2>&1
rm -rf pubspec.lock >> "$LOG_FILE" 2>&1
rm -rf ~/.dart_tool >> "$LOG_FILE" 2>&1
rm -rf ~/.pub-cache/_temp >> "$LOG_FILE" 2>&1
rm -rf ~/development/flutter/bin/cache/flutter_tools.stamp >> "$LOG_FILE" 2>&1
rm -rf ~/development/flutter/bin/cache/artifacts/ >> "$LOG_FILE" 2>&1
echo "✅ Pastas de cache removidas."
echo ""

# 4. Reinstalar pacotes
echo "📦 4. Executando flutter pub get..."
flutter pub get >> "$LOG_FILE" 2>&1
echo "✅ Pacotes reinstalados."
echo ""

# 5. Executar o app
echo "🚀 5. Executando flutter run -d chrome --web-port 8081..."
echo ""
echo "--------------------------------------------------"
echo "🔴 O aplicativo está rodando em: http://localhost:8081"
echo "📝 Log completo em: $LOG_FILE"
echo "🔴 Pressione Ctrl+C para parar."
echo "--------------------------------------------------"
echo ""

# Rodar com verbose e salvar log
flutter run -d chrome --web-port 8081 --verbose 2>&1 | tee -a "$LOG_FILE"

# Mensagem final (quando o usuário pressionar Ctrl+C)
echo ""
echo "--------------------------------------------------"
echo "✅ Execução finalizada."
echo "📁 Log salvo em: $LOG_FILE"
echo "--------------------------------------------------"