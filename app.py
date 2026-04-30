"""
Aplicação Flask - Sambaqui Tower House
MVP com painel administrativo, gerenciamento de conteúdo e SEO
"""
import os
import json
from functools import wraps
from flask import (Flask, render_template, request, session, redirect, 
                   url_for, jsonify, flash, send_from_directory)
from flask_sqlalchemy import SQLAlchemy
from datetime import datetime
from werkzeug.utils import secure_filename

from config import config
from database import db, init_db, Pagina, Secao, Imagem, Configuracao, Log
from auth import is_admin_logged_in, login_admin, require_admin, log_admin_action

# Inicializar aplicação
app = Flask(__name__)
environment = os.environ.get('FLASK_ENV', 'development')
app.config.from_object(config[environment])

# Inicializar banco de dados
db.init_app(app)

# Criar pastas necessárias
os.makedirs(app.config['UPLOAD_FOLDER'], exist_ok=True)

# ==================== FUNÇÕES AUXILIARES ====================

def get_client_ip():
    """Obtém IP do cliente"""
    if request.headers.get('X-Forwarded-For'):
        return request.headers.get('X-Forwarded-For').split(',')[0]
    return request.remote_addr

def get_all_configs():
    """Retorna todas as configurações como dicionário"""
    configs = Configuracao.query.all()
    return {c.chave: c.valor for c in configs}

# ==================== ROTAS PÚBLICAS ====================

@app.route('/')
def index():
    """Página inicial - Landing page"""
    config_dict = get_all_configs()
    return render_template('index.html', config=config_dict)

@app.route('/page/<slug>')
def view_page(slug):
    """Visualizar página específica"""
    page = Pagina.query.filter_by(slug=slug, ativa=True).first_or_404()
    config_dict = get_all_configs()
    return render_template('page.html', page=page, config=config_dict)

@app.route('/sitemap.xml')
def sitemap():
    """Sitemap XML para SEO"""
    base_url = request.host_url.rstrip('/')
    pages = Pagina.query.filter_by(ativa=True).all()
    
    sitemap_xml = '<?xml version="1.0" encoding="UTF-8"?>\n'
    sitemap_xml += '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">\n'
    sitemap_xml += f'  <url>\n    <loc>{base_url}/</loc>\n    <priority>1.0</priority>\n  </url>\n'
    
    for page in pages:
        sitemap_xml += f'  <url>\n    <loc>{base_url}/page/{page.slug}</loc>\n'
        sitemap_xml += f'    <lastmod>{page.atualizada_em.isoformat()}</lastmod>\n'
        sitemap_xml += f'    <priority>0.8</priority>\n  </url>\n'
    
    sitemap_xml += '</urlset>'
    return app.response_class(response=sitemap_xml, mimetype='application/xml')

@app.route('/robots.txt')
def robots():
    """Robots.txt para SEO"""
    robots_txt = f"""User-agent: *
Allow: /
Disallow: /admin/
Disallow: /login/

Sitemap: {request.host_url.rstrip('/')}/sitemap.xml
"""
    return app.response_class(response=robots_txt, mimetype='text/plain')

# ==================== ROTAS DE AUTENTICAÇÃO ADMIN ====================

@app.route('/admin/login', methods=['GET', 'POST'])
def admin_login():
    """Login administrativo (rota oculta)"""
    if request.method == 'POST':
        username = request.form.get('username')
        password = request.form.get('password')
        
        if login_admin(username, password):
            session['admin_logged_in'] = True
            session['admin_user'] = username
            session.permanent = True
            
            log_admin_action(db, username, 'LOGIN', 
                           'Login bem-sucedido', get_client_ip())
            
            flash('✓ Bem-vindo ao painel administrativo!', 'success')
            return redirect(url_for('admin_dashboard'))
        else:
            log_admin_action(db, username or 'desconhecido', 'LOGIN_FALHA', 
                           'Tentativa de login com credenciais inválidas', get_client_ip())
            flash('✗ Usuário ou senha inválidos', 'error')
    
    return render_template('admin/login.html')

@app.route('/admin/logout')
def admin_logout():
    """Logout administrativo"""
    username = session.get('admin_user', 'desconhecido')
    session.clear()
    log_admin_action(db, username, 'LOGOUT', 'Logout realizado')
    flash('Você foi desconectado.', 'info')
    return redirect(url_for('index'))

# ==================== ROTAS ADMINISTRATIVAS ====================

@app.route('/admin/')
@require_admin
def admin_dashboard():
    """Dashboard administrativo"""
    stats = {
        'total_paginas': Pagina.query.count(),
        'total_secoes': Secao.query.count(),
        'total_imagens': Imagem.query.count(),
        'total_logs': Log.query.count(),
    }
    
    recent_logs = Log.query.order_by(Log.criada_em.desc()).limit(10).all()
    return render_template('admin/dashboard.html', stats=stats, recent_logs=recent_logs)

