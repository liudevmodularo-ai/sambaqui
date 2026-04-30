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

mkdir -p "$INSTALL_DIR/static/uploads"
print_success "Diretório criado em $INSTALL_DIR"

image_map=(
    "https://dbvebtn3wsif3.cloudfront.net/foto/3591/3591/v-15/imoveis/1473925/23511843/4.jpg gallery_01.jpg"
    "https://dbvebtn3wsif3.cloudfront.net/foto/3591/3591/v-15/imoveis/1473925/23511844/4.jpg gallery_02.jpg"
    "https://dbvebtn3wsif3.cloudfront.net/foto/3591/3591/v-15/imoveis/1473925/23511846/4.jpg gallery_03.jpg"
    "https://dbvebtn3wsif3.cloudfront.net/foto/3591/3591/v-15/imoveis/1473925/23511847/4.jpg gallery_04.jpg"
    "https://dbvebtn3wsif3.cloudfront.net/foto/3591/3591/v-15/imoveis/1473925/23511848/4.jpg gallery_05.jpg"
    "https://dbvebtn3wsif3.cloudfront.net/foto/3591/3591/v-15/imoveis/1473925/23511849/4.jpg gallery_06.jpg"
    "https://dbvebtn3wsif3.cloudfront.net/foto/3591/3591/v-15/imoveis/1473925/23511850/4.jpg gallery_07.jpg"
    "https://dbvebtn3wsif3.cloudfront.net/foto/3591/3591/v-15/imoveis/1473925/23511845/4.jpg gallery_08.jpg"
    "https://dbvebtn3wsif3.cloudfront.net/foto/3591/3591/v-15/imoveis/1473925/23511851/4.jpg gallery_09.jpg"
    "https://dbvebtn3wsif3.cloudfront.net/foto/3591/3591/v-15/imoveis/1473925/23511852/4.jpg gallery_10.jpg"
    "https://dbvebtn3wsif3.cloudfront.net/foto/3591/3591/v-15/imoveis/1473925/23511854/4.jpg gallery_11.jpg"
    "https://dbvebtn3wsif3.cloudfront.net/foto/3591/3591/v-15/imoveis/1473925/23511840/4.jpg gallery_12.jpg"
    "https://dbvebtn3wsif3.cloudfront.net/foto/3591/3591/v-15/imoveis/1473925/23511841/4.jpg gallery_13.jpg"
    "https://dbvebtn3wsif3.cloudfront.net/foto/3591/3591/v-15/imoveis/1473925/23511842/4.jpg gallery_14.jpg"
    "https://dbvebtn3wsif3.cloudfront.net/foto/3591/3591/v-15/imoveis/1473925/23511853/4.jpg gallery_15.jpg"
    "https://dbvebtn3wsif3.cloudfront.net/foto/3591/3591/v-15/imoveis/1473925/24819900/4.jpg gallery_16.jpg"
)

print_info "Baixando imagens..."
for item in "${image_map[@]}"; do
    read -r url filename <<< "$item"
    if [ ! -f "$INSTALL_DIR/static/uploads/$filename" ]; then
        wget -q -O "$INSTALL_DIR/static/uploads/$filename" "$url"
        echo "  - Baixado: $filename"
    else
        echo "  - Já existe: $filename"
    fi
done
print_success "Download de imagens concluído."

# --- CRIAÇÃO DO ARQUIVO HTML ---
print_info "Gerando arquivo index.html..."

# Copia o conteúdo do arquivo index.html local para a VPS
# Certifique-se de que este script e o index.html estão no mesmo diretório ao copiar para a VPS
if [ -f "index.html" ]; then
    # Substitui os caminhos das imagens para serem relativos ao servidor estático
    sed -e "s|https://dbvebtn3wsif3.cloudfront.net/foto/3591/3591/v-15/imoveis/1473925/23511843/4.jpg|/static/uploads/gallery_01.jpg|g" \
        -e "s|https://dbvebtn3wsif3.cloudfront.net/foto/3591/3591/v-15/imoveis/1473925/23511844/4.jpg|/static/uploads/gallery_02.jpg|g" \
        -e "s|https://dbvebtn3wsif3.cloudfront.net/foto/3591/3591/v-15/imoveis/1473925/23511846/4.jpg|/static/uploads/gallery_03.jpg|g" \
        -e "s|https://dbvebtn3wsif3.cloudfront.net/foto/3591/3591/v-15/imoveis/1473925/23511847/4.jpg|/static/uploads/gallery_04.jpg|g" \
        -e "s|https://dbvebtn3wsif3.cloudfront.net/foto/3591/3591/v-15/imoveis/1473925/23511848/4.jpg|/static/uploads/gallery_05.jpg|g" \
        -e "s|https://dbvebtn3wsif3.cloudfront.net/foto/3591/3591/v-15/imoveis/1473925/23511849/4.jpg|/static/uploads/gallery_06.jpg|g" \
        -e "s|https://dbvebtn3wsif3.cloudfront.net/foto/3591/3591/v-15/imoveis/1473925/23511850/4.jpg|/static/uploads/gallery_07.jpg|g" \
        -e "s|https://dbvebtn3wsif3.cloudfront.net/foto/3591/3591/v-15/imoveis/1473925/23511845/4.jpg|/static/uploads/gallery_08.jpg|g" \
        -e "s|https://dbvebtn3wsif3.cloudfront.net/foto/3591/3591/v-15/imoveis/1473925/23511851/4.jpg|/static/uploads/gallery_09.jpg|g" \
        -e "s|https://dbvebtn3wsif3.cloudfront.net/foto/3591/3591/v-15/imoveis/1473925/23511852/4.jpg|/static/uploads/gallery_10.jpg|g" \
        -e "s|https://dbvebtn3wsif3.cloudfront.net/foto/3591/3591/v-15/imoveis/1473925/23511854/4.jpg|/static/uploads/gallery_11.jpg|g" \
        -e "s|https://dbvebtn3wsif3.cloudfront.net/foto/3591/3591/v-15/imoveis/1473925/23511840/4.jpg|/static/uploads/gallery_12.jpg|g" \
        -e "s|https://dbvebtn3wsif3.cloudfront.net/foto/3591/3591/v-15/imoveis/1473925/23511841/4.jpg|/static/uploads/gallery_13.jpg|g" \
        -e "s|https://dbvebtn3wsif3.cloudfront.net/foto/3591/3591/v-15/imoveis/1473925/23511842/4.jpg|/static/uploads/gallery_14.jpg|g" \
        -e "s|https://dbvebtn3wsif3.cloudfront.net/foto/3591/3591/v-15/imoveis/1473925/23511853/4.jpg|/static/uploads/gallery_15.jpg|g" \
        -e "s|https://dbvebtn3wsif3.cloudfront.net/foto/3591/3591/v-15/imoveis/1473925/24819900/4.jpg|/static/uploads/gallery_16.jpg|g" \
        index.html > "$INSTALL_DIR/index.html"
    print_success "Arquivo index.html criado e caminhos de imagem atualizados."
else
    print_error "Arquivo 'index.html' não encontrado no diretório atual. Abortando."
    exit 1
fi

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