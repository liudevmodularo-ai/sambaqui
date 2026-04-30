# 🚀 GUIA RÁPIDO - SAMBAQUI TOWER HOUSE

## Começar Agora

### Desenvolvimento Local

```bash
# 1. Clonar/extrair projeto
cd sambaqui

# 2. Executar script de desenvolvimento
chmod +x run.sh
./run.sh

# 3. Acessar em http://localhost:5000
```

### Deploy em VPS (Linux)

```bash
# 1. Conectar à VPS
ssh root@seu.servidor.com

# 2. Copiar arquivo install.sh
scp install.sh root@seu.servidor.com:/root/

# 3. Executar
sudo chmod +x /root/install.sh
sudo /root/install.sh

# 4. Seguir instruções interativas
```

---

## 🔑 Credenciais Padrão

**URL de Admin**: `http://localhost:5000/admin/login`

- **Usuário**: `devsynapt`
- **Senha**: `synmod3030`

⚠️ Altere após primeiro login!

---

## 📋 O Que Está Incluído

### ✅ Completo e Pronto
- ✓ Landing page premium responsiva
- ✓ Painel administrativo seguro
- ✓ Gerenciamento de conteúdo (CRUD)
- ✓ Gerenciamento de imagens com otimização
- ✓ Configurações do site
- ✓ Auditoria de ações
- ✓ SEO básico (Sitemap, Robots.txt, Meta tags)
- ✓ Banco de dados SQLite3 estruturado
- ✓ Script de deploy automático para VPS
- ✓ Backup automático diário
- ✓ Suporte SSL/TLS (Let's Encrypt)
- ✓ Documentação completa

### 🔄 Próximos Passos (Para Implementar)

1. **SEO Avançado**
   - [ ] Integração Google Search Console
   - [ ] Análise de palavras-chave
   - [ ] Monitoramento de ranking
   - [ ] Schema.org estruturado

2. **Marketing & APIs**
   - [ ] Google Analytics 4
   - [ ] Facebook Pixel
   - [ ] Integração email (Mailgun/SendGrid)
   - [ ] API de busca otimizada
   - [ ] Scripts de indexação

3. **Features Administrativos**
   - [ ] Relatórios avançados
   - [ ] Exportação CSV/PDF
   - [ ] Agendamento de posts
   - [ ] Versionamento de páginas

4. **Performance**
   - [ ] Cache com Redis
   - [ ] CDN para imagens
   - [ ] Lazy loading
   - [ ] Service Workers

---

## 📁 Estrutura de Arquivos

```
sambaqui/
├── 📄 app.py              ← Aplicação principal
├── 📄 config.py           ← Configurações
├── 📄 database.py         ← Modelos do banco
├── 📄 auth.py             ← Sistema de autenticação
├── 📄 requirements.txt    ← Dependências Python
├── 🔧 install.sh          ← Deploy para VPS
├── 🔧 run.sh              ← Desenvolver localmente
├── 🐳 Dockerfile          ← Para Docker
├── 🐳 docker-compose.yml  ← Docker Compose
├── 📖 README.md           ← Documentação completa
├── 🔑 .env.example        ← Variáveis de ambiente
├── 🚫 .gitignore          ← Arquivos ignorados
├── templates/             ← Templates HTML
│   ├── base.html
│   ├── index.html         ← Landing page
│   ├── page.html          ← Página genérica
│   └── admin/             ← Painel administrativo
├── static/                ← Arquivos estáticos
│   └── uploads/           ← Imagens carregadas
├── logs/                  ← Arquivos de log
├── venv/                  ← Virtual environment (local)
└── sambaqui.db            ← Banco de dados SQLite

```

---

## 🛠️ Comandos Úteis

### Desenvolvimento

```bash
# Ativar venv (Linux/Mac)
source venv/bin/activate

# Ativar venv (Windows)
venv\Scripts\activate

# Instalar dependências
pip install -r requirements.txt

# Executar aplicação
python app.py

# Executar testes
python test_app.py

# Inicializar BD com exemplos
python init_db.py
```

### Produção (VPS)

```bash
# Ver status
supervisorctl status sambaqui

# Reiniciar
supervisorctl restart sambaqui

# Parar
supervisorctl stop sambaqui

# Iniciar
supervisorctl start sambaqui

# Ver logs
tail -f /var/www/sambaqui/logs/gunicorn.log

# Fazer backup
/usr/local/bin/backup-sambaqui
```

---

## 🔐 Segurança

### Checklist de Produção

- [ ] Alterar senha de admin (`devsynapt`)
- [ ] Gerar nova SECRET_KEY em .env
- [ ] Configurar HTTPS/SSL
- [ ] Habilitar firewall
- [ ] Configurar backups automáticos
- [ ] Monitorar logs regularmente
- [ ] Manter dependências atualizadas
- [ ] Configurar Google Analytics
- [ ] Testar links e funcionalidades

### Alternar Credenciais de Admin

1. Acesse o arquivo `config.py`
2. Localize as linhas:
   ```python
   ADMIN_USERNAME = 'devsynapt'
   ADMIN_PASSWORD = 'synmod3030'
   ```
3. Altere os valores
4. Reinicie a aplicação

---

## 📊 Banco de Dados

### Acessar Banco de Dados SQLite

```bash
# Conectar ao banco
sqlite3 sambaqui.db

# Ver todas as tabelas
.tables

# Ver estrutura de uma tabela
.schema paginas

# Consultar dados
SELECT * FROM paginas;

# Sair
.quit
```

### Backup e Restauração

```bash
# Backup manual
cp sambaqui.db sambaqui.db.backup

# Restaurar
cp sambaqui.db.backup sambaqui.db
```

---

## 🌐 URLs Importantes

### Públicas
- `http://localhost:5000/` - Landing page
- `http://localhost:5000/sitemap.xml` - Sitemap XML
- `http://localhost:5000/robots.txt` - Robots.txt
- `http://localhost:5000/page/<slug>` - Página genérica

### Administrativas
- `http://localhost:5000/admin/login` - Login
- `http://localhost:5000/admin/` - Dashboard
- `http://localhost:5000/admin/paginas` - Páginas
- `http://localhost:5000/admin/imagens` - Imagens
- `http://localhost:5000/admin/configuracoes` - Configurações
- `http://localhost:5000/admin/seo` - SEO Tools

---

## 🐛 Troubleshooting

### Porta 5000 já em uso

```bash
# Encontrar processo
lsof -i :5000

# Matar processo
kill -9 <PID>

# Usar outra porta
export PORT=8000
python app.py
```

### Erro de permissões

```bash
# Corrigir permissões em VPS
sudo chown -R www-data:www-data /var/www/sambaqui
sudo chmod -R 755 /var/www/sambaqui
```

### Banco de dados corrompido

```bash
# Backup
mv sambaqui.db sambaqui.db.corrupted

# Reiniciar app para recriar
# A aplicação criará novo banco automaticamente
```

### Nginx não carregando

```bash
# Testar configuração
sudo nginx -t

# Recarregar configuração
sudo nginx -s reload

# Reiniciar Nginx
sudo systemctl restart nginx
```

---

## 📞 Suporte

### Recursos

- 📖 [README.md](README.md) - Documentação completa
- 🧪 Script de testes: `python test_app.py`
- 🚀 Deploy guide: [install.sh](install.sh)

### Próximas Ações

1. Teste a aplicação localmente
2. Customize conteúdo e configurações
3. Execute o deploy em VPS
4. Configure SSL/TLS
5. Monitore performance
6. Implemente features adicionais conforme necessário

---

**Versão**: 1.0 MVP  
**Última atualização**: 2024-2026  
**Status**: ✅ Pronto para produção
