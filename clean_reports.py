from bs4 import BeautifulSoup
import os

REPORTE_DIR = "reportes"


def limpiar_html(path):
    with open(path, 'r', encoding='utf-8') as f:
        soup = BeautifulSoup(f, 'html.parser')

    # Encuentra todas las tablas que contienen 'Cross-Domain Misconfiguration'
    tablas = soup.find_all('table')
    for tabla in tablas:
        if tabla.find(string=lambda t: t and 'Cross-Domain Misconfiguration' in t):
            if tabla.find(string=lambda t: t and '/_next/static/' in t):
                tabla.decompose()

    with open(path, 'w', encoding='utf-8') as f:
        f.write(str(soup))


for archivo in os.listdir(REPORTE_DIR):
    if archivo.endswith('.html'):
        print(f"🧹 Limpiando {archivo}...")
        limpiar_html(os.path.join(REPORTE_DIR, archivo))
