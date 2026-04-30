"""
Configurações da aplicação Sambaqui Tower House
"""
import os
from datetime import timedelta

class Config:
    """Configuração base"""
    # Caminho da aplicação
    BASE_DIR = os.path.abspath(os.path.dirname(__file__))
    
    # Database
    SQLALCHEMY_DATABASE_URI = f'sqlite:///{os.path.join(BASE_DIR, "sambaqui.db")}'
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    
    # Session
    PERMANENT_SESSION_LIFETIME = timedelta(days=7)
    SESSION_COOKIE_SECURE = True
    SESSION_COOKIE_HTTPONLY = True
    SESSION_COOKIE_SAMESITE = 'Lax'
    
    # Admin
    ADMIN_USERNAME = 'devsynapt'
    ADMIN_PASSWORD = 'synmod3030'
    
    # Security
    SECRET_KEY = os.environ.get('SECRET_KEY') or 'sambaqui-dev-key-2026'
    
    # Uploads
    UPLOAD_FOLDER = os.path.join(BASE_DIR, 'static', 'uploads')
    MAX_CONTENT_LENGTH = 16 * 1024 * 1024  # 16MB
    
class DevelopmentConfig(Config):
    """Configuração de desenvolvimento"""
    DEBUG = True
    SESSION_COOKIE_SECURE = False
    
class ProductionConfig(Config):
    """Configuração de produção"""
    DEBUG = False
    SESSION_COOKIE_SECURE = True
    
config = {
    'development': DevelopmentConfig,
    'production': ProductionConfig,
    'default': DevelopmentConfig
}
