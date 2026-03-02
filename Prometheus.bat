@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion
title Prometheus

REM ===================================================================================================
REM Prometheus - Claude API Profile Manager
REM 优化版本：界面美化、功能增强、安全性提升
REM ===================================================================================================

:: 颜色定义
for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do set "ESC=%%b"
set "c_GOLD=%ESC%[93m"
set "c_CYAN=%ESC%[96m"
set "c_GREEN=%ESC%[92m"
set "c_RED=%ESC%[91m"
set "c_GRAY=%ESC%[90m"
set "c_WHITE=%ESC%[97m"
set "c_YELLOW=%ESC%[33m"
set "c_MAGENTA=%ESC%[95m"
set "c_RESET=%ESC%[0m"
set "c_DIM=%ESC%[2m"
set "c_BOLD=%ESC%[1m"



:MAIN_MENU
:: Initialize/Clear variables
set count=0
set "active_profile="
for /L %%i in (1,1,100) do (
    set "p_name[%%i]="
    set "p_key[%%i]="
    set "p_url[%%i]="
    set "p_haiku[%%i]="
    set "p_sonnet[%%i]="
    set "p_opus[%%i]="
)

:: Initialize Shortcuts
set sc_count=0
for /L %%i in (1,1,50) do (
    set "sc_alias[%%i]="
    set "sc_cmd[%%i]="
)

:: Get current registry key
for /f "tokens=2*" %%a in ('reg query "HKCU\Environment" /v ANTHROPIC_AUTH_TOKEN 2^>nul') do set "current_key=%%b"

:: Load Data into Memory & Find Active Profile
for /f "tokens=2,3,4,5,6,7 delims=|" %%a in ('findstr /b "::DATA|" "%~f0"') do (
    set /a count+=1
    set "p_name[!count!]=%%a"
    set "p_key[!count!]=%%b"
    set "p_url[!count!]=%%c"
    set "p_haiku[!count!]=%%d"
    set "p_sonnet[!count!]=%%e"
    set "p_opus[!count!]=%%f"

    if "%%b"=="!current_key!" (
        set "active_profile=%%a"
    )
)

:: Load Shortcuts
for /f "tokens=2,3 delims=|" %%a in ('findstr /b "::SHORTCUT|" "%~f0"') do (
    set /a sc_count+=1
    set "sc_alias[!sc_count!]=%%a"
    set "sc_cmd[!sc_count!]=%%b"
)

:: Now Render UI
cls
echo.
echo  %c_GOLD% ┏━┃┏━┃┏━┃┏┏ ┏━┛━┏┛┃ ┃┏━┛┃ ┃┏━┛ %c_RESET%
echo  %c_GOLD% ┏━┛┏┏┛┃ ┃┃┃┃┏━┛ ┃ ┏━┃┏━┛┃ ┃━━┃  %c_RESET%
echo  %c_GOLD% ┛  ┛ ┛━━┛┛┛┛━━┛ ┛ ┛ ┛━━┛━━┛━━┛     %c_RESET%
echo.
echo %c_CYAN% ┌─────────────────────────────────────────────────────────────────────────────────┐%c_RESET%
echo %c_CYAN% │%c_WHITE%  PROFILES                                                                       %c_CYAN%│%c_RESET%
echo %c_CYAN% └─────────────────────────────────────────────────────────────────────────────────┘%c_RESET%
echo.
if defined active_profile (
    echo   Current Global Profile: %c_GREEN%!active_profile!%c_RESET%
) else (
    echo   %c_GRAY%No global profile active%c_RESET%
)
echo.

:: Loop to Render List
if %count%==0 (
    echo.
    echo   %c_GRAY%  No profiles found. Press [N] to create one.%c_RESET%
    echo.
) else (
    for /L %%i in (1,1,%count%) do (
        set "status_icon=  "
        if "!p_key[%%i]!"=="!current_key!" (
            set "status_icon=%c_GREEN%●%c_RESET% "
        )
        
        set "full_key=!p_key[%%i]!"
        set "masked_key=!full_key:~0,8!****!full_key:~-4!"
        
        echo  !status_icon!%c_WHITE%[%%i]%c_RESET% %c_YELLOW%!p_name[%%i]!%c_RESET%
        echo        %c_GRAY%Key: !masked_key!%c_RESET%
        echo        %c_GRAY%URL: !p_url[%%i]!%c_RESET%
        set "models_str="
        if defined p_haiku[%%i] set "models_str=!models_str! HK:!p_haiku[%%i]!"
        if defined p_sonnet[%%i] set "models_str=!models_str! SN:!p_sonnet[%%i]!"
        if defined p_opus[%%i] set "models_str=!models_str! OP:!p_opus[%%i]!"
        if defined models_str echo        %c_GRAY%Models:!models_str!%c_RESET%
        echo.
    )
)

