@echo off
setlocal EnableDelayedExpansion
title PC Optimizer Ultimate v2 - Aggressive Edition
color 0A
chcp 65001 >nul

:: ============================================================
::  WIN OPTIMIZER 
::  Universale Windows 10/11 - 32/64 bit - portatili e fissi
::  - Servizi inutili + telemetria + pulizia (modalita sicura)
::  - MODALITA AGGRESSIVA: Defender permanentemente OFF,
::    SmartScreen OFF, Windows Update completamente OFF
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
echo    PC OPTIMIZER ULTIMATE v2 - AGGRESSIVE EDITION
echo  ============================================================
echo   Ripristino disponibile: %RESTORE%
echo  ============================================================
echo.

:MENU
echo  ------------------------------------------------------------
echo   [1] OTTIMIZZAZIONE RAPIDA - tutto il sicuro + pulizia
echo   [2] MODALITA GUIDATA - scegli categoria per categoria
echo   [3] Solo pulizia file temporanei e cache
echo   [4] Solo servizi EXTRA - Xbox, stampa, biometria, ricerca
echo   [5] MODALITA AGGRESSIVA - Defender OFF per sempre,
echo       SmartScreen OFF, Windows Update OFF. Chiede conferma.
echo   [6] Esegui RIPRISTINO completo adesso
echo   [0] Esci
echo  ------------------------------------------------------------
choice /c 1234560 /n /m "   Cosa vuoi fare? "
if errorlevel 7 goto :FINE
if errorlevel 6 goto :DORIPRISTINO
if errorlevel 5 goto :AGGRESSIVA
if errorlevel 4 goto :EXTRA
if errorlevel 3 goto :PULIZIA
if errorlevel 2 goto :GUIDATA
if errorlevel 1 goto :RAPIDA

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
set /p CONF="   Per confermare digita esattamente SI e premi Invio: "
if /i not "%CONF%"=="SI" (
    echo   [!] Conferma non ricevuta. Annullo tutto.
    color 0A
    pause
    goto :MENU
)
color 0A
call :PUNTORIPRISTINO

echo.
echo  [AGGR 1/4] Windows Defender - disattivazione permanente...
reg export "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" "%~dp0backup_defender_policy.reg" /y >nul 2>&1
>>"%RESTORE%" echo reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v DisableAntiSpyware /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v DisableRealtimeMonitoring /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v DisableBehaviorMonitoring /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v DisableOnAccessProtection /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v DisableScanOnRealtimeEnable /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v DisableIOAVProtection /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" /v SpynetReporting /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" /v SubmitSamplesConsent /t REG_DWORD /d 0 /f >nul 2>&1
powershell -Command "Set-MpPreference -DisableRealtimeMonitoring $true -ErrorAction SilentlyContinue" >nul 2>&1
schtasks /change /tn "\Microsoft\Windows\Windows Defender\Windows Defender Cache Maintenance" /disable >nul 2>&1
schtasks /change /tn "\Microsoft\Windows\Windows Defender\Windows Defender Cleanup" /disable >nul 2>&1
schtasks /change /tn "\Microsoft\Windows\Windows Defender\Windows Defender Scheduled Scan" /disable >nul 2>&1
schtasks /change /tn "\Microsoft\Windows\Windows Defender\Windows Defender Verification" /disable >nul 2>&1
echo  [OK] Policy anti-Defender applicate - permanente.

echo  [AGGR 2/4] SmartScreen completamente OFF...
>>"%RESTORE%" echo reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" /v SmartScreenEnabled /t REG_SZ /d "On" /f
>>"%RESTORE%" echo reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer" /v SmartScreenEnabled /t REG_SZ /d "On" /f
>>"%RESTORE%" echo reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v EnableSmartScreen /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" /v SmartScreenEnabled /t REG_SZ /d "Off" /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer" /v SmartScreenEnabled /t REG_SZ /d "Off" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v EnableSmartScreen /t REG_DWORD /d 0 /f >nul 2>&1
echo  [OK] SmartScreen disattivato.

echo  [AGGR 3/4] Windows Update completamente OFF...
reg export "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" "%~dp0backup_wu_policy.reg" /y >nul 2>&1
>>"%RESTORE%" echo reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v NoAutoUpdate /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v DoNotConnectToWindowsUpdateInternetLocations /t REG_DWORD /d 1 /f >nul 2>&1
call :DISABLE wuauserv
call :DISABLE UsoSvc
reg add "HKLM\SYSTEM\CurrentControlSet\Services\WaaSMedicSvc" /v Start /t REG_DWORD /d 4 /f >nul 2>&1
>>"%RESTORE%" echo reg add "HKLM\SYSTEM\CurrentControlSet\Services\WaaSMedicSvc" /v Start /t REG_DWORD /d 3 /f
schtasks /change /tn "\Microsoft\Windows\UpdateOrchestrator\Schedule Scan" /disable >nul 2>&1
schtasks /change /tn "\Microsoft\Windows\UpdateOrchestrator\Schedule Wake To Work" /disable >nul 2>&1
schtasks /change /tn "\Microsoft\Windows\UpdateOrchestrator\Universal Orchestrator Start" /disable >nul 2>&1
schtasks /change /tn "\Microsoft\Windows\WindowsUpdate\Scheduled Start" /disable >nul 2>&1
echo  [OK] Windows Update spento - servizi, task pianificati e policy.

