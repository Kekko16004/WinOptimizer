@echo off
setlocal EnableDelayedExpansion
title PC Optimizer Ultimate v3 - Aggressive Edition
color 0A
chcp 65001 >nul

:: ============================================================
::  PC OPTIMIZER ULTIMATE v3 - AGGRESSIVE EDITION
::  Universale Windows 10/11 - 32/64 bit - portatili e fissi
::  - Servizi inutili + telemetria + pulizia (modalita sicura)
::  - MODALITA AGGRESSIVA: Defender permanentemente OFF,
::    SmartScreen OFF, Windows Update completamente OFF
::  - Opzione 7: attiva/disattiva creazione punti di ripristino
::    (su PC vecchi con dischi lenti mette TROPPO tempo)
::  - Tutto reversibile via RIPRISTINO_OPTIMIZER.bat
:: ============================================================

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo  [!] Servono permessi da Amministratore.
    powershell -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

set "RESTORE=%~dp0RIPRISTINO_OPTIMIZER.bat"
set "SKIPRP=%~dp0.skip_restorepoint"

if not exist "%RESTORE%" (
    >"%RESTORE%" echo @echo off
    >>"%RESTORE%" echo title Ripristino servizi PC Optimizer
    >>"%RESTORE%" echo chcp 65001 ^>nul
    >>"%RESTORE%" echo color 0C
    >>"%RESTORE%" echo net session ^>nul 2^>^&1 ^|^| ^(powershell -Command "Start-Process -FilePath '%%~f0' -Verb RunAs" ^& exit /b^)
    >>"%RESTORE%" echo echo Ripristino in corso...
    >>"%RESTORE%" echo echo NON chiudere questa finestra.
)

echo.
echo  ============================================================
echo    PC OPTIMIZER ULTIMATE v3 - AGGRESSIVE EDITION
echo  ============================================================
echo   Ripristino disponibile: %RESTORE%
echo  ============================================================
echo.

:MENU
if exist "%SKIPRP%" (
    set "RPSTATO=DISATTIVATA - non verra creato nessun punto di ripristino"
) else (
    set "RPSTATO=ATTIVA - viene creato il punto di ripristino prima delle modifiche"
)
echo  ------------------------------------------------------------
echo   [1] OTTIMIZZAZIONE RAPIDA - tutto il sicuro + pulizia
echo   [2] MODALITA GUIDATA - scegli categoria per categoria
echo   [3] Solo pulizia file temporanei e cache
echo   [4] Solo servizi EXTRA - Xbox, stampa, biometria, ricerca
echo   [5] MODALITA AGGRESSIVA - Defender OFF per sempre,
echo       SmartScreen OFF, Windows Update OFF. Chiede conferma.
echo   [6] Esegui RIPRISTINO completo adesso
echo   [7] Creazione punti di ripristino: !RPSTATO!
echo       cambiala se il PC e vecchio e ci mette troppo
echo   [0] Esci
echo  ------------------------------------------------------------
choice /c 12345670 /n /m "   Cosa vuoi fare? "
if errorlevel 8 goto :FINE
if errorlevel 7 goto :TOGGLERP
if errorlevel 6 goto :DORIPRISTINO
if errorlevel 5 goto :AGGRESSIVA
if errorlevel 4 goto :EXTRA
if errorlevel 3 goto :PULIZIA
if errorlevel 2 goto :GUIDATA
if errorlevel 1 goto :RAPIDA

:TOGGLERP
if exist "%SKIPRP%" (
    del /f /q "%SKIPRP%" >nul 2>&1
    echo  [OK] Creazione punti di ripristino RIATTIVATA.
) else (
    >"%SKIPRP%" echo skip
    echo  [OK] Creazione punti di ripristino DISATTIVATA.
    echo       Ora le ottimizzazioni partono subito senza attese.
)
echo  [i] Nota: il file di ripristino RIPRISTINO_OPTIMIZER.bat
       continuera a funzionare comunque - quello e indipendente.
pause
goto :MENU

:: ============================================================
:: [1] OTTIMIZZAZIONE RAPIDA
:: ============================================================
:RAPIDA
call :PUNTORIPRISTINO
echo.
echo  [FASE 1/5] Disabilitazione servizi SICURI...
call :DISABLE DiagTrack
call :DISABLE dmwappushservice
call :DISABLE MapsBroker
call :DISABLE Fax
call :DISABLE RemoteRegistry
call :DISABLE RetailDemo
call :DISABLE SharedAccess
call :DISABLE WMPNetworkSvc
call :DISABLE TrkWks
call :DISABLE SEMgrSvc
call :DISABLE PhoneSvc
call :DISABLE SCardSvr
call :DISABLE SCPolicySvc
call :DISABLE WalletService
call :DISABLE WpcMonSvc
echo  [OK] Servizi sicuri disabilitati.

echo  [FASE 2/5] Disabilitazione telemetria e attivita in background...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v AllowTelemetry /t REG_DWORD /d 0 /f >nul 2>&1
schtasks /change /tn "\Microsoft\Windows\Customer Experience Improvement Program\Consolidator" /disable >nul 2>&1
schtasks /change /tn "\Microsoft\Windows\Customer Experience Improvement Program\UsbCeip" /disable >nul 2>&1
schtasks /change /tn "\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser" /disable >nul 2>&1
schtasks /change /tn "\Microsoft\Windows\Application Experience\ProgramDataUpdater" /disable >nul 2>&1
schtasks /change /tn "\Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector" /disable >nul 2>&1
echo  [OK] Telemetria ridotta al minimo.