echo %c_CYAN% ┌─────────────────────────────────────────────────────────────────────────────────┐%c_RESET%
echo %c_CYAN% │%c_WHITE%  COMMANDS                                                                       %c_CYAN%│%c_RESET%
echo %c_CYAN% └─────────────────────────────────────────────────────────────────────────────────┘%c_RESET%
echo.
echo    %c_WHITE%[N]%c_RESET% New Profile    %c_WHITE%[E]%c_RESET% Edit Profile    %c_WHITE%[D]%c_RESET% Delete Profile
echo    %c_WHITE%[G]%c_RESET% Global Env     %c_WHITE%[T]%c_RESET% Test Connect    %c_WHITE%[B]%c_RESET% Backup/Restore
echo    %c_WHITE%[C]%c_RESET% Clear All      %c_WHITE%[H]%c_RESET% Help            %c_WHITE%[Q]%c_RESET% Quit
echo    %c_WHITE%[S]%c_RESET% Shortcuts
echo.
echo    %c_GRAY%[0] or Enter to go back in submenus%c_RESET%
echo.
echo %c_CYAN% ───────────────────────────────────────────────────────────────────────────────────%c_RESET%

set /p "ACTION=  %c_WHITE%   Select [1-%count%] or Command: %c_RESET%"

if /i "%ACTION%"=="G" goto GLOBAL_APPLY_MENU
if /i "%ACTION%"=="N" goto NEW_CONFIG
if /i "%ACTION%"=="E" goto EDIT_CONFIG
if /i "%ACTION%"=="D" goto DELETE_CONFIG
if /i "%ACTION%"=="T" goto TEST_CONNECTION
if /i "%ACTION%"=="B" goto BACKUP_MENU
if /i "%ACTION%"=="C" goto CLEAR_ALL_CONFIG
if /i "%ACTION%"=="S" goto SHORTCUT_MENU
if /i "%ACTION%"=="H" goto SHOW_HELP
if /i "%ACTION%"=="Q" goto EXIT_APP

:: 检查是否选择了有效的配置编号 -> 现在直接启动隔离终端
if defined p_name[%ACTION%] (
    set "L_NUM=%ACTION%"
    goto DO_LAUNCH_DIRECT
)

goto MAIN_MENU

REM ===================================================================================================
REM 新建配置
REM ===================================================================================================
:NEW_CONFIG
cls
call :SHOW_HEADER "NEW PROFILE"
echo.
echo   %c_GRAY%Press [0] or Enter to return to main menu%c_RESET%
echo.

set "N_NAME="
set "N_KEY="
set "N_URL="
set "N_HAIKU="
set "N_SONNET="
set "N_OPUS="

set /p "N_NAME=  %c_WHITE%Profile Name: %c_RESET%"
if "%N_NAME%"=="" goto MAIN_MENU
if "%N_NAME%"=="0" goto MAIN_MENU

:: 验证名称不包含特殊字符
echo %N_NAME% | findstr /r "[|<>]" >nul && (
    call :SHOW_ERROR "Profile name cannot contain special characters (| < >)"
    goto NEW_CONFIG
)

set /p "N_KEY=  %c_WHITE%API Key: %c_RESET%"
if "%N_KEY%"=="" goto MAIN_MENU
if "%N_KEY%"=="0" goto MAIN_MENU

:: 验证 API Key 格式
echo %N_KEY% | findstr /b "sk-" >nul || (
    echo.
    echo   %c_YELLOW%Warning: API Key doesn't start with 'sk-'. Continue anyway? [Y/N]%c_RESET%
    set /p "CONFIRM="
    if /i "!CONFIRM!" NEQ "Y" goto NEW_CONFIG
)

set /p "N_URL=  %c_WHITE%API URL: %c_RESET%"
if "%N_URL%"=="" goto MAIN_MENU
if "%N_URL%"=="0" goto MAIN_MENU

:: 验证 URL 格式
echo %N_URL% | findstr /b "http" >nul || (
    call :SHOW_ERROR "URL must start with http:// or https://"
    goto NEW_CONFIG
)