# ---- Gerenciamento de Páginas ----

@app.route('/admin/paginas')
@require_admin
def admin_paginas():
    """Listar páginas"""
    paginas = Pagina.query.all()
    return render_template('admin/paginas.html', paginas=paginas)

@app.route('/admin/paginas/nova', methods=['GET', 'POST'])
@require_admin
def admin_pagina_nova():
    """Criar nova página"""
    if request.method == 'POST':
        titulo = request.form.get('titulo')
        conteudo = request.form.get('conteudo')
        meta_descricao = request.form.get('meta_descricao')
        meta_keywords = request.form.get('meta_keywords')
        
        # Gerar slug a partir do título
        import re
        slug = titulo.lower()
        slug = re.sub(r'[áàâã]', 'a', slug)
        slug = re.sub(r'[éèê]', 'e', slug)
        slug = re.sub(r'[íì]', 'i', slug)
        slug = re.sub(r'[óòôõ]', 'o', slug)
        slug = re.sub(r'[úù]', 'u', slug)
        slug = re.sub(r'[ç]', 'c', slug)
        slug = re.sub(r'\s+', '-', slug)
        slug = re.sub(r'[^a-z0-9-]', '', slug)
        slug = re.sub(r'-+', '-', slug).strip('-')
        
        if Pagina.query.filter_by(slug=slug).first():
            flash('✗ Uma página com este título já existe', 'error')
            return render_template('admin/pagina_form.html', edit=False)
        
        pagina = Pagina(
            titulo=titulo,
            slug=slug,
            conteudo=conteudo,
            meta_descricao=meta_descricao,
            meta_keywords=meta_keywords
        )
        
        db.session.add(pagina)
        db.session.commit()
        
        log_admin_action(db, session.get('admin_user'), 'PAGINA_CRIADA', 
                        f'Página criada: {titulo}', get_client_ip())
        
        flash(f'✓ Página "{titulo}" criada com sucesso!', 'success')
        return redirect(url_for('admin_paginas'))
    
    return render_template('admin/pagina_form.html', edit=False)

@app.route('/admin/paginas/<int:id>/editar', methods=['GET', 'POST'])
@require_admin
def admin_pagina_editar(id):
    """Editar página"""
    pagina = Pagina.query.get_or_404(id)
    
    if request.method == 'POST':
        pagina.titulo = request.form.get('titulo')
        pagina.conteudo = request.form.get('conteudo')
        pagina.meta_descricao = request.form.get('meta_descricao')
        pagina.meta_keywords = request.form.get('meta_keywords')
        pagina.ativa = request.form.get('ativa') == 'on'
        pagina.atualizada_em = datetime.utcnow()
        
        db.session.commit()
        
        log_admin_action(db, session.get('admin_user'), 'PAGINA_EDITADA', 
                        f'Página editada: {pagina.titulo}', get_client_ip())
        
        flash(f'✓ Página "{pagina.titulo}" atualizada!', 'success')
        return redirect(url_for('admin_paginas'))
    
    return render_template('admin/pagina_form.html', pagina=pagina, edit=True)

@app.route('/admin/paginas/<int:id>/deletar', methods=['POST'])
@require_admin
def admin_pagina_deletar(id):
    """Deletar página"""
    pagina = Pagina.query.get_or_404(id)
    titulo = pagina.titulo
    
    db.session.delete(pagina)
    db.session.commit()
    
    log_admin_action(db, session.get('admin_user'), 'PAGINA_DELETADA', 
                    f'Página deletada: {titulo}', get_client_ip())
    
    flash(f'✓ Página "{titulo}" removida!', 'success')
    return redirect(url_for('admin_paginas'))

# ---- Gerenciamento de Imagens ----

@app.route('/admin/imagens')
@require_admin
def admin_imagens():
    """Listar imagens"""
    imagens = Imagem.query.all()
    return render_template('admin/imagens.html', imagens=imagens)

@app.route('/admin/imagens/upload', methods=['POST'])
@require_admin
def admin_imagem_upload():
    """Upload de imagem"""
    if 'arquivo' not in request.files:
        return jsonify({'erro': 'Nenhum arquivo enviado'}), 400
    
    arquivo = request.files['arquivo']
    if arquivo.filename == '':
        return jsonify({'erro': 'Arquivo vazio'}), 400
    
    if arquivo and allowed_file(arquivo.filename):
        filename = secure_filename(arquivo.filename)
        timestamp = datetime.utcnow().strftime('%Y%m%d_%H%M%S_')
        filename = timestamp + filename
        
        caminho_completo = os.path.join(app.config['UPLOAD_FOLDER'], filename)
        arquivo.save(caminho_completo)
        
        # Otimizar imagem com Pillow
        try:
            from PIL import Image
            img = Image.open(caminho_completo)
            img.thumbnail((1920, 1080))
            img.save(caminho_completo, quality=85, optimize=True)
        except:
            pass
        
        tamanho = os.path.getsize(caminho_completo)
        
        imagem = Imagem(
            nome_original=request.files['arquivo'].filename,
            caminho=f'/static/uploads/{filename}',
            tipo=request.form.get('tipo', 'galeria'),
            titulo_alt=request.form.get('titulo_alt', ''),
            descricao=request.form.get('descricao', ''),
            tamanho=tamanho
        )
        
        db.session.add(imagem)
        db.session.commit()
        
        log_admin_action(db, session.get('admin_user'), 'IMAGEM_UPLOAD', 
                        f'Imagem enviada: {filename}', get_client_ip())
        
        return jsonify({
            'sucesso': True,
            'imagem_id': imagem.id,
            'caminho': imagem.caminho,
            'mensagem': 'Imagem enviada com sucesso!'
        })
    
    return jsonify({'erro': 'Tipo de arquivo não permitido'}), 400

