@echo off
::::::::::::::::::::::::::::
:����Ҫ����ԱȨ��
:����д��һ��ע����ļ�
:�����û�������Ҫ���ĵĶ˿ں�
:����������Ҫʮ���������ݣ������û������¼���������Ҫ��һ��ת������
:ת����Ϻ����д��ע���Ȼ�����и�ע������ɾ��
echo Windows Registry Editor Version 5.00 >t1.reg
echo.
echo [HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp] >>t1.reg
:::::::::::::::::::::::::::::::::::::ʮ����ת��ʮ������
setlocal enabledelayedexpansion
set hexstr=0 1 2 3 4 5 6 7 8 9 A B C D E F
set d=0
for %%i in (%hexstr%) do (set d!d!=%%i&set/a d+=1)
set/p scanf=��������Ҫ�ı��RDP�˿ںţ����ɳ���65535��
if not defined scanf exit/b
set dec=%scanf%
call :d2h
if not defined hex set hex=0
::echo %dec% ��ʮ������Ϊ��0x%hex%
echo "PortNumber"=dword:0%hex% >>t1.reg
regedit /s t1.reg
del /q t1.reg
:d2h
if %scanf% equ 0 exit/b
set/a tscanf=%scanf%"&"15
set/a scanf">>="4
set hex=!d%tscanf%!!hex!
goto :d2h