set /p "N_HAIKU=  %c_WHITE%Haiku Model (Optional): %c_RESET%"
if "%N_HAIKU%"=="0" goto MAIN_MENU
set /p "N_SONNET=  %c_WHITE%Sonnet Model (Optional): %c_RESET%"
if "%N_SONNET%"=="0" goto MAIN_MENU
set /p "N_OPUS=  %c_WHITE%Opus Model (Optional): %c_RESET%"
if "%N_OPUS%"=="0" goto MAIN_MENU

:: 保存配置
echo ::DATA^|%N_NAME%^|%N_KEY%^|%N_URL%^|%N_HAIKU%^|%N_SONNET%^|%N_OPUS%>>"%~f0"

call :SHOW_SUCCESS "Profile '%N_NAME%' created successfully!"
timeout /t 2 >nul
goto MAIN_MENU

REM ===================================================================================================
REM 编辑配置
REM ===================================================================================================
:EDIT_CONFIG
cls
call :SHOW_HEADER "EDIT PROFILE"
echo.
echo   %c_GRAY%Press [0] or Enter to return to main menu%c_RESET%
echo.

if %count%==0 (
    call :SHOW_ERROR "No profiles to edit."
    timeout /t 2 >nul
    goto MAIN_MENU
)

set /p "E_NUM=  %c_WHITE%Enter profile ID to edit [1-%count%]: %c_RESET%"
if "%E_NUM%"=="" goto MAIN_MENU
if "%E_NUM%"=="0" goto MAIN_MENU

if not defined p_name[%E_NUM%] (
    call :SHOW_ERROR "Invalid profile ID."
    timeout /t 2 >nul
    goto MAIN_MENU
)

set "OLD_NAME=!p_name[%E_NUM%]!"
set "OLD_KEY=!p_key[%E_NUM%]!"
set "OLD_URL=!p_url[%E_NUM%]!"
set "OLD_HAIKU=!p_haiku[%E_NUM%]!"
set "OLD_SONNET=!p_sonnet[%E_NUM%]!"
set "OLD_OPUS=!p_opus[%E_NUM%]!"

echo.
echo   %c_GRAY%Current values shown in brackets. Press Enter to keep.%c_RESET%
echo   %c_GRAY%Current Name: %OLD_NAME%%c_RESET%
echo.
set /p "NEW_NAME=  %c_WHITE%New Name: %c_RESET%"
if "%NEW_NAME%"=="" set "NEW_NAME=%OLD_NAME%"

echo   %c_GRAY%Current Key: %OLD_KEY:~0,8%****%OLD_KEY:~-4%%c_RESET%
set /p "NEW_KEY=  %c_WHITE%New Key: %c_RESET%"
if "%NEW_KEY%"=="" set "NEW_KEY=%OLD_KEY%"

echo   %c_GRAY%Current URL: %OLD_URL%%c_RESET%
set /p "NEW_URL=  %c_WHITE%New URL: %c_RESET%"
if "%NEW_URL%"=="" set "NEW_URL=%OLD_URL%"

echo   %c_GRAY%Current Haiku: %OLD_HAIKU%%c_RESET%
set /p "NEW_HAIKU=  %c_WHITE%New Haiku (Enter '-' to clear): %c_RESET%"
if "%NEW_HAIKU%"=="" set "NEW_HAIKU=%OLD_HAIKU%"
if "%NEW_HAIKU%"=="-" set "NEW_HAIKU="

echo   %c_GRAY%Current Sonnet: %OLD_SONNET%%c_RESET%
set /p "NEW_SONNET=  %c_WHITE%New Sonnet (Enter '-' to clear): %c_RESET%"
if "%NEW_SONNET%"=="" set "NEW_SONNET=%OLD_SONNET%"
if "%NEW_SONNET%"=="-" set "NEW_SONNET="

echo   %c_GRAY%Current Opus: %OLD_OPUS%%c_RESET%
set /p "NEW_OPUS=  %c_WHITE%New Opus (Enter '-' to clear): %c_RESET%"
if "%NEW_OPUS%"=="" set "NEW_OPUS=%OLD_OPUS%"
if "%NEW_OPUS%"=="-" set "NEW_OPUS="

:: 删除旧配置并添加新配置
set "D_TARGET=::DATA|%OLD_NAME%|%OLD_KEY%|%OLD_URL%"
findstr /v /c:"%D_TARGET%" "%~f0" > "%~f0.tmp"
move /y "%~f0.tmp" "%~f0" >nul
echo ::DATA^|%NEW_NAME%^|%NEW_KEY%^|%NEW_URL%^|%NEW_HAIKU%^|%NEW_SONNET%^|%NEW_OPUS%>>"%~f0"

call :SHOW_SUCCESS "Profile updated successfully!"
timeout /t 2 >nul
goto MAIN_MENU

