@echo off
set var1=%~dp0
echo ��װĿ¼
FOR /F "tokens=2*" %%i IN ('reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\PPStream.exe" /v path') DO set path_result=%%j
FOR /F "delims=\ tokens=1" %%k IN ("%path_result%") DO set disk_result=%%k
%disk_result% 
echo ���ƽ�������
dir /a-d /b "%path_result%\LStyle\*.exe" >> "%var1%"\Process.txt
dir /a-d /b "%path_result%\Common\*.exe" >> "%var1%"\Process.txt
echo ɾ������
cd /d %var1%
for /f "delims=" %%a in (Process.txt) do (taskkill /f /im %%a
)

echo ɾ���ļ��еı�����
echo ɾ���������ļ�
cd /d %appdata%\IQIYI Video\LStyle
del /s/q PPStream.ini

echo ɾ�������ĵ�
cd /d %var1%
del /s/q Process.txt
echo ���̽������