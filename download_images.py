import os
import requests
from datetime import datetime

def download_images():
    """
    Baixa as imagens do HTML original para o diretório static/uploads
    e retorna um mapeamento dos URLs originais para os caminhos locais.
    """
    
    # Certifique-se de que o diretório de uploads existe
    upload_dir = os.path.join(os.path.dirname(__file__), 'static', 'uploads')
    os.makedirs(upload_dir, exist_ok=True)

    image_map = {
        'https://dbvebtn3wsif3.cloudfront.net/foto/3591/3591/v-15/imoveis/1473925/23511843/4.jpg': 'gallery_01.jpg',
        'https://dbvebtn3wsif3.cloudfront.net/foto/3591/3591/v-15/imoveis/1473925/23511844/4.jpg': 'gallery_02.jpg',
        'https://dbvebtn3wsif3.cloudfront.net/foto/3591/3591/v-15/imoveis/1473925/23511846/4.jpg': 'gallery_03.jpg',
        'https://dbvebtn3wsif3.cloudfront.net/foto/3591/3591/v-15/imoveis/1473925/23511847/4.jpg': 'gallery_04.jpg',
        'https://dbvebtn3wsif3.cloudfront.net/foto/3591/3591/v-15/imoveis/1473925/23511848/4.jpg': 'gallery_05.jpg',
        'https://dbvebtn3wsif3.cloudfront.net/foto/3591/3591/v-15/imoveis/1473925/23511849/4.jpg': 'gallery_06.jpg',
        'https://dbvebtn3wsif3.cloudfront.net/foto/3591/3591/v-15/imoveis/1473925/23511850/4.jpg': 'gallery_07.jpg',
        'https://dbvebtn3wsif3.cloudfront.net/foto/3591/3591/v-15/imoveis/1473925/23511845/4.jpg': 'gallery_08.jpg',
        'https://dbvebtn3wsif3.cloudfront.net/foto/3591/3591/v-15/imoveis/1473925/23511851/4.jpg': 'gallery_09.jpg',
        'https://dbvebtn3wsif3.cloudfront.net/foto/3591/3591/v-15/imoveis/1473925/23511852/4.jpg': 'gallery_10.jpg',
        'https://dbvebtn3wsif3.cloudfront.net/foto/3591/3591/v-15/imoveis/1473925/23511854/4.jpg': 'gallery_11.jpg',
        'https://dbvebtn3wsif3.cloudfront.net/foto/3591/3591/v-15/imoveis/1473925/23511840/4.jpg': 'gallery_12.jpg', # floorplan_garden
        'https://dbvebtn3wsif3.cloudfront.net/foto/3591/3591/v-15/imoveis/1473925/23511841/4.jpg': 'gallery_13.jpg', # floorplan_duplex
        'https://dbvebtn3wsif3.cloudfront.net/foto/3591/3591/v-15/imoveis/1473925/23511842/4.jpg': 'gallery_14.jpg',
        'https://dbvebtn3wsif3.cloudfront.net/foto/3591/3591/v-15/imoveis/1473925/23511853/4.jpg': 'gallery_15.jpg',
        'https://dbvebtn3wsif3.cloudfront.net/foto/3591/3591/v-15/imoveis/1473925/24819900/4.jpg': 'gallery_16.jpg', # floorplan_std
    }

    print("Iniciando download das imagens...")
    for original_url, local_filename in image_map.items():
        local_path = os.path.join(upload_dir, local_filename)
        if os.path.exists(local_path):
            print(f"  - Imagem já existe: {local_filename}")
            continue
        
        try:
            response = requests.get(original_url, stream=True)
            response.raise_for_status() # Levanta um erro para códigos de status HTTP ruins
            with open(local_path, 'wb') as f:
                for chunk in response.iter_content(chunk_size=8192):
                    f.write(chunk)
            print(f"  - Baixado: {local_filename}")
        except requests.exceptions.RequestException as e:
            print(f"  - Erro ao baixar {original_url}: {e}")
        except Exception as e:
            print(f"  - Erro inesperado ao salvar {local_filename}: {e}")
            
    print("Download de imagens concluído.")
    return image_map

if __name__ == '__main__':
    print("Este script irá baixar as imagens necessárias para o projeto.")
    print("Certifique-se de ter 'requests' instalado (pip install requests).")
    print("As imagens serão salvas em 'static/uploads'.")
    
    # Adiciona um pequeno atraso para o usuário ler a mensagem
    # import time
    # time.sleep(2)
    
    download_images()