REM ===================================================================================================
REM 删除配置
REM ===================================================================================================
:DELETE_CONFIG
cls
call :SHOW_HEADER "DELETE PROFILE"
echo.
echo   %c_GRAY%Press [0] or Enter to return to main menu%c_RESET%
echo.

if %count%==0 (
    call :SHOW_ERROR "No profiles to delete."
    timeout /t 2 >nul
    goto MAIN_MENU
)

set /p "D_NUM=  %c_WHITE%Enter profile ID to delete [1-%count%]: %c_RESET%"
if "%D_NUM%"=="" goto MAIN_MENU
if "%D_NUM%"=="0" goto MAIN_MENU

if not defined p_name[%D_NUM%] (
    call :SHOW_ERROR "Invalid profile ID."
    timeout /t 2 >nul
    goto MAIN_MENU
)

set "DEL_NAME=!p_name[%D_NUM%]!"
echo.
echo   %c_YELLOW%Are you sure you want to delete '%DEL_NAME%'? [Y/N]%c_RESET%
set /p "CONFIRM="
if /i "%CONFIRM%" NEQ "Y" goto MAIN_MENU

set "D_TARGET=::DATA|!p_name[%D_NUM%]!|!p_key[%D_NUM%]!|!p_url[%D_NUM%]!"
findstr /v /c:"%D_TARGET%" "%~f0" > "%~f0.tmp"
move /y "%~f0.tmp" "%~f0" >nul

call :SHOW_SUCCESS "Profile '%DEL_NAME%' deleted."
timeout /t 2 >nul
timeout /t 2 >nul
goto MAIN_MENU

REM ===================================================================================================
REM 启动终端 (Direct Jump Label)
REM ===================================================================================================
:DO_LAUNCH_DIRECT
:: L_NUM 已经在跳转前设置好了
set "L_NAME=!p_name[%L_NUM%]!"
set "L_KEY=!p_key[%L_NUM%]!"
set "L_URL=!p_url[%L_NUM%]!"
set "L_HAIKU=!p_haiku[%L_NUM%]!"
set "L_SONNET=!p_sonnet[%L_NUM%]!"
set "L_OPUS=!p_opus[%L_NUM%]!"

echo.
echo   %c_CYAN%Launching isolated terminal for %L_NAME%...%c_RESET%
echo.

set "SHORTCUT_STRING="
if %sc_count% GTR 0 (
    for /L %%i in (1,1,%sc_count%) do (
        set "SHORTCUT_STRING=!SHORTCUT_STRING! & doskey !sc_alias[%%i]!=!sc_cmd[%%i]!"
    )
)

set "MODEL_ENV="
if defined L_HAIKU set "MODEL_ENV=!MODEL_ENV!& set ANTHROPIC_DEFAULT_HAIKU_MODEL=!L_HAIKU!"
if defined L_SONNET set "MODEL_ENV=!MODEL_ENV!& set ANTHROPIC_DEFAULT_SONNET_MODEL=!L_SONNET!"
if defined L_OPUS set "MODEL_ENV=!MODEL_ENV!& set ANTHROPIC_DEFAULT_OPUS_MODEL=!L_OPUS!"

wt -w 0 nt --title "Prometheus: %L_NAME%" -d . cmd /k "title Prometheus: %L_NAME% & color 0B & echo. & echo %c_MAGENTA% ┏━┃┏━┃┏━┃┏┏ ┏━┛━┏┛┃ ┃┏━┛┃ ┃┏━┛ %c_RESET% & echo %c_MAGENTA% ┏━┛┏┏┛┃ ┃┃┃┃┏━┛ ┃ ┏━┃┏━┛┃ ┃━━┃  %c_RESET% & echo %c_MAGENTA% ┛  ┛ ┛━━┛┛┛┛━━┛ ┛ ┛ ┛━━┛━━┛━━┛     %c_RESET% & echo. & echo  %c_GOLD%Prometheus Isolated Environment%c_RESET% & echo  %c_GRAY%Profile: %L_NAME%%c_RESET% & echo  %c_GRAY%URL: %L_URL%%c_RESET% & echo. & set ANTHROPIC_AUTH_TOKEN=%L_KEY%& set ANTHROPIC_BASE_URL=%L_URL%& set CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1!MODEL_ENV!%SHORTCUT_STRING%"

goto MAIN_MENU

REM ===================================================================================================
REM 测试连接
REM ===================================================================================================
:TEST_CONNECTION
cls
call :SHOW_HEADER "TEST CONNECTION"
echo.
echo   %c_GRAY%Press [0] or Enter to return to main menu%c_RESET%
echo.

