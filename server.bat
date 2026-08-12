@echo off
setlocal
set SCRIPT_DIR=%~dp0
set PS1=%SCRIPT_DIR%server_manager.ps1
set PORT=8080

:menu
cls
echo ============================================
echo   Educano - Gerenciador do Servidor Flutter Web
echo ============================================
echo.
powershell -NoProfile -ExecutionPolicy Bypass -File "%PS1%" -Action status
echo.
echo 1. Iniciar servidor
echo 2. Parar servidor
echo 3. Reiniciar servidor
echo 4. Abrir no navegador
echo 5. Ver log
echo 6. Sair
echo.
set /p opt="Escolha uma opcao: "

if "%opt%"=="1" (
    powershell -NoProfile -ExecutionPolicy Bypass -File "%PS1%" -Action start
    goto pause_menu
)
if "%opt%"=="2" (
    powershell -NoProfile -ExecutionPolicy Bypass -File "%PS1%" -Action stop
    goto pause_menu
)
if "%opt%"=="3" (
    powershell -NoProfile -ExecutionPolicy Bypass -File "%PS1%" -Action restart
    goto pause_menu
)
if "%opt%"=="4" (
    start "" "http://localhost:%PORT%"
    goto pause_menu
)
if "%opt%"=="5" (
    if exist "%SCRIPT_DIR%server.log" (
        type "%SCRIPT_DIR%server.log"
    ) else (
        echo Nenhum log encontrado ainda.
    )
    goto pause_menu
)
if "%opt%"=="6" exit /b

goto menu

:pause_menu
echo.
pause
goto menu
