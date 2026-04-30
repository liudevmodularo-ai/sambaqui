#!/bin/bash

# Script de desenvolvimento local - Sambaqui Tower House

# Cores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🚀 Iniciando Sambaqui Tower House (Desenvolvimento)${NC}\n"

# Verificar virtual environment
if [ ! -d "venv" ]; then
    echo "Criando virtual environment..."
    python3 -m venv venv
fi

# Ativar venv
source venv/bin/activate

# Instalar dependências se necessário
if [ ! -f "requirements.txt" ]; then
    echo "❌ requirements.txt não encontrado!"
    exit 1
fi

pip install -q -r requirements.txt 2>/dev/null

# Criar .env se não existir
if [ ! -f ".env" ]; then
    echo "Criando arquivo .env..."
    cp .env.example .env 2>/dev/null || cat > .env << 'EOF'
FLASK_ENV=development
FLASK_APP=app.py
SECRET_KEY=dev-key-change-in-production
PORT=5000
EOF
fi

# Executar aplicação
echo -e "${GREEN}✓ Tudo pronto!${NC}\n"
echo "🌐 Acessar: http://localhost:5000"
echo "🔐 Admin: http://localhost:5000/admin/login"
echo "   Usuário: devsynapt"
echo "   Senha: synmod3030"
echo ""
echo "Pressione Ctrl+C para parar\n"

python3 app.py