if %count%==0 (
    call :SHOW_ERROR "No profiles to test."
    timeout /t 2 >nul
    goto MAIN_MENU
)

set /p "T_NUM=  %c_WHITE%Enter profile ID to test [1-%count%]: %c_RESET%"
if "%T_NUM%"=="" goto MAIN_MENU
if "%T_NUM%"=="0" goto MAIN_MENU

if not defined p_name[%T_NUM%] (
    call :SHOW_ERROR "Invalid profile ID."
    timeout /t 2 >nul
    goto MAIN_MENU
)

set "TEST_NAME=!p_name[%T_NUM%]!"
set "TEST_KEY=!p_key[%T_NUM%]!"
set "TEST_URL=!p_url[%T_NUM%]!"

echo.
echo   %c_CYAN%Testing connection to %TEST_URL%...%c_RESET%
echo.

:: 使用 curl 测试连接
curl -s -o nul -w "%%{http_code}" -H "x-api-key: %TEST_KEY%" -H "anthropic-version: 2023-06-01" "%TEST_URL%/v1/models" > "%TEMP%\prometheus_test.tmp" 2>&1

set /p HTTP_CODE=<"%TEMP%\prometheus_test.tmp"
del "%TEMP%\prometheus_test.tmp" 2>nul

if "%HTTP_CODE%"=="200" (
    call :SHOW_SUCCESS "Connection successful! (HTTP 200)"
) else if "%HTTP_CODE%"=="401" (
    call :SHOW_ERROR "Authentication failed. Check your API key. (HTTP 401)"
) else if "%HTTP_CODE%"=="403" (
    call :SHOW_ERROR "Access forbidden. Check your permissions. (HTTP 403)"
) else if "%HTTP_CODE%"=="000" (
    call :SHOW_ERROR "Connection failed. Check URL or network."
) else (
    echo   %c_YELLOW%Response: HTTP %HTTP_CODE%%c_RESET%
)

echo.
pause
goto MAIN_MENU

REM ===================================================================================================
REM 备份/恢复菜单
REM ===================================================================================================
:BACKUP_MENU
cls
call :SHOW_HEADER "BACKUP / RESTORE"
echo.
echo   %c_CYAN%Choose an action:%c_RESET%
echo.
echo   %c_WHITE%[1]%c_RESET% Quick Backup (to Desktop)
echo   %c_WHITE%[2]%c_RESET% Import from File
echo.
echo   %c_GRAY%[0] Back to Main Menu%c_RESET%
echo.

set /p "B_ACTION=  %c_WHITE%Select [1-2]: %c_RESET%"

if "%B_ACTION%"=="1" goto QUICK_BACKUP
if "%B_ACTION%"=="2" goto LOAD_FROM_FILE
if "%B_ACTION%"=="0" goto MAIN_MENU
goto BACKUP_MENU

REM ===================================================================================================
REM 快速备份
REM ===================================================================================================
:QUICK_BACKUP
if %count%==0 (
    call :SHOW_ERROR "No profiles to backup."
    timeout /t 2 >nul
    goto BACKUP_MENU
)

set "BACKUP_FILE=%USERPROFILE%\Desktop\prometheus_backup_%date:~0,4%%date:~5,2%%date:~8,2%_%time:~0,2%%time:~3,2%%time:~6,2%.txt"
set "BACKUP_FILE=%BACKUP_FILE: =0%"

echo # Prometheus Config Backup > "%BACKUP_FILE%"
echo # Generated: %date% %time% >> "%BACKUP_FILE%"
echo # ================================ >> "%BACKUP_FILE%"

for /f "tokens=2,3,4,5,6,7 delims=|" %%a in ('findstr /b "::DATA|" "%~f0"') do (
    echo %%a^|%%b^|%%c^|%%d^|%%e^|%%f >> "%BACKUP_FILE%"
)
for /f "tokens=2,3 delims=|" %%a in ('findstr /b "::SHORTCUT|" "%~f0"') do (
    echo SHORTCUT^|%%a^|%%b >> "%BACKUP_FILE%"
)

call :SHOW_SUCCESS "Quick Backup created at:"
echo   %c_GRAY%%BACKUP_FILE%%c_RESET%
echo.
echo   %c_WHITE%Press any key to return...%c_RESET%
pause >nul
goto BACKUP_MENU

REM ===================================================================================================
REM 从文件导入
REM ===================================================================================================
:LOAD_FROM_FILE
cls
call :SHOW_HEADER "IMPORT CONFIG"
echo.
echo   %c_GRAY%Press [0] or Enter to return to backup menu%c_RESET%
echo.

