#!/bin/bash

# ============================================================================
# 🚀 SCRIPT DE DEPLOY ESTÁTICO - SAMBAQUI TOWER HOUSE
# Instala e configura Nginx para servir o site estaticamente com SSL.
# ============================================================================

set -e

# --- CORES ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# --- FUNÇÕES DE PRINT ---
print_header() { echo -e "\n${BLUE}════════════════════════════════════════════════════════════${NC}\n${BLUE}$1${NC}\n${BLUE}════════════════════════════════════════════════════════════${NC}\n"; }
print_success() { echo -e "${GREEN}✓ $1${NC}"; }
print_error() { echo -e "${RED}✗ $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠ $1${NC}"; }
print_info() { echo -e "${BLUE}ℹ $1${NC}"; }

# --- VERIFICAÇÕES INICIAIS ---
print_header "🔍 VERIFICAÇÕES INICIAIS"

if [[ $EUID -ne 0 ]]; then
   print_error "Este script deve ser executado como root (use: sudo ./install-static.sh)"
   exit 1
fi

if ! command -v wget &> /dev/null; then
    print_info "Wget não encontrado. Instalando..."
    apt-get update -y && apt-get install -y wget
fi

# --- PERGUNTAS INTERATIVAS ---
print_header "❓ CONFIGURAÇÃO DO SITE"

read -p "$(echo -e ${YELLOW}'Qual o domínio do site? (ex: sambaqui.com.br): '${NC})" SERVER_HOST
if [ -z "$SERVER_HOST" ]; then
    print_error "O domínio é obrigatório."
    exit 1
fi

read -p "$(echo -e ${YELLOW}'Qual seu e-mail para o certificado SSL? (ex: dev@synapt.com.br): '${NC})" SSL_EMAIL
if [ -z "$SSL_EMAIL" ]; then
    print_error "O e-mail é obrigatório para o certificado SSL."
    exit 1
fi

INSTALL_DIR="/var/www/sambaqui_static"

# --- INSTALAÇÃO DE DEPENDÊNCIAS ---
print_header "📦 INSTALANDO NGINX E CERTBOT"

apt-get update -y
apt-get install -y nginx certbot python3-certbot-nginx
print_success "Dependências instaladas."

# --- CRIAÇÃO DA ESTRUTURA E DOWNLOADS ---
print_header "📁 PREPARANDO ARQUIVOS DO SITE"

# Verifica se os arquivos necessários estão presentes no pacote de deploy
if [ ! -f "index.html" ] || [ ! -d "images" ]; then
    print_error "Certifique-se de que 'index.html' e o diretório 'images/' estão no mesmo local que este script."
    exit 1
fi

mkdir -p "$INSTALL_DIR/static/uploads"
print_success "Diretório criado em $INSTALL_DIR"

print_info "Copiando imagens para o servidor..."
cp -r images/* "$INSTALL_DIR/static/uploads/"
print_success "Imagens copiadas."

print_info "Copiando index.html para o servidor..."
cp index.html "$INSTALL_DIR/index.html"
print_success "index.html copiado."

# --- CRIAÇÃO DO ARQUIVO HTML ---
# A seção de criação de HTML foi removida, pois o index.html agora é copiado diretamente.

# --- CONFIGURAÇÃO DO NGINX ---
print_header "🌐 CONFIGURANDO NGINX"

cat > /etc/nginx/sites-available/sambaqui-static << EOF
server {
    listen 80;
    server_name $SERVER_HOST;

    root $INSTALL_DIR;
    index index.html;

    location / {
        try_files \$uri \$uri/ =404;
    }

    location /static/ {
        alias $INSTALL_DIR/static/;
        expires 30d;
        add_header Cache-Control "public, immutable";
    }

    # Otimizações de performance
    gzip on;
    gzip_vary on;
    gzip_proxied any;
    gzip_comp_level 6;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;
}
EOF

ln -sf /etc/nginx/sites-available/sambaqui-static /etc/nginx/sites-enabled/

if nginx -t; then
    print_success "Configuração do Nginx é válida."
    systemctl restart nginx
    print_success "Nginx reiniciado."
else
    print_error "Configuração do Nginx inválida. Verifique os erros acima."
    exit 1
fi

# --- CONFIGURAÇÃO DO SSL ---
print_header "🔒 CONFIGURANDO SSL COM CERTBOT"

certbot --nginx -d "$SERVER_HOST" --agree-tos -m "$SSL_EMAIL" --non-interactive
print_success "Certificado SSL gerado e configurado."

# --- CONFIGURAÇÃO DO FIREWALL ---
print_header "🔥 CONFIGURANDO FIREWALL (UFW)"

if command -v ufw &> /dev/null; then
    ufw --force enable
    ufw allow 'Nginx Full'
    ufw allow 'OpenSSH'
    ufw status
    print_success "Firewall UFW configurado."
else
    print_warning "UFW não instalado. Configure o firewall manualmente se necessário."
fi

# --- PERMISSÕES FINAIS ---
print_header "🔐 AJUSTANDO PERMISSÕES"
chown -R www-data:www-data "$INSTALL_DIR"
chmod -R 755 "$INSTALL_DIR"
print_success "Permissões ajustadas."

# --- CONCLUSÃO ---
print_header "✅ DEPLOY ESTÁTICO CONCLUÍDO!"

echo -e "${GREEN}O site está no ar e servido estaticamente!${NC}"
echo -e "Acesse em: ${YELLOW}https://$SERVER_HOST${NC}"
echo ""
print_info "O Nginx está configurado para servir os arquivos de '$INSTALL_DIR'."
print_info "O certificado SSL será renovado automaticamente pelo Certbot."
echo ""

exit 0