echo  [AGGR 4/4] Servizi pesanti vari...
call :DISABLE SysMain
call :DISABLE WSearch
call :DISABLE DPS
call :DISABLE WdiSystemHost
call :DISABLE WdiServiceHost
call :DISABLE WerSvc
call :DISABLE WalletService
call :DISABLE MapsBroker
echo.
echo  ============================================================
echo   MODALITA AGGRESSIVA COMPLETATA!
echo   Riavvia il PC. Defender NON si riattivera da solo
echo   perche le policy sono permanenti - a patto che tu abbia
echo   spento Tamper Protection come al Passaggio 0.
echo   Ripristino: RIPRISTINO_OPTIMIZER.bat nella stessa cartella.
echo  ============================================================
pause
goto :MENU

:: ============================================================
:: [6] RIPRISTINO
:: ============================================================
:DORIPRISTINO
echo.
call "%RESTORE%"
echo  [OK] Ripristino eseguito. Riavvia il PC.
pause
goto :MENU

:: ============================================================
:: FUNZIONI
:: ============================================================

:DISABLE
sc query "%~1" >nul 2>&1
if !errorlevel! neq 0 (
    echo   [-] %~1 non presente su questo PC, salto.
    goto :EOF
)
for /f "tokens=3" %%s in ('sc qc "%~1" 2^>nul ^| find "START_TYPE"') do (
    >>"%RESTORE%" echo sc config "%~1" start= %%s
    >>"%RESTORE%" echo net start "%~1"
)
net stop "%~1" >nul 2>&1
sc config "%~1" start= disabled >nul 2>&1
echo   [OK] %~1 DISABILITATO
goto :EOF

:CHIEDI
choice /c SN /n /m "  ? %~1 - S/N "
goto :EOF

:PULIZIA_ONLY
echo   Pulizia cartella utente TEMP...
del /f /s /q "%TEMP%\*" >nul 2>&1
for /d %%d in ("%TEMP%\*") do rd /s /q "%%d" >nul 2>&1
echo   Pulizia C:\Windows\Temp...
del /f /s /q "C:\Windows\Temp\*" >nul 2>&1
for /d %%d in ("C:\Windows\Temp\*") do rd /s /q "%%d" >nul 2>&1
echo   Pulizia Prefetch...
del /f /q "C:\Windows\Prefetch\*" >nul 2>&1
echo   Pulizia cache download Windows Update...
del /f /s /q "C:\Windows\SoftwareDistribution\Download\*" >nul 2>&1
echo   Pulizia minidump e tmp...
del /f /q "C:\Windows\Minidump\*" >nul 2>&1
del /f /q "%SystemRoot%\*.tmp" >nul 2>&1
echo   Svuotamento Cestino...
powershell -Command "Clear-RecycleBin -Force -ErrorAction SilentlyContinue" >nul 2>&1
echo   Flush DNS...
ipconfig /flushdns >nul 2>&1
echo   [OK] Pulizia eseguita.
goto :EOF

:STARTUP
reg export "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" "%~dp0backup_run_hkcu.reg" /y >nul 2>&1
reg export "HKLM\Software\Microsoft\Windows\CurrentVersion\Run" "%~dp0backup_run_hklm.reg" /y >nul 2>&1
echo   Backup chiavi avvio salvati: backup_run_hkcu.reg / backup_run_hklm.reg
echo   Voci attuali all'avvio:
for /f "tokens=1,* delims=" %%a in ('reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" 2^>nul ^| findstr /i /v "HKEY_"') do echo    - %%a
echo   Disattiva le non essenziali da Task Manager - Avvio.
goto :EOF

:PUNTORIPRISTINO
echo  [i] Creazione punto di ripristino - attendi 1-2 minuti...
powershell -Command "Enable-ComputerRestore -Drive 'C:\' -ErrorAction SilentlyContinue; Checkpoint-Computer -Description 'Prima di PC Optimizer' -RestorePointType 'MODIFY_SETTINGS' -ErrorAction SilentlyContinue" >nul 2>&1
echo  [OK] Punto di ripristino creato se la protezione sistema era attiva.
goto :EOF

:FINE
endlocal
exit /b
