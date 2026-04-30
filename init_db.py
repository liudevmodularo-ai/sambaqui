#!/usr/bin/env python3
"""
Script de inicialização do banco de dados com dados de exemplo
Uso: python init_db.py
"""

from app import app, db
from database import init_db, Pagina, Secao, Imagem, Configuracao

def create_sample_data():
    """Cria dados de exemplo"""
    with app.app_context():
        print("🔄 Inicializando banco de dados...")
        
        # Inicializar estrutura
        init_db(app)
        
        print("✓ Banco de dados criado/atualizado")
        print("✓ Configurações padrão inseridas")
        
        # Inserir página de exemplo
        about = Pagina.query.filter_by(slug='sobre').first()
        if not about:
            about = Pagina(
                titulo='Sobre o Sambaqui Tower House',
                slug='sobre',
                conteudo='''
<h2>Bem-vindo ao Sambaqui Tower House</h2>
<p>
    O Sambaqui Tower House é um empreendimento residencial de alta qualidade 
    localizado em Guaratuba, Santa Catarina. Com arquitetura moderna e acabamentos 
    premium, oferecemos mais que um imóvel - uma experiência de vida sofisticada.
</p>
<h3>Nossa Visão</h3>
<p>
    Criar um espaço onde a elegância, conforto e segurança caminham juntos, 
    proporcionando a melhor qualidade de vida para nossos moradores.
</p>
<h3>Certificações</h3>
<ul>
    <li>✓ Construção com padrão internacional</li>
    <li>✓ Acabamentos premium em todas as unidades</li>
    <li>✓ Infraestrutura completa de segurança</li>
    <li>✓ Sistemas sustentáveis</li>
</ul>
                ''',
                meta_descricao='Conheça o Sambaqui Tower House - Empreendimento residencial premium em Guaratuba',
                meta_keywords='empreendimento, residencial, guaratuba, premium, torres',
                ativa=True
            )
            db.session.add(about)
            db.session.commit()
            print("✓ Página 'Sobre' criada")
        
        print("\n✅ Banco de dados pronto para uso!")
        print("\n📊 Estatísticas:")
        print(f"  - Páginas: {Pagina.query.count()}")
        print(f"  - Configurações: {Configuracao.query.count()}")
        
        print("\n🔐 Credenciais de Admin:")
        print("  - Usuário: devsynapt")
        print("  - Senha: synmod3030")

if __name__ == '__main__':
    create_sample_data()