set /p "IMPORT_FILE=  %c_WHITE%Import file path: %c_RESET%"
if "%IMPORT_FILE%"=="" goto BACKUP_MENU
if "%IMPORT_FILE%"=="0" goto BACKUP_MENU

if not exist "%IMPORT_FILE%" (
    call :SHOW_ERROR "File not found."
    timeout /t 2 >nul
    goto BACKUP_MENU
)

set import_count=0
for /f "tokens=1,2,3,4,5,6 delims=|" %%a in ('findstr /v /b "#" "%IMPORT_FILE%"') do (
    if not "%%a"=="" if not "%%b"=="" if not "%%c"=="" (
        if "%%a"=="SHORTCUT" (
            echo ::SHORTCUT^|%%b^|%%c>>"%~f0"
        ) else (
            echo ::DATA^|%%a^|%%b^|%%c^|%%d^|%%e^|%%f>>"%~f0"
        )
        set /a import_count+=1
    )
)

call :SHOW_SUCCESS "Imported %import_count% profile(s)."
timeout /t 2 >nul
goto BACKUP_MENU

REM ===================================================================================================
REM 清空所有配置
REM ===================================================================================================
:CLEAR_ALL_CONFIG
cls
call :SHOW_HEADER "CLEAR ALL PROFILES"
echo.
echo   %c_GRAY%Press [0] or Enter to return to main menu%c_RESET%
echo.

if %count%==0 (
    call :SHOW_ERROR "No profiles to clear."
    timeout /t 2 >nul
    goto MAIN_MENU
)

echo   %c_RED%WARNING: This will delete ALL %count% profile(s)!%c_RESET%
echo.
echo   %c_YELLOW%Type 'DELETE' to confirm: %c_RESET%
set /p "CONFIRM="
if "%CONFIRM%"=="" goto MAIN_MENU
if "%CONFIRM%"=="0" goto MAIN_MENU

if "%CONFIRM%" NEQ "DELETE" (
    echo.
    echo   %c_GRAY%Operation cancelled.%c_RESET%
    timeout /t 2 >nul
    goto MAIN_MENU
)

findstr /v /b "::DATA|" "%~f0" > "%~f0.tmp"
move /y "%~f0.tmp" "%~f0" >nul

call :SHOW_SUCCESS "All profiles cleared."
timeout /t 2 >nul
goto MAIN_MENU

REM ===================================================================================================
REM 应用配置 (Set Global)
REM ===================================================================================================
:GLOBAL_APPLY_MENU
cls
call :SHOW_HEADER "SET GLOBAL ENVIRONMENT"
echo.
echo   %c_GRAY%Press [0] or Enter to return to main menu%c_RESET%
echo.

if %count%==0 (
    call :SHOW_ERROR "No profiles available."
    timeout /t 2 >nul
    goto MAIN_MENU
)

set /p "G_NUM=  %c_WHITE%Select profile to set globally [1-%count%]: %c_RESET%"
if "%G_NUM%"=="" goto MAIN_MENU
if "%G_NUM%"=="0" goto MAIN_MENU

if not defined p_name[%G_NUM%] (
    call :SHOW_ERROR "Invalid profile ID."
    timeout /t 2 >nul
    goto MAIN_MENU
)

set "SEL_NAME=!p_name[%G_NUM%]!"
set "SEL_KEY=!p_key[%G_NUM%]!"
set "SEL_URL=!p_url[%G_NUM%]!"
set "SEL_HAIKU=!p_haiku[%G_NUM%]!"
set "SEL_SONNET=!p_sonnet[%G_NUM%]!"
set "SEL_OPUS=!p_opus[%G_NUM%]!"

:APPLY_CONFIG_EXEC
REM 执行系统变量设置
echo   %c_GRAY%Setting ANTHROPIC_AUTH_TOKEN...%c_RESET%
setx ANTHROPIC_AUTH_TOKEN "%SEL_KEY%" >nul 2>&1
if errorlevel 1 (
    call :SHOW_ERROR "Failed to set ANTHROPIC_AUTH_TOKEN"
    pause
    goto MAIN_MENU
)

echo   %c_GRAY%Setting ANTHROPIC_BASE_URL...%c_RESET%
setx ANTHROPIC_BASE_URL "%SEL_URL%" >nul 2>&1

echo   %c_GRAY%Setting CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC...%c_RESET%
setx CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC "1" >nul 2>&1

echo   %c_GRAY%Setting API_TIMEOUT_MS...%c_RESET%
setx API_TIMEOUT_MS "600000" >nul 2>&1

