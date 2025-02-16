# Usar la imagen oficial de Python
FROM python:3.11

# Establecer el directorio de trabajo dentro del contenedor
WORKDIR /app

# Instalar dependencias con logs detallados
RUN python -m pip install --no-cache-dir --verbose -r requirements.txt

# Copiar el resto de los archivos del proyecto
COPY . .

# Exponer el puerto en el que correrá FastAPI
EXPOSE 8000

# Comando para ejecutar la API
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
