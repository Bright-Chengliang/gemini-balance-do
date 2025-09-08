@echo off
setlocal enabledelayedexpansion

set "PORT_TO_KILL=3457"
set "PIDS_FOUND="
set "PROCESS_COUNT=0"

echo 正在查找占用端口 %PORT_TO_KILL% 的进程...

:: 使用 netstat 查找占用指定端口的 PID
:: -a 显示所有连接和侦听端口
:: -n 以数字形式显示地址和端口号
:: -o 显示每个连接的进程 ID
:: findstr 过滤出包含 "LISTENING" 状态和端口号的行
for /f "tokens=5" %%p in ('netstat -ano ^| findstr /i "LISTENING" ^| findstr ":%PORT_TO_KILL%"') do (
    :: 确保 PID 不是空的，并且排除系统进程的 PID 0
    if not "%%p" == "0" (
        set "PIDS_FOUND=!PIDS_FOUND! %%p"
        set /a PROCESS_COUNT+=1
    )
)

if %PROCESS_COUNT% equ 0 (
    echo 没有找到占用端口 %PORT_TO_KILL% 的进程。
) else (
    echo 找到 %PROCESS_COUNT% 个占用端口 %PORT_TO_KILL% 的进程，PID 如下：%PIDS_FOUND%
    echo.
    echo 正在尝试终止这些进程...

    :: 遍历找到的 PIDs 并使用 taskkill 终止它们
    for %%i in (%PIDS_FOUND%) do (
        echo 正在终止 PID %%i ...
        taskkill /PID %%i /F
        if !errorlevel! equ 0 (
            echo 进程 %%i 已成功终止。
        ) else (
            echo 终止进程 %%i 失败。错误代码：!errorlevel!
            echo 可能是因为权限不足，或者进程已经终止。
        )
    )
)

echo.
echo 操作完成。
endlocal
pause
