#!/bin/bash

# ============================================
# SCRIPT DE VERIFICAÇÃO DO AMBIENTE COM LOG
# ============================================
# Verifica se todas as ferramentas necessárias
# estão instaladas e rodando corretamente
# Gera um arquivo de log com todos os resultados
# ============================================

# Cores para o terminal
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Diretório de logs
LOG_DIR="/Users/khambay/Documents/0_z/logsFlutter"
mkdir -p "$LOG_DIR"

# Data e hora para o nome do arquivo
DATA_HORA=$(date +"%Y%m%d_%H%M%S")
LOG_FILE="${LOG_DIR}/check_environment_${DATA_HORA}.txt"

# Arquivo de log para erros
ERROR_LOG="${LOG_DIR}/check_environment_erros.txt"

# ============================================
# FUNÇÕES DE LOG
# ============================================
log() {
    echo "$1" | tee -a "$LOG_FILE"
}

log_ok() {
    echo -e "${GREEN}✅ $1${NC}" | tee -a "$LOG_FILE"
}

log_warn() {
    echo -e "${YELLOW}⚠️  $1${NC}" | tee -a "$LOG_FILE"
}

log_error() {
    echo -e "${RED}❌ $1${NC}" | tee -a "$LOG_FILE"
    echo "ERRO: $1" >> "$ERROR_LOG"
}

log_info() {
    echo -e "${BLUE}$1${NC}" | tee -a "$LOG_FILE"
}

log_section() {
    echo "" | tee -a "$LOG_FILE"
    echo "========================================" | tee -a "$LOG_FILE"
    echo -e "${BLUE}$1${NC}" | tee -a "$LOG_FILE"
    echo "========================================" | tee -a "$LOG_FILE"
}

# ============================================
# INÍCIO DO LOG
# ============================================
echo "" | tee -a "$LOG_FILE"
log_section "🔍 VERIFICAÇÃO DO AMBIENTE - FLOWPROJ"
log "📅 Data: $(date)"
log "📁 Log: $LOG_FILE"
echo "" | tee -a "$LOG_FILE"

# Contadores
TOTAL_CHECKS=0
OK_COUNT=0
WARN_COUNT=0
ERROR_COUNT=0

# ============================================
# 1. VERIFICAR DOCKER (COLIMA)
# ============================================
log_section "[1/6] Verificando Docker/Colima"

if command -v colima &> /dev/null; then
    log_ok "Colima instalado"
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    OK_COUNT=$((OK_COUNT + 1))
    
    if colima status &> /dev/null; then
        log_ok "Colima está rodando"
        TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
        OK_COUNT=$((OK_COUNT + 1))
    else
        log_warn "Colima não está rodando. Execute: colima start"
        TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
        WARN_COUNT=$((WARN_COUNT + 1))
    fi
else
    log_error "Colima não encontrado. Instale com: brew install colima"
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    ERROR_COUNT=$((ERROR_COUNT + 1))
fi

if command -v docker &> /dev/null; then
    log_ok "Docker instalado"
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    OK_COUNT=$((OK_COUNT + 1))
    
    if docker ps &> /dev/null; then
        log_ok "Docker está respondendo"
        TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
        OK_COUNT=$((OK_COUNT + 1))
    else
        log_warn "Docker não responde. Verifique se o Colima está rodando."
        TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
        WARN_COUNT=$((WARN_COUNT + 1))
    fi
else
    log_error "Docker não encontrado."
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    ERROR_COUNT=$((ERROR_COUNT + 1))
fi

# ============================================
# 2. VERIFICAR FLUTTER
# ============================================
log_section "[2/6] Verificando Flutter"

if command -v flutter &> /dev/null; then
    FLUTTER_VERSION=$(flutter --version | head -n 1)
    log_ok "Flutter instalado: $FLUTTER_VERSION"
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    OK_COUNT=$((OK_COUNT + 1))
    
    # Verificar se o Flutter está atualizado
    FLUTTER_CHANNEL=$(flutter --version | grep -i "channel" | awk '{print $2}')
    log_info "  📌 Canal: $FLUTTER_CHANNEL"
else
    log_error "Flutter não encontrado."
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    ERROR_COUNT=$((ERROR_COUNT + 1))
fi

# ============================================
# 3. VERIFICAR SUPABASE CLI
# ============================================
log_section "[3/6] Verificando Supabase CLI"

if command -v supabase &> /dev/null; then
    SUPABASE_VERSION=$(supabase --version 2>/dev/null || echo "versão desconhecida")
    log_ok "Supabase CLI instalado: $SUPABASE_VERSION"
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    OK_COUNT=$((OK_COUNT + 1))
    
    cd /Users/khambay/Documents/0Dev/flowproj/flowproj
    if supabase status &> /dev/null; then
        log_ok "Supabase local está rodando"
        TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
        OK_COUNT=$((OK_COUNT + 1))
        
        # Pegar URLs do Supabase
        SUPABASE_API_URL=$(supabase status | grep "API URL" | awk '{print $3}')
        SUPABASE_STUDIO_URL=$(supabase status | grep "Studio" | awk '{print $3}')
        log_info "  📌 API URL: $SUPABASE_API_URL"
        log_info "  📌 Studio URL: $SUPABASE_STUDIO_URL"
    else
        log_warn "Supabase local não está rodando. Execute: supabase start"
        TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
        WARN_COUNT=$((WARN_COUNT + 1))
    fi
