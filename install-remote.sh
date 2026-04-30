#!/bin/bash

# ============================================================================
# 🚀 SCRIPT DE INSTALAÇÃO REMOTO E AUTÔNOMO - SAMBAQUI TOWER HOUSE
# Este é o único script necessário na VPS. Ele gerencia a instalação,
# atualização e reinstalação completa do projeto.
# ============================================================================

set -e

# --- CONFIGURAÇÕES ---
GIT_REPO="https://github.com/liudevmodularo-ai/sambaqui.git"
INSTALL_DIR="/var/www/sambaqui"
APP_USER="www-data" # O usuário que roda a aplicação (padrão do install.sh)
# --- FIM DAS CONFIGURAÇÕES ---

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
# FUNÇÕES DE AÇÃO
# ============================================================================

function install_fresh() {
    print_header "🚀 INICIANDO NOVA INSTALAÇÃO"

    # Garante que o git está instalado
    if ! command -v git &> /dev/null; then
        print_info "Git não encontrado. Instalando..."
        apt-get update -y && apt-get install -y git
    fi

    print_info "Clonando repositório de $GIT_REPO..."
    git clone "$GIT_REPO" "$INSTALL_DIR"
    
    cd "$INSTALL_DIR"

    if [ ! -f "install.sh" ]; then
        print_error "O script 'install.sh' não foi encontrado no repositório. Abortando."
        exit 1
    fi

    print_info "Executando o script de instalação principal (install.sh)..."
    chmod +x install.sh
    ./install.sh

    print_success "Nova instalação concluída com sucesso!"
}

function update_installation() {
    print_header "🔄 ATUALIZANDO APLICAÇÃO EXISTENTE"
    
    cd "$INSTALL_DIR"

    print_info "Forçando a sincronização com o repositório Git (descartando alterações locais)..."
    sudo -u "$APP_USER" git fetch origin
    sudo -u "$APP_USER" git reset --hard origin/main
    # The 'git clean' command was removed as it was too destructive for a standard update.

    # Ensure the virtual environment exists, recreating it if necessary.
    # This adds resilience to the script.
    if [ ! -f "venv/bin/activate" ]; then
        print_warning "Ambiente virtual não encontrado. Recriando..."
        sudo -u "$APP_USER" python3 -m venv venv
        print_success "Ambiente virtual recriado."
    fi
    
    print_info "Ativando ambiente virtual e atualizando dependências como '$APP_USER'..."
    # Executa a instalação de dependências dentro de um sub-shell como o usuário correto
    sudo -u "$APP_USER" bash -c "source venv/bin/activate && pip install -r requirements.txt"

    print_info "Reiniciando a aplicação via Supervisor..."
    supervisorctl restart sambaqui

    print_success "Aplicação atualizada com sucesso!"
    sleep 2
    supervisorctl status sambaqui
}

function reinstall_installation() {
    print_header "🔥 INICIANDO REINSTALAÇÃO COMPLETA"

    print_warning "Este script irá REMOVER COMPLETAMENTE a instalação atual."
    print_warning "Diretório a ser removido: $INSTALL_DIR"
    print_warning "Serviços (nginx, supervisor) serão reconfigurados."
    print_warning "O banco de dados será APAGADO."
    read -p "$(echo -e ${YELLOW}'Você tem certeza que deseja continuar? (s/n): '${NC})" CONFIRM
    if [[ "$CONFIRM" != "s" && "$CONFIRM" != "S" ]]; then
        print_info "Reinstalação cancelada."
        exit 0
    fi

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

    # 5. Executar uma nova instalação
    install_fresh
}

# ============================================================================
# LÓGICA PRINCIPAL
# ============================================================================

main() {
    print_header "Gerenciador de Instalação Remota - Sambaqui Tower House"

    # Verifica se é root
    if [[ $EUID -ne 0 ]]; then
       print_error "Este script deve ser executado como root (use: sudo ./install-remote.sh)"
       exit 1
    fi

    # Verifica se a instalação já existe
    if [ -d "$INSTALL_DIR" ]; then
        print_warning "Uma instalação existente foi encontrada em '$INSTALL_DIR'."
        echo ""
        print_info "O que você gostaria de fazer?"
        echo "  1) Atualizar a aplicação (puxar do Git e reiniciar)"
        echo "  2) Reinstalar completamente (apagar tudo e começar do zero)"
        echo "  3) Cancelar"
        echo ""
        read -p "$(echo -e ${YELLOW}'Escolha uma opção [1-3]: '${NC})" CHOICE

        case "$CHOICE" in
            1)
                update_installation
                ;;
            2)
                reinstall_installation
                ;;
            3)
                print_info "Operação cancelada."
                exit 0
                ;;
            *)
                print_error "Opção inválida. Abortando."
                exit 1
                ;;
        esac
    else
        print_info "Nenhuma instalação encontrada. Iniciando uma nova instalação..."
        install_fresh
    fi
}

# Executa a função principal
main

exit 0