"""
Modelos de banco de dados e inicialização
"""
from flask_sqlalchemy import SQLAlchemy
from datetime import datetime

db = SQLAlchemy()

class Pagina(db.Model):
    """Modelo para páginas do site"""
    __tablename__ = 'paginas'
    
    id = db.Column(db.Integer, primary_key=True)
    titulo = db.Column(db.String(255), nullable=False, unique=True)
    slug = db.Column(db.String(255), nullable=False, unique=True, index=True)
    conteudo = db.Column(db.Text, nullable=False)
    meta_descricao = db.Column(db.String(160))
    meta_keywords = db.Column(db.String(255))
    ativa = db.Column(db.Boolean, default=True)
    criada_em = db.Column(db.DateTime, default=datetime.utcnow)
    atualizada_em = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    def __repr__(self):
        return f'<Pagina {self.titulo}>'

class Secao(db.Model):
    """Modelo para seções de conteúdo"""
    __tablename__ = 'secoes'
    
    id = db.Column(db.Integer, primary_key=True)
    nome = db.Column(db.String(255), nullable=False)
    tipo = db.Column(db.String(50), nullable=False)  # hero, galeria, features, etc
    ordem = db.Column(db.Integer, default=0)
    dados_json = db.Column(db.JSON, default=dict)
    ativa = db.Column(db.Boolean, default=True)
    criada_em = db.Column(db.DateTime, default=datetime.utcnow)
    atualizada_em = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    def __repr__(self):
        return f'<Secao {self.nome}>'

class Imagem(db.Model):
    """Modelo para gerenciar imagens do site"""
    __tablename__ = 'imagens'
    
    id = db.Column(db.Integer, primary_key=True)
    nome_original = db.Column(db.String(255), nullable=False)
    caminho = db.Column(db.String(255), nullable=False, unique=True)
    tipo = db.Column(db.String(50))  # hero, galeria, thumbnail, etc
    titulo_alt = db.Column(db.String(255))
    descricao = db.Column(db.Text)
    tamanho = db.Column(db.Integer)  # em bytes
    criada_em = db.Column(db.DateTime, default=datetime.utcnow)
    
    def __repr__(self):
        return f'<Imagem {self.nome_original}>'

class Configuracao(db.Model):
    """Modelo para configurações do site"""
    __tablename__ = 'configuracoes'
    
    id = db.Column(db.Integer, primary_key=True)
    chave = db.Column(db.String(100), nullable=False, unique=True, index=True)
    valor = db.Column(db.Text, nullable=False)
    tipo = db.Column(db.String(50), default='string')  # string, int, bool, json
    descricao = db.Column(db.String(255))
    
    def __repr__(self):
        return f'<Config {self.chave}>'

class Log(db.Model):
    """Modelo para logs de atividades administrativas"""
    __tablename__ = 'logs'
    
    id = db.Column(db.Integer, primary_key=True)
    acao = db.Column(db.String(100), nullable=False)
    usuario = db.Column(db.String(100), nullable=False)
    descricao = db.Column(db.Text)
    ip_address = db.Column(db.String(45))
    criada_em = db.Column(db.DateTime, default=datetime.utcnow, index=True)
    
    def __repr__(self):
        return f'<Log {self.acao}>'

def init_db(app):
    """Inicializa o banco de dados"""
    with app.app_context():
        db.create_all()
        
        # Insere configurações padrão se não existirem
        if Configuracao.query.count() == 0:
            configs = [
                Configuracao(
                    chave='site_titulo',
                    valor='Sambaqui Tower House',
                    tipo='string',
                    descricao='Título principal do site'
                ),
                Configuracao(
                    chave='site_descricao',
                    valor='Empreendimento de alta qualidade em Guaratuba',
                    tipo='string',
                    descricao='Descrição meta do site'
                ),
                Configuracao(
                    chave='site_email',
                    valor='contato@sambaquitorhouse.com',
                    tipo='string',
                    descricao='Email de contato'
                ),
                Configuracao(
                    chave='site_telefone',
                    valor='+55 (41) XXXXX-XXXX',
                    tipo='string',
                    descricao='Telefone de contato'
                ),
                Configuracao(
                    chave='site_endereco',
                    valor='Avenida Atlântica, 1234, Guaratuba, PR, Brasil',
                    tipo='string',
                    descricao='Endereço completo do empreendimento para o mapa e localização'
                ),
                Configuracao(
                    chave='site_endereco_curto',
                    valor='Rua Mal. Floriano Peixoto, 483 · Centro',
                    tipo='string',
                    descricao='Endereço curto para exibição no hero e outros locais'
                ),
                Configuracao(
                    chave='seo_google_analytics',
                    valor='',
                    tipo='string',
                    descricao='ID Google Analytics'
                ),
            ]
            db.session.add_all(configs)
            db.session.commit()
        
        # Garante que o endereço do site exista mesmo em bases antigas
        if Configuracao.query.filter_by(chave='site_endereco').first() is None:
            db.session.add(Configuracao(
                chave='site_endereco',
                valor='Avenida Atlântica, 1234, Guaratuba, PR, Brasil',
                tipo='string',
                descricao='Endereço completo do empreendimento para o mapa e localização'
            ))
            db.session.commit()
        
        # Garante que o endereço curto do site exista
        if Configuracao.query.filter_by(chave='site_endereco_curto').first() is None:
            db.session.add(Configuracao(
                chave='site_endereco_curto',
                valor='Rua Mal. Floriano Peixoto, 483 · Centro',
                tipo='string',
                descricao='Endereço curto para exibição no hero e outros locais'
            ))
            db.session.commit()
        
        # Insere página inicial se não existir
        if Pagina.query.filter_by(slug='inicio').first() is None:
            inicio = Pagina(
                titulo='Página Inicial',
                slug='inicio',
                conteudo='<h1>Bem-vindo ao Sambaqui Tower House</h1>',
                meta_descricao='Empreendimento de alta qualidade em Guaratuba - Sambaqui Tower House',
                meta_keywords='imóvel, guaratuba, residencial, premium',
                ativa=True
            )
            db.session.add(inicio)
            db.session.commit()
