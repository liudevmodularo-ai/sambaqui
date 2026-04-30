#!/bin/bash

# ============================================================================
# 🚀 SCRIPT DE INSTALAÇÃO - SAMBAQUI TOWER HOUSE
# Deploy Interativo para VPS
# ============================================================================

set -e

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ============================================================================
# FUNCTIONS
# ============================================================================

print_header() {
    echo -e "\n${BLUE}════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}\n"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

# ============================================================================
# VERIFICAÇÕES INICIAIS
# ============================================================================

print_header "🔍 VERIFICAÇÕES DE SISTEMA"

# Verifica sistema operacional
if [[ "$OSTYPE" != "linux-gnu"* ]]; then
    print_warning "Este script foi testado em Linux. Alguns comandos podem não funcionar."
fi

# Verifica se é root
if [[ $EUID -ne 0 ]]; then
   print_error "Este script deve ser executado como root (use: sudo ./install.sh)"
   exit 1
fi

# Verifica Python
if ! command -v python3 &> /dev/null; then
    print_error "Python 3 não encontrado. Instalando..."
    apt-get update
    apt-get install -y python3 python3-pip
else
    PYTHON_VERSION=$(python3 --version)
    print_success "Python encontrado: $PYTHON_VERSION"
fi

# Verifica pip
if ! command -v pip3 &> /dev/null; then
    print_error "pip3 não encontrado. Instalando..."
    apt-get install -y python3-pip
else
    print_success "pip3 encontrado"
fi

# Verifica git
if ! command -v git &> /dev/null; then
    print_warning "Git não encontrado. Instalando..."
    apt-get install -y git
else
    print_success "Git encontrado"
fi

# ============================================================================
# PERGUNTAS INTERATIVAS
# ============================================================================

print_header "❓ CONFIGURAÇÃO DE DEPLOY"

if [ -f ".env" ]; then
    print_info "Arquivo .env encontrado. Carregando configurações..."
    set -o allexport
    source .env
    set +o allexport
    
    # Usar valores do .env ou defaults
    INSTALL_DIR=${INSTALL_DIR:-/var/www/sambaqui}
    APP_USER=${APP_USER:-www-data}
    APP_PORT=${APP_PORT:-5000}
    SERVER_HOST=${SERVER_HOST:-localhost}
    USE_HTTPS=${USE_HTTPS:-n}
    SSL_EMAIL=${SSL_EMAIL:-""}
    GIT_REPO=${GIT_REPO:-""}
else
    print_warning "Arquivo .env não encontrado. Usando modo interativo."
    read -p "$(echo -e ${YELLOW}'Diretório de instalação (default: /var/www/sambaqui): '${NC})" INSTALL_DIR
    INSTALL_DIR=${INSTALL_DIR:-/var/www/sambaqui}
    read -p "$(echo -e ${YELLOW}'Usuário do sistema (default: www-data): '${NC})" APP_USER
    APP_USER=${APP_USER:-www-data}
    read -p "$(echo -e ${YELLOW}'Porta da aplicação (default: 5000): '${NC})" APP_PORT
    APP_PORT=${APP_PORT:-5000}
    read -p "$(echo -e ${YELLOW}'Domínio/IP do servidor (ex: example.com): '${NC})" SERVER_HOST
    read -p "$(echo -e ${YELLOW}'Usar HTTPS? (s/n, default: n): '${NC})" USE_HTTPS
    [ "$USE_HTTPS" = "s" ] && read -p "$(echo -e ${YELLOW}'Email para SSL (ex: dev@synapt.com.br): '${NC})" SSL_EMAIL
fi

# ============================================================================
# INSTALAÇÃO DE DEPENDÊNCIAS DO SISTEMA
# ============================================================================

print_header "📦 INSTALANDO DEPENDÊNCIAS DO SISTEMA"

apt-get update
apt-get install -y \
    build-essential \
    libssl-dev \
    libffi-dev \
    python3-dev \
    git \
    curl \
    wget \
    supervisor \
    nginx

print_success "Dependências do sistema instaladas"

# ============================================================================
# CRIAÇÃO DE ESTRUTURA DE DIRETÓRIOS
# ============================================================================

print_header "📁 CRIANDO ESTRUTURA DE DIRETÓRIOS"

mkdir -p "$INSTALL_DIR"
mkdir -p "$INSTALL_DIR/logs"
mkdir -p "$INSTALL_DIR/static/uploads"
mkdir -p "$INSTALL_DIR/venv"

print_success "Diretórios criados em $INSTALL_DIR"

# ============================================================================
# CLONE DO REPOSITÓRIO (OU CÓPIA DE ARQUIVOS)
# ============================================================================

print_header "📥 PREPARANDO ARQUIVOS DA APLICAÇÃO"

# Se GIT_REPO está definido, clona. Senão, copia.
if [ -n "$GIT_REPO" ]; then
    print_info "Clonando repositório de $GIT_REPO..."
    git clone "$GIT_REPO" "$INSTALL_DIR"
else
    print_info "Copiando arquivos do diretório atual..."
    cp -r ./* "$INSTALL_DIR/" 2>/dev/null || true
fi

# ============================================================================
# VIRTUAL ENVIRONMENT E DEPENDENCIES
# ============================================================================

print_header "🐍 CONFIGURANDO AMBIENTE PYTHON"

cd "$INSTALL_DIR"

# Criar venv
python3 -m venv venv
print_success "Virtual environment criado"

# Ativar venv
source venv/bin/activate

# Instalar dependências
if [ -f "requirements.txt" ]; then
    print_info "Instalando dependências Python..."
    pip install --upgrade pip setuptools wheel
    pip install -r requirements.txt
    print_success "Dependências Python instaladas"
else
    print_warning "requirements.txt não encontrado"
fi

# ============================================================================
# BANCO DE DADOS
# ============================================================================

print_header "💾 INICIALIZANDO BANCO DE DADOS"

python3 << EOF
import sys
sys.path.insert(0, '.')
from app import app, db
from database import init_db

with app.app_context():
    init_db(app)
    print("✓ Banco de dados inicializado")
EOF

print_success "Banco de dados criado e inicializado"

# ============================================================================
# PERMISSÕES
# ============================================================================

print_header "🔐 CONFIGURANDO PERMISSÕES"

# Criar usuário se não existir
if ! id "$APP_USER" &>/dev/null; then
    useradd -r -s /bin/bash "$APP_USER"
    print_success "Usuário $APP_USER criado"
else
    print_info "Usuário $APP_USER já existe"
fi

# Definir proprietário
chown -R "$APP_USER:$APP_USER" "$INSTALL_DIR"
chmod -R 755 "$INSTALL_DIR"
chmod -R 775 "$INSTALL_DIR/static/uploads"
chmod -R 775 "$INSTALL_DIR/logs"

print_success "Permissões configuradas"

# ============================================================================
# ARQUIVO .ENV
# ============================================================================

print_header "🔑 CRIANDO ARQUIVO DE CONFIGURAÇÃO"

cat > "$INSTALL_DIR/.env" << EOF
FLASK_ENV=production
FLASK_APP=app.py
SECRET_KEY=$(python3 -c "import secrets; print(secrets.token_hex(32))")
PORT=$APP_PORT
EOF

chown "$APP_USER:$APP_USER" "$INSTALL_DIR/.env"
chmod 600 "$INSTALL_DIR/.env"

print_success "Arquivo .env criado (permissões: 600)"

# ============================================================================
# SUPERVISOR (Process Manager)
# ============================================================================

print_header "⚙️ CONFIGURANDO SUPERVISOR"

cat > /etc/supervisor/conf.d/sambaqui.conf << EOF
[program:sambaqui]
directory=$INSTALL_DIR
command=$INSTALL_DIR/venv/bin/gunicorn -w 4 -b 127.0.0.1:$APP_PORT app:app
user=$APP_USER
autostart=true
autorestart=true
redirect_stderr=true
stdout_logfile=$INSTALL_DIR/logs/gunicorn.log
environment=PATH="$INSTALL_DIR/venv/bin"
EOF

supervisorctl reread
supervisorctl update
supervisorctl start sambaqui

print_success "Supervisor configurado e aplicação iniciada"

# ============================================================================
# NGINX (Reverse Proxy)
# ============================================================================

print_header "🌐 CONFIGURANDO NGINX"

cat > /etc/nginx/sites-available/sambaqui << 'EOF'
server {
    listen 80;
    server_name _;

    client_max_body_size 16M;

    location / {
        proxy_pass http://127.0.0.1:__PORT__;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # Timeouts
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }

    location /static/ {
        alias __INSTALL_DIR__/static/;
        expires 30d;
        add_header Cache-Control "public, immutable";
    }
}
EOF

# Substituir placeholders
sed -i "s|__PORT__|$APP_PORT|g" /etc/nginx/sites-available/sambaqui
sed -i "s|__INSTALL_DIR__|$INSTALL_DIR|g" /etc/nginx/sites-available/sambaqui

# Ativar site
ln -sf /etc/nginx/sites-available/sambaqui /etc/nginx/sites-enabled/sambaqui 2>/dev/null || true

# Teste de configuração
nginx -t

# Reiniciar Nginx
systemctl restart nginx

print_success "Nginx configurado e reiniciado"

# ============================================================================
# CERTIFICADO SSL (OPCIONAL)
# ============================================================================

if [ "$USE_HTTPS" = "s" ] || [ "$USE_HTTPS" = "S" ]; then
    print_header "🔒 CONFIGURANDO SSL/TLS (LetsEncrypt)"
    
    # Instalar Certbot
    apt-get install -y certbot python3-certbot-nginx
    
    # Verificar porta 80
    if ss -ltnp | grep -q ':80'; then
        print_warning "A porta 80 já está em uso. Certbot não poderá validar o domínio com standalone."
        print_warning "Se você quiser HTTPS, pare o serviço atual que usa a porta 80 e execute o script novamente."
    else
        print_info "Gerando certificado SSL para $SERVER_HOST..."
        if certbot --nginx -d "$SERVER_HOST" --agree-tos -m "$SSL_EMAIL" --non-interactive; then
            print_success "Certificado gerado com sucesso"
            
            # O Certbot já deve ter modificado o arquivo do Nginx. Vamos garantir que está correto.
            cat > /etc/nginx/sites-available/sambaqui << EOF
server {
    listen 80;
    server_name $SERVER_HOST;
    return 301 https://\$server_name\$request_uri;
}

server {
    listen 443 ssl http2;
    server_name $SERVER_HOST;

    ssl_certificate /etc/letsencrypt/live/$SERVER_HOST/fullchain.pem; # managed by Certbot
    ssl_certificate_key /etc/letsencrypt/live/$SERVER_HOST/privkey.pem; # managed by Certbot

    client_max_body_size 16M;

    location / {
        proxy_pass http://127.0.0.1:$APP_PORT;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }

    location /static/ {
        alias $INSTALL_DIR/static/;
        expires 30d;
    }
}
EOF
            
            nginx -t
            systemctl restart nginx
            print_success "SSL/TLS configurado"
        else
            print_error "Falha ao gerar certificado SSL. Verifique os logs do Certbot. Mantendo configuração HTTP."
            systemctl start nginx || true
        fi
    fi
fi

# ============================================================================
# FIREWALL
# ============================================================================

print_header "🔥 CONFIGURANDO FIREWALL"

if command -v ufw &> /dev/null; then
    ufw --force enable
    ufw default deny incoming
    ufw default allow outgoing
    ufw allow 22/tcp
    ufw allow 80/tcp
    ufw allow 443/tcp
    print_success "Firewall UFW configurado"
else
    print_warning "UFW não instalado. Configure o firewall manualmente se necessário."
fi

# ============================================================================
# BACKUPS
# ============================================================================

print_header "💾 CONFIGURANDO BACKUPS"

cat > /usr/local/bin/backup-sambaqui << EOF
#!/bin/bash
BACKUP_DIR="$INSTALL_DIR/backups"
mkdir -p \$BACKUP_DIR
TIMESTAMP=\$(date +%Y%m%d_%H%M%S)
tar -czf \$BACKUP_DIR/sambaqui_\$TIMESTAMP.tar.gz -C "$INSTALL_DIR" . --exclude='venv' --exclude='.git' --exclude='*.pyc'
find \$BACKUP_DIR -name "*.tar.gz" -mtime +30 -delete
EOF

chmod +x /usr/local/bin/backup-sambaqui

# Adicionar ao cron (backup diário às 2 AM)
(crontab -u root -l 2>/dev/null | grep -v backup-sambaqui || true; echo "0 2 * * * /usr/local/bin/backup-sambaqui") | crontab -u root -

print_success "Backups configurados (diariamente às 2 AM)"

# ============================================================================
# MONITORAMENTO
# ============================================================================

print_header "📊 INFORMAÇÕES DE MONITORAMENTO"

print_info "Para visualizar logs da aplicação:"
echo "  tail -f $INSTALL_DIR/logs/gunicorn.log"

print_info "Para reiniciar a aplicação:"
echo "  supervisorctl restart sambaqui"

print_info "Para parar a aplicação:"
echo "  supervisorctl stop sambaqui"

print_info "Para ver status:"
echo "  supervisorctl status"

# ============================================================================
# RESUMO FINAL
# ============================================================================

print_header "✅ INSTALAÇÃO CONCLUÍDA COM SUCESSO!"

echo -e "${GREEN}Resumo da Instalação:${NC}"
echo "  📁 Diretório: $INSTALL_DIR"
echo "  👤 Usuário: $APP_USER"
echo "  🌐 Servidor: $SERVER_HOST"
echo "  🔌 Porta Interna: $APP_PORT"
echo "  🔒 HTTPS: $([ "$USE_HTTPS" = "s" ] || [ "$USE_HTTPS" = "S" ] && echo 'Habilitado' || echo 'Desabilitado')"

echo -e "\n${GREEN}Acessar aplicação:${NC}"
if [ "$USE_HTTPS" = "s" ] || [ "$USE_HTTPS" = "S" ]; then
    echo "  🔒 https://$SERVER_HOST"
else
    echo "  🌐 http://$SERVER_HOST"
fi

echo -e "\n${GREEN}Login de Administração:${NC}"
echo "  🔐 URL: http://$SERVER_HOST/admin/login"
echo "  👤 Usuário: devsynapt"
echo "  🔑 Senha: synmod3030"

echo -e "\n${YELLOW}⚠️  LEMBRE-SE:${NC}"
echo "  • Altere a senha de administração após o primeiro acesso"
echo "  • Configure o SECRET_KEY em .env para produção"
echo "  • Mantenha backups regulares"
echo "  • Monitore os logs regularmente"
echo "  • Configure SSL/TLS em produção"

echo -e "\n${GREEN}📚 Documentação:${NC}"
echo "  • Arquivo de configuração: $INSTALL_DIR/.env"
echo "  • Arquivo de supervisor: /etc/supervisor/conf.d/sambaqui.conf"
echo "  • Arquivo Nginx: /etc/nginx/sites-available/sambaqui"

echo -e "\n${BLUE}════════════════════════════════════════════════════════════${NC}\n"