echo   %c_GRAY%Setting Model Maps...%c_RESET%
if defined SEL_HAIKU (
    setx ANTHROPIC_DEFAULT_HAIKU_MODEL "!SEL_HAIKU!" >nul 2>&1
) else (
    REG DELETE HKCU\Environment /v ANTHROPIC_DEFAULT_HAIKU_MODEL /f >nul 2>&1
)

if defined SEL_SONNET (
    setx ANTHROPIC_DEFAULT_SONNET_MODEL "!SEL_SONNET!" >nul 2>&1
) else (
    REG DELETE HKCU\Environment /v ANTHROPIC_DEFAULT_SONNET_MODEL /f >nul 2>&1
)

if defined SEL_OPUS (
    setx ANTHROPIC_DEFAULT_OPUS_MODEL "!SEL_OPUS!" >nul 2>&1
) else (
    REG DELETE HKCU\Environment /v ANTHROPIC_DEFAULT_OPUS_MODEL /f >nul 2>&1
)

echo.
call :SHOW_SUCCESS "Profile '%SEL_NAME%' activated!"
echo.
echo   %c_YELLOW%IMPORTANT: Restart your terminal/IDE for changes to take effect.%c_RESET%
echo.
pause
goto MAIN_MENU

REM ===================================================================================================
REM 帮助信息
REM ===================================================================================================
:SHOW_HELP
cls
call :SHOW_HEADER "HELP"
echo.
echo   %c_WHITE%Prometheus%c_RESET% - Claude API Profile Manager
echo.
echo   %c_CYAN%What is this?%c_RESET%
echo   A tool to manage multiple Claude API configurations and quickly
echo   switch between them by setting system environment variables.
echo.
echo   %c_CYAN%Commands:%c_RESET%
echo   %c_WHITE%[1-9]%c_RESET%  Launch isolated terminal (Implicit)
echo   %c_WHITE%[N]%c_RESET%    Create a new profile
echo   %c_WHITE%[E]%c_RESET%    Edit an existing profile
echo   %c_WHITE%[D]%c_RESET%    Delete a profile
echo   %c_WHITE%[G]%c_RESET%    Set global environment
echo   %c_WHITE%[T]%c_RESET%    Test API connection
echo   %c_WHITE%[B]%c_RESET%    Backup/Restore profiles
echo   %c_WHITE%[C]%c_RESET%    Clear all profiles
echo   %c_WHITE%[Q]%c_RESET%    Quit
echo   %c_WHITE%[0]%c_RESET%    Return to main menu (in submenus)
echo.
echo   %c_CYAN%Environment Variables Set:%c_RESET%
echo   - ANTHROPIC_AUTH_TOKEN
echo   - ANTHROPIC_BASE_URL
echo   - CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC
echo   - API_TIMEOUT_MS
echo.
echo   %c_CYAN%Tips:%c_RESET%
echo   - %c_GREEN%●%c_RESET% indicates the currently active profile
echo   - API keys are partially hidden for security
echo.
pause
goto MAIN_MENU

REM ===================================================================================================
REM 退出
REM ===================================================================================================
:EXIT_APP
cls
echo.
echo   %c_GOLD%Thanks for using Prometheus!%c_RESET%
echo.
timeout /t 1 >nul
exit /b 0

REM ===================================================================================================
REM 辅助函数
REM ===================================================================================================

:SHOW_HEADER
echo.
echo  %c_GOLD% ┏━┃┏━┃┏━┃┏┏ ┏━┛━┏┛┃ ┃┏━┛┃ ┃┏━┛ %c_RESET%
echo  %c_GOLD% ┏━┛┏┏┛┃ ┃┃┃┃┏━┛ ┃ ┏━┃┏━┛┃ ┃━━┃  %c_RESET%
echo  %c_GOLD% ┛  ┛ ┛━━┛┛┛┛━━┛ ┛ ┛ ┛━━┛━━┛━━┛     %c_RESET%
echo.
echo %c_CYAN%^> %~1%c_RESET%
goto :eof

:SHOW_SUCCESS
echo.
echo   %c_GREEN%✓ %~1%c_RESET%
goto :eof

:SHOW_ERROR
echo.
echo   %c_RED%✗ %~1%c_RESET%
goto :eof

