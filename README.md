# 🏢 Sambaqui Tower House - Plataforma Web

Um **MVP profissional** de landing page e painel administrativo para o empreendimento Sambaqui Tower House em Guaratuba, SC.

## ✨ Características

### 🎨 Frontend
- **Landing Page Premium**: Design elegante e responsivo
- **Mobile-First**: Otimizado para todos os dispositivos
- **Performance**: Otimização de imagens e carregamento rápido
- **SEO Otimizado**: Sitemap, Robots.txt e Meta tags

### 🔐 Administração
- **Painel Seguro**: Autenticação com credenciais
- **Gestão de Conteúdo**: Criar, editar e deletar páginas
- **Gerenciamento de Imagens**: Upload, otimização e organização
- **Configurações**: Personalize dados do site
- **Auditoria**: Registre todas as ações administrativas
- **SEO Tools**: Monitore e otimize SEO

### 💾 Banco de Dados
- **SQLite3**: Banco de dados leve e portável
- **Modelos Estruturados**: Páginas, Seções, Imagens, Configurações
- **Escalabilidade**: Pronto para PostgreSQL em produção

### 🚀 Deploy
- **Script Interativo**: `install.sh` para deploy automático em VPS
- **Supervisor**: Gerenciamento de processos
- **Nginx**: Reverse proxy e cache
- **SSL/TLS**: Suporte para HTTPS com Let's Encrypt
- **Backups**: Sistema automático de backup diário

## 🛠️ Stack Técnico

- **Framework**: Flask (Python)
- **Database**: SQLite3
- **ORM**: SQLAlchemy
- **Frontend**: HTML5, CSS3, JavaScript (Vanilla)
- **Server**: Gunicorn + Nginx
- **Process Manager**: Supervisor
- **SSL**: Let's Encrypt + Certbot

## 📋 Pré-requisitos

### Local (Desenvolvimento)
- Python 3.8+
- pip e virtualenv
- Git

### VPS (Produção)
- Linux (Ubuntu 20.04+ recomendado)
- Acesso root via SSH
- 2GB RAM mínimo
- 20GB espaço em disco

## 🚀 Instalação Rápida

### Desenvolvimento Local

```bash
# 1. Clone ou extraia o projeto
cd sambaqui

# 2. Crie virtual environment
python3 -m venv venv
source venv/bin/activate  # Linux/Mac
# ou
venv\Scripts\activate  # Windows

# 3. Instale dependências
pip install -r requirements.txt

# 4. Execute a aplicação
python app.py
```

Acesse em: **http://localhost:5000**

Painel Admin: **http://localhost:5000/admin/login**

### Deploy em VPS

```bash
# 1. Conecte na VPS
ssh root@seu.servidor.com

# 2. Clone o repositório
git clone https://seu-repo.git
cd sambaqui

# 3. Execute o script de instalação
sudo chmod +x install.sh
sudo ./install.sh

# 4. Responda às perguntas interativas
```

O script irá:
- ✓ Instalar dependências do sistema
- ✓ Configurar Python e virtualenv
- ✓ Inicializar banco de dados
- ✓ Configurar Supervisor (process manager)
- ✓ Configurar Nginx (reverse proxy)
- ✓ Gerar certificado SSL (opcional)
- ✓ Configurar Firewall
- ✓ Configurar Backups automáticos

## 📚 Documentação

### Estrutura do Projeto

```
sambaqui/
├── app.py                 # Aplicação Flask principal
├── config.py              # Configurações
├── database.py            # Modelos SQLAlchemy
├── auth.py                # Sistema de autenticação
├── requirements.txt       # Dependências Python
├── install.sh            # Script de deploy
├── .env.example          # Variáveis de ambiente
├── templates/            # Templates Jinja2
│   ├── base.html         # Template base
│   ├── index.html        # Landing page
│   ├── page.html         # Página genérica
│   └── admin/            # Templates administrativos
│       ├── login.html
│       ├── dashboard.html
│       ├── paginas.html
│       ├── imagens.html
│       ├── configuracoes.html
│       └── seo.html
├── static/               # Arquivos estáticos
│   └── uploads/          # Imagens carregadas
└── logs/                 # Arquivos de log
```

### Modelos de Banco de Dados

#### Pagina
```python
- id (int, PK)
- titulo (string)
- slug (string, unique)
- conteudo (text)
- meta_descricao (string)
- meta_keywords (string)
- ativa (bool)
- criada_em (datetime)
- atualizada_em (datetime)
```

#### Imagem
```python
- id (int, PK)
- nome_original (string)
- caminho (string, unique)
- tipo (string) # hero, galeria, thumbnail
- titulo_alt (string)
- descricao (text)
- tamanho (int)
- criada_em (datetime)
```

#### Configuracao
```python
- id (int, PK)
- chave (string, unique)
- valor (text)
- tipo (string) # string, int, bool, json
- descricao (string)
```

