@echo off
setlocal EnableExtensions
cd /d "%~dp0"

echo [food-delivery-platform] Verificando Docker...
docker info >nul 2>&1 && goto :compose_up

echo Docker nao respondeu. Tentando iniciar o Docker Desktop...
set "DOCKER_DESKTOP=C:\Program Files\Docker\Docker\Docker Desktop.exe"
if not exist "%DOCKER_DESKTOP%" (
  echo ERRO: Docker Desktop nao encontrado em "%DOCKER_DESKTOP%"
  echo Edite este .bat se a instalacao estiver em outro caminho.
  exit /b 1
)
start "" "%DOCKER_DESKTOP%"

echo Aguardando o motor do Docker ficar pronto (ate ~5 min)...
set /a n=0
:wait
docker info >nul 2>&1 && goto :compose_up
set /a n+=1
if %n% geq 100 (
  echo TIMEOUT: Docker nao respondeu a tempo. Tente wsl --shutdown e abrir o Docker de novo.
  exit /b 1
)
timeout /t 3 /nobreak >nul
goto :wait

:compose_up
echo Iniciando stack: docker compose up -d
docker compose up -d
if errorlevel 1 exit /b 1
echo.
echo Containers:
docker compose ps
exit /b 0
