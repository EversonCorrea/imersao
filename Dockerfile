# Etapa 1: Usar uma imagem base oficial do Python com Alpine
# A imagem 'alpine' é minimalista, resultando em um contêiner menor e mais seguro.
# Usando a versão estável 3.10, conforme o readme.md, em vez de uma versão beta instável.
FROM python:3.10-alpine

# Etapa 2: Definir o diretório de trabalho dentro do contêiner
WORKDIR /app

# Etapa 3: Copiar o arquivo de dependências
# Copiamos este arquivo primeiro para otimizar o cache de camadas do Docker.
# As dependências só serão reinstaladas se o arquivo requirements.txt mudar.
COPY requirements.txt .

# Etapa 4: Instalar dependências
# Instalamos as dependências do sistema (build-base) necessárias para compilar
# alguns pacotes Python. Usamos um 'virtual package' (.build-deps) para poder
# removê-las após a instalação, mantendo a imagem final enxuta.
RUN apk add --no-cache --virtual .build-deps build-base \
    && pip install --no-cache-dir -r requirements.txt \
    && apk del .build-deps

# Etapa 5: Copiar o restante do código da aplicação para o contêiner
COPY . .

# Etapa 6: Expor a porta em que a aplicação será executada
EXPOSE 8000

# Etapa 7: Comando para iniciar a aplicação com Uvicorn
# O host 0.0.0.0 permite que a API seja acessível de fora do contêiner.
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000", "--reload"]
