#!/usr/bin/env bash
set -euo pipefail

# Ajuste via variáveis de ambiente do Coolify, se quiser:
RUNTIME_IMAGE="${RUNTIME_IMAGE:-public.ecr.aws/lambda/python:3.12}"
ARCH="${ARCH:-x86_64}" # x86_64 ou arm64

echo "==> Build Lambda ZIP (Pillow)"
echo "Runtime image: $RUNTIME_IMAGE"
echo "Target arch:   $ARCH"

# 0) Teste rápido: Docker está disponível no ambiente?
echo "==> Checando Docker..."
docker version

rm -rf build
mkdir -p build/package

# 1) Definir platform para a arquitetura
if [ "$ARCH" = "arm64" ]; then
  PLATFORM="linux/arm64"
else
  PLATFORM="linux/amd64"
fi
echo "Docker platform: $PLATFORM"

# 2) Instalar dependências dentro da imagem do Lambda
echo "==> Instalando dependências (pip) no ambiente compatível com Lambda..."
docker run --rm --platform "$PLATFORM" -v "$PWD":/var/task "$RUNTIME_IMAGE" \
  /bin/bash -lc "python -V && pip -V && pip install -r requirements.txt -t build/package"

# 3) Copiar seu código para o root do pacote
echo "==> Copiando código da Lambda..."
cp lambda_function.py build/package/

# 4) Criar o ZIP
echo "==> Criando ZIP..."
(
  cd build/package
  zip -r ../deployment_package.zip .
)

echo "==> OK. ZIP gerado:"
ls -lh build/deployment_package.zip