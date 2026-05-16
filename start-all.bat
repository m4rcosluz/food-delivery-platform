@echo off
setlocal EnableExtensions EnableDelayedExpansion

title Food Delivery Platform

cd /d "%~dp0"
set "ROOT_DIR=%~dp0"
set "START_DELAY=4"

:: ===========================================================================
:: MENU
:: ===========================================================================

:menu
cls

echo.
echo ============================================
echo   FOOD DELIVERY PLATFORM - Launcher
echo ============================================
echo.
echo   [1] Stack completa
echo   [2] Infraestrutura Docker
echo   [3] Apenas microservicos
echo   [4] Escolher servicos
echo   [5] Parar servicos
echo   [6] Status
echo   [0] Sair
echo.

set /p "CHOICE=Opcao: "

if "%CHOICE%"=="1" goto full_stack
if "%CHOICE%"=="2" goto infra_only
if "%CHOICE%"=="3" goto services_only
if "%CHOICE%"=="4" goto pick_services
if "%CHOICE%"=="5" goto stop_all
if "%CHOICE%"=="6" goto status
if "%CHOICE%"=="0" goto end

echo.
echo Opcao invalida.
pause
goto menu

:: ===========================================================================
:: STACK COMPLETA
:: ===========================================================================

:full_stack

call :check_maven

echo.
echo ============================================
echo Subindo Docker...
echo ============================================
echo.

call "%ROOT_DIR%iniciar-docker.bat"

echo.
echo ============================================
echo Aguardando Postgres...
echo ============================================
echo.

call :wait_postgres 60

goto start_all_services

:: ===========================================================================
:: INFRA
:: ===========================================================================

:infra_only

call "%ROOT_DIR%iniciar-docker.bat"

pause
goto menu

:: ===========================================================================
:: SERVICES ONLY
:: ===========================================================================

:services_only

call :check_maven

goto start_all_services

:: ===========================================================================
:: PICK SERVICES
:: ===========================================================================

:pick_services

cls

echo.
echo ============================================
echo Escolha os servicos
echo ============================================
echo.
echo [1] auth-service
echo [2] user-service
echo [3] restaurant-service
echo [4] order-service
echo [5] payment-service
echo [6] notification-service
echo [7] gateway-service
echo.
echo [A] Todos
echo [0] Voltar
echo.

set /p "PICK=Servicos: "

if /i "%PICK%"=="0" goto menu
if /i "%PICK%"=="A" goto start_all_services

for %%T in (%PICK%) do (
    call :start_by_index %%T
)

goto done_services

:: ===========================================================================
:: START ALL
:: ===========================================================================

:start_all_services

echo.
echo ============================================
echo Iniciando microservicos...
echo ============================================
echo.

call :start_service auth-service 8081
call :start_service user-service 8082
call :start_service restaurant-service 8083
call :start_service order-service 8084
call :start_service payment-service 8085
call :start_service notification-service 8086
call :start_service gateway-service 8080

goto done_services

:: ===========================================================================
:: DONE
:: ===========================================================================

:done_services

echo.
echo ============================================
echo Servicos iniciados
echo ============================================
echo.
echo Gateway:
echo http://localhost:8080
echo.

pause
goto menu

:: ===========================================================================
:: STOP
:: ===========================================================================

:stop_all

echo.
echo ============================================
echo Encerrando processos...
echo ============================================
echo.

for %%P in (8080 8081 8082 8083 8084 8085 8086) do (
    call :kill_port %%P
)

echo.
echo Finalizado.
echo.

pause
goto menu

:: ===========================================================================
:: STATUS
:: ===========================================================================

:status

echo.
echo ============================================
echo STATUS DOS SERVICOS
echo ============================================
echo.

call :port_status 8080 gateway-service
call :port_status 8081 auth-service
call :port_status 8082 user-service
call :port_status 8083 restaurant-service
call :port_status 8084 order-service
call :port_status 8085 payment-service
call :port_status 8086 notification-service

echo.
echo ============================================
echo DOCKER
echo ============================================
echo.

docker compose ps

echo.
pause
goto menu

:: ===========================================================================
:: FUNCTIONS
:: ===========================================================================

:check_maven

where mvn >nul 2>&1

if errorlevel 1 (
    echo.
    echo Maven nao encontrado no PATH.
    echo.
    pause
    goto menu
)

goto :eof

:: ---------------------------------------------------------------------------

:start_service

set "SVC_NAME=%~1"
set "SVC_PORT=%~2"

if not exist "%ROOT_DIR%%SVC_NAME%\pom.xml" (
    echo.
    echo [ERRO] %SVC_NAME% nao encontrado.
    goto :eof
)

call :port_in_use %SVC_PORT%

if %errorlevel%==0 (
    echo.
    echo [AVISO] Porta %SVC_PORT% ja esta em uso.
    goto :eof
)

echo.
echo [+] Iniciando %SVC_NAME% na porta %SVC_PORT%

start "fdp-%SVC_NAME%" cmd /k "cd /d ""%ROOT_DIR%%SVC_NAME%"" && title fdp-%SVC_NAME% && mvn spring-boot:run"

timeout /t %START_DELAY% /nobreak >nul

goto :eof

:: ---------------------------------------------------------------------------

:start_by_index

if "%~1"=="1" call :start_service auth-service 8081
if "%~1"=="2" call :start_service user-service 8082
if "%~1"=="3" call :start_service restaurant-service 8083
if "%~1"=="4" call :start_service order-service 8084
if "%~1"=="5" call :start_service payment-service 8085
if "%~1"=="6" call :start_service notification-service 8086
if "%~1"=="7" call :start_service gateway-service 8080

goto :eof

:: ---------------------------------------------------------------------------

:port_in_use

netstat -ano ^
| findstr ":%~1 " ^
| findstr "LISTENING" >nul 2>&1

exit /b %errorlevel%

:: ---------------------------------------------------------------------------

:port_status

call :port_in_use %~1

if %errorlevel%==0 (
    echo [OK] %~2 - porta %~1 em uso
) else (
    echo [  ] %~2 - porta %~1 livre
)

goto :eof

:: ---------------------------------------------------------------------------

:kill_port

for /f "tokens=5" %%I in ('
    netstat -ano ^| findstr ":%~1 " ^| findstr "LISTENING"
') do (
    echo Encerrando PID %%I da porta %~1
    taskkill /PID %%I /F >nul 2>&1
)

goto :eof

:: ---------------------------------------------------------------------------

:wait_postgres

set /a "MAX_WAIT=%~1"
set /a "ELAPSED=0"

:wait_loop

docker compose exec -T postgres pg_isready -U fooddelivery -d fooddelivery >nul 2>&1

if not errorlevel 1 (
    goto :eof
)

if %ELAPSED% geq %MAX_WAIT% (
    echo.
    echo [AVISO] Timeout aguardando Postgres.
    goto :eof
)

set /a ELAPSED+=2

timeout /t 2 /nobreak >nul

goto wait_loop

:: ===========================================================================
:: END
:: ===========================================================================

:end
exit