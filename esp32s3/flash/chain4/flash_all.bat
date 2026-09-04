@echo off
REM ===================================================================
REM  CHAIN4 -- flash all four boards at once, each on its own USB port.
REM
REM  Put this file in Downloads\chain4\ , with the three bins of each
REM  board in its own sub-folder:
REM      chain4\pos1\bootloader.bin partitiontable.bin juno_s3.bin
REM      chain4\pos2\ ...  pos3\ ...  pos4\ ...
REM
REM  Set the four COM ports below to match Device Manager, then run:
REM      flash_all.bat
REM
REM  Each board flashes in its own window. A window that stays open with
REM  an error is the board that failed -- read it, the others are done.
REM ===================================================================

set PORT1=COM3
set PORT2=COM4
set PORT3=COM5
set PORT4=COM6

set ARGS=-b 460800 --before default-reset --after hard-reset write-flash --flash-mode dio --flash-size 8MB --flash-freq 80m 0x0 bootloader.bin 0x8000 partitiontable.bin 0x10000 juno_s3.bin

echo Flashing 4 boards: %PORT1% %PORT2% %PORT3% %PORT4%

start "pos1 %PORT1%" cmd /k "cd /d %~dp0pos1 && python -m esptool --chip esp32s3 -p %PORT1% %ARGS% && echo. && echo POS1 OK && timeout /t 5 && exit"
start "pos2 %PORT2%" cmd /k "cd /d %~dp0pos2 && python -m esptool --chip esp32s3 -p %PORT2% %ARGS% && echo. && echo POS2 OK && timeout /t 5 && exit"
start "pos3 %PORT3%" cmd /k "cd /d %~dp0pos3 && python -m esptool --chip esp32s3 -p %PORT3% %ARGS% && echo. && echo POS3 OK && timeout /t 5 && exit"
start "pos4 %PORT4%" cmd /k "cd /d %~dp0pos4 && python -m esptool --chip esp32s3 -p %PORT4% %ARGS% && echo. && echo POS4 OK && timeout /t 5 && exit"

echo.
echo Four windows opened. Each closes itself when its board is done.
echo A window that STAYS OPEN shows the error for that board.
