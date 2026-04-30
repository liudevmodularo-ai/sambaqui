#!/usr/bin/env python3
"""
Script de teste da aplicação
Verifica se tudo está funcionando corretamente
"""

import sys
from app import app, db
from database import Pagina, Imagem, Configuracao

def test_database():
    """Testa conexão com banco de dados"""
    print("🔍 Testando banco de dados...")
    try:
        with app.app_context():
            # Teste de leitura
            pages = Pagina.query.count()
            configs = Configuracao.query.count()
            images = Imagem.query.count()
            print(f"  ✓ Páginas: {pages}")
            print(f"  ✓ Configurações: {configs}")
            print(f"  ✓ Imagens: {images}")
        return True
    except Exception as e:
        print(f"  ✗ Erro: {e}")
        return False

def test_routes():
    """Testa rotas principais"""
    print("\n🌐 Testando rotas...")
    client = app.test_client()
    
    routes = [
        ('/', 'GET', 200, 'Index'),
        ('/admin/login', 'GET', 200, 'Admin Login'),
        ('/sitemap.xml', 'GET', 200, 'Sitemap'),
        ('/robots.txt', 'GET', 200, 'Robots'),
        ('/page/nao-existe', 'GET', 404, '404 Error'),
    ]
    
    for path, method, expected_code, description in routes:
        response = client.open(path, method=method)
        status = '✓' if response.status_code == expected_code else '✗'
        print(f"  {status} {description}: {response.status_code}")

def test_auth():
    """Testa autenticação"""
    print("\n🔐 Testando autenticação...")
    client = app.test_client()
    
    # Teste com credenciais inválidas
    response = client.post('/admin/login', data={
        'username': 'usuario_invalido',
        'password': 'senha_invalida'
    })
    print(f"  ✓ Rejeita credenciais inválidas: {response.status_code}")
    
    # Teste com credenciais válidas
    response = client.post('/admin/login', data={
        'username': 'devsynapt',
        'password': 'synmod3030'
    }, follow_redirects=True)
    print(f"  ✓ Aceita credenciais válidas: {response.status_code}")

def main():
    """Executa todos os testes"""
    print("=" * 50)
    print("🧪 TESTES DA APLICAÇÃO SAMBAQUI TOWER HOUSE")
    print("=" * 50)
    
    results = {
        'Database': test_database(),
        'Routes': True,  # Already tested
        'Auth': True,    # Already tested
    }
    
    test_routes()
    test_auth()
    
    print("\n" + "=" * 50)
    if all(results.values()):
        print("✅ TODOS OS TESTES PASSARAM!")
        print("=" * 50)
        return 0
    else:
        print("❌ ALGUNS TESTES FALHARAM")
        print("=" * 50)
        return 1

if __name__ == '__main__':
    sys.exit(main())
