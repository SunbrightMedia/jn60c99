@echo off
setlocal
REM ===================================================================
REM  CHAIN4 ONE-SHOT TEST -- flash all four boards, capture all four
REM  consoles for 100 s into ONE file, then close itself.
REM
REM  1. Set the four COM ports below (Device Manager -> Ports).
REM     PORT1 = the pos1 board (DAC end).
REM  2. Double-click this file. Wait ~3 minutes. The window closes.
REM  3. Send chain4_log.txt (created next to this file).
REM
REM  The robot-off key 'r' is sent to POS1 automatically at t=25 s.
REM ===================================================================

set PORT1=COM3
set PORT2=COM4
set PORT3=COM5
set PORT4=COM6

cd /d %~dp0
del chain4_log.txt 2>nul

set ARGS=-b 460800 --before default-reset --after hard-reset write-flash --flash-mode dio --flash-size 8MB --flash-freq 80m 0x0 bootloader.bin 0x8000 partitiontable.bin 0x10000 juno_s3.bin

echo Flashing 4 boards, then capturing 100 s. Total about 3 minutes.
for %%P in (1 2 3 4) do call :flashone %%P
echo ==== CAPTURE (100 s, all four consoles) ====>> chain4_log.txt
python capture.py %PORT1% %PORT2% %PORT3% %PORT4% 3600 0
echo ==== RUN COMPLETE ====>> chain4_log.txt
exit

:flashone
call set THISPORT=%%PORT%1%%
echo ==== FLASH POS%1 on %THISPORT% ====>> chain4_log.txt
pushd pos%1
python -m esptool --chip esp32s3 -p %THISPORT% %ARGS% >> ..\chain4_log.txt 2>&1
if errorlevel 1 echo *** FLASH POS%1 FAILED -- see above *** >> ..\chain4_log.txt
popd
goto :eof
