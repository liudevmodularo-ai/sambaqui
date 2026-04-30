#!/bin/bash

# ============================================================================
# 🚀 SCRIPT DE REINSTALAÇÃO COMPLETA - SAMBAQUI TOWER HOUSE
# Remove a instalação existente e executa uma nova a partir do Git.
# ============================================================================

set -e

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Funções de print
print_header() { echo -e "\n${BLUE}════════════════════════════════════════════════════════════${NC}\n${BLUE}$1${NC}\n${BLUE}════════════════════════════════════════════════════════════${NC}\n"; }
print_success() { echo -e "${GREEN}✓ $1${NC}"; }
print_error() { echo -e "${RED}✗ $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠ $1${NC}"; }
print_info() { echo -e "${BLUE}ℹ $1${NC}"; }

# ============================================================================
# VERIFICAÇÕES E CONFIRMAÇÃO
# ============================================================================

print_header "🔥 REINSTALAÇÃO COMPLETA"

# Verifica se é root
if [[ $EUID -ne 0 ]]; then
   print_error "Este script deve ser executado como root (use: sudo ./reinstall.sh)"
   exit 1
fi

# Carrega variáveis do .env para saber o que remover
if [ -f ".env" ]; then
    print_info "Arquivo .env encontrado. Carregando configurações para limpeza..."
    set -o allexport
    source .env
    set +o allexport
    INSTALL_DIR=${INSTALL_DIR:-/var/www/sambaqui}
else
    print_error "Arquivo .env não encontrado. Não é possível continuar."
    print_info "Crie um arquivo .env a partir do .env.example para definir as configurações."
    exit 1
fi

print_warning "Este script irá REMOVER COMPLETAMENTE a instalação atual."
print_warning "Diretório a ser removido: $INSTALL_DIR"
print_warning "Serviços (nginx, supervisor) serão reconfigurados."
print_warning "O banco de dados será APAGADO."
read -p "$(echo -e ${YELLOW}'Você tem certeza que deseja continuar? (s/n): '${NC})" CONFIRM
if [[ "$CONFIRM" != "s" && "$CONFIRM" != "S" ]]; then
    print_info "Reinstalação cancelada."
    exit 0
fi

# ============================================================================
# LIMPEZA DO AMBIENTE ANTIGO
# ============================================================================

print_header "🧹 LIMPANDO INSTALAÇÃO ANTIGA"

# 1. Parar e remover serviços
print_info "Parando serviços..."
supervisorctl stop sambaqui || print_warning "Serviço 'sambaqui' do supervisor não encontrado ou já parado."
systemctl stop nginx || print_warning "Nginx não encontrado ou já parado."

# 2. Remover arquivos de configuração
print_info "Removendo arquivos de configuração..."
rm -f /etc/supervisor/conf.d/sambaqui.conf
rm -f /etc/nginx/sites-enabled/sambaqui
rm -f /etc/nginx/sites-available/sambaqui
supervisorctl reread
supervisorctl update

# 3. Remover cron de backup
print_info "Removendo agendamento de backup..."
(crontab -u root -l 2>/dev/null | grep -v backup-sambaqui || true) | crontab -u root -
rm -f /usr/local/bin/backup-sambaqui

# 4. Remover diretório de instalação
print_info "Removendo diretório de instalação: $INSTALL_DIR"
rm -rf "$INSTALL_DIR"

print_success "Limpeza concluída."

# ============================================================================
# EXECUÇÃO DA NOVA INSTALAÇÃO
# ============================================================================

print_header "🚀 INICIANDO NOVA INSTALAÇÃO"

# Garante que o install.sh é executável
chmod +x ./install.sh

# Executa o script de instalação, que agora lerá as configs do .env
./install.sh

print_success "Reinstalação concluída com sucesso!"