echo  [FASE 3/5] Effetti visivi e trasparenze...
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" /v VisualFXSetting /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v EnableTransparency /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SystemPaneSuggestionsEnabled /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SilentInstalledAppsEnabled /t REG_DWORD /d 0 /f >nul 2>&1
echo  [OK] Effetti visivi su prestazioni ottimali.

echo  [FASE 4/5] Piano energetico ALTE PRESTAZIONI...
powercfg /setactive SCHEME_MIN >nul 2>&1
echo  [OK] Piano energetico attivato se disponibile.

echo  [FASE 5/5] Pulizia file temporanei...
call :PULIZIA_ONLY
echo.
echo  ============================================================
echo   COMPLETATO! Riavvia il PC per applicare tutto.
echo  ============================================================
pause
goto :MENU

:: ============================================================
:: [2] MODALITA GUIDATA
:: ============================================================
:GUIDATA
call :PUNTORIPRISTINO
echo.
echo  === SERVIZI ===
call :CHIEDI "Disabilitare DiagTrack e servizi telemetria"
if errorlevel 1 (
    call :DISABLE DiagTrack
    call :DISABLE dmwappushservice
    schtasks /change /tn "\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser" /disable >nul 2>&1
)
call :CHIEDI "Disabilitare SysMain/Superfetch - utile se poca RAM e CPU debole"
if errorlevel 1 call :DISABLE SysMain
call :CHIEDI "Disabilitare Ricerca Windows indicizzazione WSearch - CPU killer su PC vecchi"
if errorlevel 1 call :DISABLE WSearch
call :CHIEDI "Disabilitare Stampa Spooler - SOLO se non stampi MAI da questo PC"
if errorlevel 1 call :DISABLE Spooler
call :CHIEDI "Disabilitare servizi XBOX - SOLO se non usi Xbox Game Bar"
if errorlevel 1 (
    call :DISABLE XblAuthManager
    call :DISABLE XblGameSave
    call :DISABLE XboxNetApiSvc
    call :DISABLE XboxGipSvc
)
call :CHIEDI "Disabilitare Biometria WbioSrvc - SOLO se non usi impronta digitale"
if errorlevel 1 call :DISABLE WbioSrvc
call :CHIEDI "Disabilitare Segnalazioni errori WerSvc"
if errorlevel 1 call :DISABLE WerSvc
call :CHIEDI "Disabilitare Diagnostica aggressiva DPS WdiSystemHost WdiServiceHost"
if errorlevel 1 (
    call :DISABLE DPS
    call :DISABLE WdiSystemHost
    call :DISABLE WdiServiceHost
)
call :CHIEDI "Disabilitare servizi Tablet/Penna TabletInputService - su PC senza touch"
if errorlevel 1 call :DISABLE TabletInputService

echo.
echo  === EFFETTI, AVVIO E PULIZIA ===
call :CHIEDI "Impostare effetti visivi su prestazioni ottimali e togliere trasparenze"
if errorlevel 1 (
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" /v VisualFXSetting /t REG_DWORD /d 2 /f >nul 2>&1
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v EnableTransparency /t REG_DWORD /d 0 /f >nul 2>&1
    echo   [OK] Effetti ridotti.
)
call :CHIEDI "Attivare piano energetico Alte Prestazioni - consuma piu batteria"
if errorlevel 1 (
    powercfg /setactive SCHEME_MIN >nul 2>&1
    echo   [OK] Piano energetico attivato se disponibile.
)
call :CHIEDI "Disabilitare app all'avvio non essenziali - guidedo con Task Manager"
if errorlevel 1 call :STARTUP
call :CHIEDI "Pulire file temporanei e cache adesso"
if errorlevel 1 call :PULIZIA_ONLY
echo.
echo  [OK] MODALITA GUIDATA COMPLETATA! Riavvia il PC.
pause
goto :MENU

:: ============================================================
:: [3] SOLO PULIZIA
:: ============================================================
:PULIZIA
call :PULIZIA_ONLY
echo.
echo  [OK] Pulizia completata.
pause
goto :MENU

:: ============================================================
:: [4] SERVIZI EXTRA
:: ============================================================
:EXTRA
call :PUNTORIPRISTINO
echo.
call :DISABLE SysMain
call :DISABLE WSearch
call :DISABLE WerSvc
call :DISABLE XblAuthManager
call :DISABLE XblGameSave
call :DISABLE XboxNetApiSvc
call :DISABLE XboxGipSvc
call :DISABLE WbioSrvc
call :DISABLE TabletInputService
echo.
echo  [OK] Servizi extra disabilitati. Riavvia il PC.
pause
goto :MENU

:: ============================================================
:: [5] MODALITA AGGRESSIVA
:: ============================================================
:AGGRESSIVA
color 0C
echo.
echo  ============================================================
echo    ATTENZIONE - MODALITA AGGRESSIVA
echo  ============================================================
echo   Questa modalita disattiva PERMANENTEMENTE:
echo    - Windows Defender real-time protection
echo    - SmartScreen
echo    - Windows Update completamente
echo   Il PC sara MOLTO piu veloce ma sara SENZA protezione
echo   antivirus. Usalo solo se lo sai: se poi apri email strane
echo   o scarichi exe da siti loschi il rischio e tuo.
echo   Tutto resta ripristinabile con RIPRISTINO_OPTIMIZER.bat
echo  ============================================================
echo.
echo   Passaggio 0 - OBBLIGATORIO fatto da te a mano:
echo   Apri - Sicurezza di Windows - Protezione da virus e minacce
echo   - Gestisci impostazioni - spegni PROTEZIONE DA
echo   MANOMISSIONI Tamper Protection.
echo   Senza questo passo Windows si riattivera tutto da solo.
echo.
set /p CONF="   Per conferm