else
    log_error "Supabase CLI não encontrado. Instale com: brew install supabase/tap/supabase"
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    ERROR_COUNT=$((ERROR_COUNT + 1))
fi

# ============================================
# 4. VERIFICAR GIT
# ============================================
log_section "[4/6] Verificando Git"

if command -v git &> /dev/null; then
    GIT_VERSION=$(git --version)
    log_ok "Git instalado: $GIT_VERSION"
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    OK_COUNT=$((OK_COUNT + 1))
    
    cd /Users/khambay/Documents/0Dev/flowproj/flowproj
    if git status &> /dev/null; then
        log_ok "Repositório Git OK"
        TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
        OK_COUNT=$((OK_COUNT + 1))
        
        BRANCH=$(git branch --show-current)
        log_info "  📌 Branch atual: $BRANCH"
        
        # Verificar se há alterações não commitadas
        if [[ -n $(git status -s) ]]; then
            log_warn "Há alterações não commitadas"
            TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
            WARN_COUNT=$((WARN_COUNT + 1))
        else
            log_ok "Working directory limpo"
            TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
            OK_COUNT=$((OK_COUNT + 1))
        fi
    else
        log_warn "Não é um repositório Git"
        TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
        WARN_COUNT=$((WARN_COUNT + 1))
    fi
else
    log_error "Git não encontrado."
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    ERROR_COUNT=$((ERROR_COUNT + 1))
fi

# ============================================
# 5. VERIFICAR VS CODE
# ============================================
log_section "[5/6] Verificando VS Code"

if command -v code &> /dev/null; then
    log_ok "VS Code instalado"
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    OK_COUNT=$((OK_COUNT + 1))
    
    # Verificar extensões importantes
    if code --list-extensions | grep -q "dart-code.flutter"; then
        log_ok "  ✅ Flutter extension instalada"
    else
        log_warn "  ⚠️  Flutter extension não instalada"
    fi
    
    if code --list-extensions | grep -q "dart-code.dart"; then
        log_ok "  ✅ Dart extension instalada"
    else
        log_warn "  ⚠️  Dart extension não instalada"
    fi
else
    log_warn "VS Code não encontrado no PATH"
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    WARN_COUNT=$((WARN_COUNT + 1))
fi

# ============================================
# 6. VERIFICAR DEPENDÊNCIAS DO PROJETO
# ============================================
log_section "[6/6] Verificando dependências do projeto"

cd /Users/khambay/Documents/0Dev/flowproj/flowproj

if [ -f ".env" ]; then
    log_ok ".env encontrado"
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    OK_COUNT=$((OK_COUNT + 1))
    
    # Verificar se tem as chaves do Supabase
    if grep -q "SUPABASE_URL" .env && grep -q "SUPABASE_ANON_KEY" .env; then
        log_ok "  ✅ Supabase configurado no .env"
    else
        log_warn "  ⚠️  Supabase não configurado no .env"
    fi
else
    log_error ".env não encontrado"
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    ERROR_COUNT=$((ERROR_COUNT + 1))
fi

if [ -f "pubspec.yaml" ]; then
    log_ok "pubspec.yaml encontrado"
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    OK_COUNT=$((OK_COUNT + 1))
else
    log_error "pubspec.yaml não encontrado"
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    ERROR_COUNT=$((ERROR_COUNT + 1))
fi

if [ -d ".dart_tool" ]; then
    log_ok ".dart_tool encontrado (dependências instaladas)"
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    OK_COUNT=$((OK_COUNT + 1))
else
    log_warn "Execute: flutter pub get"
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    WARN_COUNT=$((WARN_COUNT + 1))
fi

# Verificar se o projeto compila
if [ -f "build/" ]; then
    log_ok "Projeto já compilado (build/ encontrado)"
else
    log_warn "Projeto não compilado. Execute: flutter run"
fi

# ============================================
# 7. RESUMO FINAL
# ============================================
log_section "📋 RESUMO DA VERIFICAÇÃO"

log "Total de verificações: $TOTAL_CHECKS"
log_ok "✅ OK: $OK_COUNT"
log_warn "⚠️  ATENÇÃO: $WARN_COUNT"
log_error "❌ ERRO: $ERROR_COUNT"

echo "" | tee -a "$LOG_FILE"
log_info "📁 Log completo salvo em: $LOG_FILE"

if [ -f "$ERROR_LOG" ]; then
    log_warn "📁 Erros salvos em: $ERROR_LOG"
    echo "" | tee -a "$LOG_FILE"
    log_info "🔴 Lista de erros encontrados:"
    cat "$ERROR_LOG" | tee -a "$LOG_FILE"
    rm -f "$ERROR_LOG"
fi

echo "" | tee -a "$LOG_FILE"
log_section "✅ Verificação concluída!"

# Status de saída
if [ $ERROR_COUNT -gt 0 ]; then
    exit 1
else
    exit 0
fi