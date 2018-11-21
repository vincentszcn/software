@echo off
set var1=%~dp0
echo 安装目录
FOR /F "tokens=2*" %%i IN ('reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\PPStream.exe" /v path') DO set path_result=%%j
FOR /F "delims=\ tokens=1" %%k IN ("%path_result%") DO set disk_result=%%k
%disk_result% 
echo 复制进程名称
dir /a-d /b "%path_result%\LStyle\*.exe" >> "%var1%"\Process.txt
dir /a-d /b "%path_result%\Common\*.exe" >> "%var1%"\Process.txt
echo 删除进程
cd /d %var1%
for /f "delims=" %%a in (Process.txt) do (taskkill /f /im %%a
)

echo 删除文件中的崩溃数
echo 删除该配置文件
cd /d %appdata%\IQIYI Video\LStyle
del /s/q PPStream.ini

echo 删除多余文档
cd /d %var1%
del /s/q Process.txt
echo 进程结束完毕