@app.route('/admin/imagens/<int:id>/deletar', methods=['POST'])
@require_admin
def admin_imagem_deletar(id):
    """Deletar imagem"""
    imagem = Imagem.query.get_or_404(id)
    
    try:
        caminho_arquivo = os.path.join('static', imagem.caminho.lstrip('/'))
        if os.path.exists(caminho_arquivo):
            os.remove(caminho_arquivo)
    except:
        pass
    
    db.session.delete(imagem)
    db.session.commit()
    
    log_admin_action(db, session.get('admin_user'), 'IMAGEM_DELETADA', 
                    f'Imagem deletada: {imagem.nome_original}', get_client_ip())
    
    flash('✓ Imagem removida!', 'success')
    return redirect(url_for('admin_imagens'))

# ---- Gerenciamento de Configurações ----

@app.route('/admin/configuracoes')
@require_admin
def admin_configuracoes():
    """Editar configurações do site"""
    configuracoes = Configuracao.query.all()
    return render_template('admin/configuracoes.html', configuracoes=configuracoes)

@app.route('/admin/configuracoes/<int:id>/salvar', methods=['POST'])
@require_admin
def admin_config_salvar(id):
    """Salvar configuração"""
    config = Configuracao.query.get_or_404(id)
    valor = request.form.get('valor')
    
    config.valor = valor
    db.session.commit()
    
    log_admin_action(db, session.get('admin_user'), 'CONFIG_ALTERADA', 
                    f'Configuração alterada: {config.chave}', get_client_ip())
    
    flash(f'✓ Configuração "{config.chave}" salva!', 'success')
    return redirect(url_for('admin_configuracoes'))

# ---- Gerenciamento de SEO ----

@app.route('/admin/seo')
@require_admin
def admin_seo():
    """Painel de SEO e otimizações"""
    stats = {
        'total_paginas': Pagina.query.count(),
        'paginas_com_meta': Pagina.query.filter(Pagina.meta_descricao != '').count(),
        'total_imagens': Imagem.query.count(),
        'imagens_com_alt': Imagem.query.filter(Imagem.titulo_alt != '').count(),
    }
    return render_template('admin/seo.html', stats=stats)

# ---- API Endpoints ----

@app.route('/contact-submit', methods=['POST'])
def contact_submit():
    """Endpoint para formulário de contato AJAX"""
    email = request.form.get('email')
    if not email:
        return jsonify({'sucesso': False, 'mensagem': 'O e-mail é obrigatório.'}), 400
    
    # Aqui você adicionaria a lógica para salvar no banco ou enviar um e-mail
    print(f"Novo lead recebido: {email}")
    
    return jsonify({'sucesso': True, 'mensagem': 'Obrigado! Entraremos em contato em breve.'})

# ==================== ROTAS DE ARQUIVOS ====================

@app.route('/static/uploads/<filename>')
def serve_upload(filename):
    """Servir arquivos upload"""
    return send_from_directory(app.config['UPLOAD_FOLDER'], filename)

# ==================== FUNÇÕES AUXILIARES ====================

ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg', 'gif', 'webp', 'svg'}

def allowed_file(filename):
    """Verifica se extensão é permitida"""
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

# ==================== TRATAMENTO DE ERROS ====================

@app.errorhandler(404)
def not_found(error):
    """Página não encontrada"""
    return render_template('errors/404.html'), 404

@app.errorhandler(500)
def server_error(error):
    """Erro interno do servidor"""
    return render_template('errors/500.html'), 500

# ==================== CONTEXTO PARA TEMPLATES ====================

@app.context_processor
def inject_config():
    """Injeta configurações em todos os templates"""
    return dict(
        config=get_all_configs(),
        admin_logged_in=is_admin_logged_in(),
        admin_user=session.get('admin_user')
    )

# ==================== INICIALIZAÇÃO ====================

if __name__ == '__main__':
    with app.app_context():
        init_db(app)
    
    app.run(
        host='0.0.0.0',
        port=int(os.environ.get('PORT', 5000)),
        debug=app.config['DEBUG']
    )
