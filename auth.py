"""
Sistema de autenticação administrativa
"""
from functools import wraps
from flask import session, redirect, url_for, current_app
from werkzeug.security import check_password_hash, generate_password_hash

def is_admin_logged_in():
    """Verifica se o admin está autenticado"""
    return session.get('admin_logged_in', False)

def login_admin(username, password):
    """Valida credenciais de admin"""
    if (username == current_app.config['ADMIN_USERNAME'] and 
        password == current_app.config['ADMIN_PASSWORD']):
        return True
    return False

def require_admin(f):
    """Decorator para proteger rotas administrativas"""
    @wraps(f)
    def decorated_function(*args, **kwargs):
        if not is_admin_logged_in():
            return redirect(url_for('admin_login'))
        return f(*args, **kwargs)
    return decorated_function

def log_admin_action(db, usuario, acao, descricao='', ip_address=''):
    """Registra ações administrativas para auditoria"""
    from database import Log
    log = Log(
        usuario=usuario,
        acao=acao,
        descricao=descricao,
        ip_address=ip_address
    )
    db.session.add(log)
    db.session.commit()