REM ===================================================================================================
REM 快捷指令菜单
REM ===================================================================================================
:SHORTCUT_MENU
:: Reload shortcuts to ensure freshness
set sc_count=0
for /L %%i in (1,1,50) do (
    set "sc_alias[%%i]="
    set "sc_cmd[%%i]="
)
for /f "tokens=2,3 delims=|" %%a in ('findstr /b "::SHORTCUT|" "%~f0"') do (
    set /a sc_count+=1
    set "sc_alias[!sc_count!]=%%a"
    set "sc_cmd[!sc_count!]=%%b"
)

cls
call :SHOW_HEADER "SHORTCUTS MANAGER"
echo.
echo   %c_CYAN%Manage quick commands for your terminal sessions.%c_RESET%
echo.

if %sc_count%==0 (
    echo   %c_GRAY%No shortcuts defined.%c_RESET%
    echo.
) else (
    echo   %c_WHITE%Current Shortcuts:%c_RESET%
    for /L %%i in (1,1,%sc_count%) do (
        echo   %c_WHITE%[%%i]%c_RESET% %c_YELLOW%!sc_alias[%%i]!%c_RESET% = %c_GRAY%!sc_cmd[%%i]!%c_RESET%
    )
    echo.
)

echo   %c_WHITE%[N]%c_RESET% New Shortcut
echo   %c_WHITE%[D]%c_RESET% Delete Shortcut
echo.
echo   %c_GRAY%[0] Back to Main Menu%c_RESET%
echo.

set /p "S_ACTION=  %c_WHITE%Select option: %c_RESET%"

if /i "%S_ACTION%"=="N" goto NEW_SHORTCUT
if /i "%S_ACTION%"=="D" goto DELETE_SHORTCUT
if "%S_ACTION%"=="0" goto MAIN_MENU
goto SHORTCUT_MENU

REM ===================================================================================================
REM 新建快捷指令
REM ===================================================================================================
:NEW_SHORTCUT
cls
call :SHOW_HEADER "NEW SHORTCUT"
echo.
echo   %c_GRAY%Press [0] or Enter to return%c_RESET%
echo.

set "S_ALIAS="
set "S_CMD="

set /p "S_ALIAS=  %c_WHITE%Alias (e.g. myproject): %c_RESET%"
if "%S_ALIAS%"=="" goto SHORTCUT_MENU
if "%S_ALIAS%"=="0" goto SHORTCUT_MENU

:: 验证 Alias 不包含空格或特殊字符
echo %S_ALIAS% | findstr /r "[&|<> ]" >nul && (
    call :SHOW_ERROR "Alias cannot contain spaces or special characters"
    goto NEW_SHORTCUT
)

set /p "S_CMD=  %c_WHITE%Command (e.g. cd /d C:\Projects\MyProject): %c_RESET%"
if "%S_CMD%"=="" goto SHORTCUT_MENU
if "%S_CMD%"=="0" goto SHORTCUT_MENU

:: 保存快捷指令
echo ::SHORTCUT^|!S_ALIAS!^|!S_CMD!>>"%~f0"

call :SHOW_SUCCESS "Shortcut '!S_ALIAS!' added!"
echo   %c_GRAY%Tip: You can use $T to chain commands (e.g. cd path $T claude)%c_RESET%
timeout /t 4 >nul
goto MAIN_MENU

REM ===================================================================================================
REM 删除快捷指令
REM ===================================================================================================
:DELETE_SHORTCUT
cls
call :SHOW_HEADER "DELETE SHORTCUT"
echo.

if %sc_count%==0 (
    call :SHOW_ERROR "No shortcuts to delete."
    timeout /t 2 >nul
    goto SHORTCUT_MENU
)

set /p "DS_NUM=  %c_WHITE%Enter shortcut ID to delete [1-%sc_count%]: %c_RESET%"
if "%DS_NUM%"=="" goto SHORTCUT_MENU
if "%DS_NUM%"=="0" goto SHORTCUT_MENU

if not defined sc_alias[%DS_NUM%] (
    call :SHOW_ERROR "Invalid ID."
    timeout /t 2 >nul
    goto SHORTCUT_MENU
)

set "DEL_ALIAS=!sc_alias[%DS_NUM%]!"
set "DEL_CMD=!sc_cmd[%DS_NUM%]!"

set "S_TARGET=::SHORTCUT|%DEL_ALIAS%|%DEL_CMD%"
findstr /v /c:"%S_TARGET%" "%~f0" > "%~f0.tmp"
move /y "%~f0.tmp" "%~f0" >nul

call :SHOW_SUCCESS "Shortcut '%DEL_ALIAS%' deleted."
timeout /t 2 >nul
goto SHORTCUT_MENU

REM ===================================================================================================
REM DATA SECTION (DO NOT EDIT MANUALLY)
REM ===================================================================================================
