# Usar la imagen oficial de Python
FROM python:3.11

# Establecer el directorio de trabajo dentro del contenedor
WORKDIR /app

RUN python -m pip install --upgrade pip setuptools wheel

# Instalar dependencias antes de copiar todo el código
RUN python -m pip install --timeout=60 fastapi uvicorn motor 

# Ahora copiar el resto del código
COPY . .

# Exponer el puerto en el que correrá FastAPI
EXPOSE 8000

# Comando para ejecutar la API
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