#### Log
```python
- id (int, PK)
- acao (string)
- usuario (string)
- descricao (text)
- ip_address (string)
- criada_em (datetime)
```

## 🔐 Autenticação

### Credenciais Padrão
- **Usuário**: `devsynapt`
- **Senha**: `synmod3030`

⚠️ **Altere a senha após o primeiro acesso!**

### Rotas Protegidas
- `/admin/` - Dashboard
- `/admin/paginas` - Gerenciar páginas
- `/admin/imagens` - Gerenciar imagens
- `/admin/configuracoes` - Configurações
- `/admin/seo` - Ferramentas de SEO

## 📊 SEO

### Recursos Inclusos
- ✓ Sitemap XML automático (`/sitemap.xml`)
- ✓ Robots.txt (`/robots.txt`)
- ✓ Meta tags em todas as páginas
- ✓ Alt text em imagens
- ✓ URLs amigáveis (slugs)
- ✓ Estrutura de cabeçalhos (H1, H2, etc)

### Próximas Implementações
- [ ] Integração Google Search Console
- [ ] Análise de palavras-chave
- [ ] Monitoramento de ranking
- [ ] Schema.org estruturado
- [ ] Otimização de velocidade

## 🔧 Configuração

### Arquivo .env

```bash
FLASK_ENV=production
FLASK_APP=app.py
SECRET_KEY=sua-chave-super-segura
PORT=5000
ADMIN_USERNAME=devsynapt
ADMIN_PASSWORD=synmod3030
```

### Variáveis de Ambiente em Produção

```bash
# Segurança
SECRET_KEY=$(python3 -c "import secrets; print(secrets.token_hex(32))")

# Banco de Dados
DATABASE_URL=postgresql://user:pass@localhost/sambaqui

# Email
SMTP_SERVER=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=seu-email@gmail.com
SMTP_PASSWORD=sua-senha

# Google Analytics
GOOGLE_ANALYTICS_ID=G-XXXXXXXXXX
```

## 📦 Deploy com Docker

```dockerfile
FROM python:3.11-slim

WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

CMD ["gunicorn", "-w", "4", "-b", "0.0.0.0:5000", "app:app"]
```

```bash
docker build -t sambaqui .
docker run -p 5000:5000 sambaqui
```

## 🔄 Backups

Backups automáticos são executados diariamente às 2 AM:

```bash
# Backup manual
/usr/local/bin/backup-sambaqui

# Restaurar backup
tar -xzf backups/sambaqui_TIMESTAMP.tar.gz
```

## 📊 Monitoramento

### Logs
```bash
# Logs da aplicação
tail -f /var/www/sambaqui/logs/gunicorn.log

# Logs Nginx
tail -f /var/log/nginx/error.log
tail -f /var/log/nginx/access.log

# Logs Supervisor
tail -f /var/log/supervisor/sambaqui.log
```

### Status
```bash
# Ver status da aplicação
supervisorctl status sambaqui

# Reiniciar aplicação
supervisorctl restart sambaqui

# Status Nginx
systemctl status nginx
```

## 🚨 Troubleshooting

### Porta Já em Uso
```bash
# Encontrar processo na porta
lsof -i :5000

# Matar processo
kill -9 <PID>
```

### Permissões
```bash
# Corrigir permissões
sudo chown -R www-data:www-data /var/www/sambaqui
sudo chmod -R 755 /var/www/sambaqui
sudo chmod -R 775 /var/www/sambaqui/static/uploads
```

### Resetar Banco de Dados
```bash
# Backup antes de resetar!
cp sambaqui.db sambaqui.db.backup

# Deletar database
rm sambaqui.db

# Reiniciar aplicação para recriar
supervisorctl restart sambaqui
```

## 🎯 Próximas Etapas

### MVP 2.0
- [ ] Integração com APIs de email
- [ ] Sistema de newsletter
- [ ] Formulários de contato avançados
- [ ] Galeria de fotos interativa
- [ ] Virtual tour 3D

### SEO & Marketing
- [ ] Integração Google Analytics 4
- [ ] Google Search Console
- [ ] Hotjar para análise de usuários
- [ ] Facebook Pixel
- [ ] LinkedIn Ads integration

### Performance
- [ ] Cache com Redis
- [ ] CDN para imagens
- [ ] Compressão de assets
- [ ] Lazy loading
- [ ] Service Workers

### Admin
- [ ] Relatórios avançados
- [ ] Exportação de dados (CSV, PDF)
- [ ] Agendamento de conteúdo
- [ ] Versioning de páginas
- [ ] Dark mode

## 📞 Suporte

Para suporte técnico:
- Email: admin@sambaquitorhouse.com
- Telefone: +55 (41) XXXXX-XXXX

## 📄 Licença

Propriedade exclusiva da Sambaqui Tower House. Todos os direitos reservados.

---

**Desenvolvido com ❤️ para o Sambaqui Tower House** | 2024-2026
