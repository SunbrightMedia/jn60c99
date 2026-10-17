@echo off
cd /d "%~dp0"
echo Running the BOSS product tracer... (this takes a moment)
boss_trace_host.exe "C:\Program Files\Common Files\VST3\Roland\BOSS Effects Pedals\BOSS Effects Pedals.vst3" executed_rvas.txt
echo.
echo ================================================================
echo Done. Send the file  executed_rvas.txt  (in this folder) back to Claude.
echo ================================================================
pause
