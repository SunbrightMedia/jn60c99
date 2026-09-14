@echo off
REM THE UNATTENDED BENCH -- double-click once, then walk away.
REM If bench.py ever exits, this restarts it after 30 s.
cd /d %~dp0
:loop
python bench.py
echo bench.py exited -- restarting in 30 s (Ctrl+C to stop)
timeout /t 30 >nul
goto loop
