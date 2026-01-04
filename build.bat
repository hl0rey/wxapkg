@echo off
setlocal enabledelayedexpansion

REM wxapkg 编译脚本 (Windows)
REM 支持多平台交叉编译

title wxapkg 编译脚本

REM 版本信息
if "%VERSION%"=="" set VERSION=v0.0.1
for /f "delims=" %%i in ('git rev-parse --short HEAD 2^>nul') do set COMMIT=%%i
if "%COMMIT%"=="" set COMMIT=dev

REM 输出目录
set OUTPUT_DIR=dist

REM 颜色代码（使用 PowerShell 实现彩色输出）
set "GREEN=[92m"
set "YELLOW=[93m"
set "BLUE=[94m"
set "RED=[91m"
set "NC=[0m"

echo.
echo ======================================
echo        wxapkg 编译脚本
echo ======================================
echo.

REM 检查 Go 环境
where go >nul 2>&1
if %errorlevel% neq 0 (
    echo [错误] 未找到 Go 编译器，请先安装 Go
    exit /b 1
)

REM 解析命令
set COMMAND=%1
if "%COMMAND%"=="" set COMMAND=current

if "%COMMAND%"=="all" goto build_all
if "%COMMAND%"=="current" goto build_current
if "%COMMAND%"=="clean" goto clean
if "%COMMAND%"=="install" goto install
if "%COMMAND%"=="help" goto show_help
if "%COMMAND%"=="-h" goto show_help
if "%COMMAND%"=="--help" goto show_help

echo [错误] 未知命令: %COMMAND%
echo.
goto show_help

:clean
echo [+] 清理旧的编译文件...
if exist %OUTPUT_DIR% rmdir /s /q %OUTPUT_DIR%
echo [√] 清理完成
goto :eof

:build_platform
set GOOS=%~1
set GOARCH=%~2
set OUTPUT_NAME=%~3

echo [*] 编译 %GOOS%/%GOARCH%...

REM 设置输出文件名
set BINARY_NAME=wxapkg
if "%GOOS%"=="windows" set BINARY_NAME=wxapkg.exe

set OUTPUT_PATH=%OUTPUT_DIR%\%OUTPUT_NAME%\%BINARY_NAME%

REM 创建输出目录
if not exist "%OUTPUT_DIR%\%OUTPUT_NAME%" mkdir "%OUTPUT_DIR%\%OUTPUT_NAME%"

REM 编译参数
set LDFLAGS=-s -w -X main.version=%VERSION% -X main.commit=%COMMIT%

REM 执行编译
set CGO_ENABLED=0
go build -trimpath -ldflags "%LDFLAGS%" -o "%OUTPUT_PATH%" .

if %errorlevel% equ 0 (
    echo [√] 编译成功: %OUTPUT_PATH%
    
    REM 创建压缩包
    cd "%OUTPUT_DIR%\%OUTPUT_NAME%"
    if "%GOOS%"=="windows" (
        powershell -command "Compress-Archive -Path '%BINARY_NAME%' -DestinationPath '..\%OUTPUT_NAME%.zip' -Force" >nul 2>&1
        echo [√] 创建压缩包: %OUTPUT_DIR%\%OUTPUT_NAME%.zip
    ) else (
        REM 在 Windows 上为其他平台创建 zip
        powershell -command "Compress-Archive -Path '%BINARY_NAME%' -DestinationPath '..\%OUTPUT_NAME%.zip' -Force" >nul 2>&1
        echo [√] 创建压缩包: %OUTPUT_DIR%\%OUTPUT_NAME%.zip
    )
    cd ..\..
) else (
    echo [×] 编译失败: %GOOS%/%GOARCH%
    exit /b 1
)
goto :eof

:build_all
echo [+] 开始编译所有平台...
echo 版本: %VERSION%
echo 提交: %COMMIT%
echo.

call :clean

REM Windows
call :build_platform windows amd64 wxapkg-windows-amd64

REM macOS
call :build_platform darwin amd64 wxapkg-darwin-amd64
call :build_platform darwin arm64 wxapkg-darwin-arm64

REM Linux
call :build_platform linux amd64 wxapkg-linux-amd64
call :build_platform linux arm64 wxapkg-linux-arm64

echo.
echo [√] 所有平台编译完成！
echo.
echo 编译产物:
dir /b %OUTPUT_DIR%\*.zip 2>nul
goto end

:build_current
echo [+] 编译当前平台...
echo 版本: %VERSION%
echo 提交: %COMMIT%
echo.

if not exist %OUTPUT_DIR% mkdir %OUTPUT_DIR%

for /f "tokens=*" %%i in ('go env GOOS') do set GOOS=%%i
for /f "tokens=*" %%i in ('go env GOARCH') do set GOARCH=%%i

call :build_platform !GOOS! !GOARCH! wxapkg-!GOOS!-!GOARCH!
goto end

:install
echo [+] 编译并安装到本地...

set LDFLAGS=-s -w -X main.version=%VERSION% -X main.commit=%COMMIT%

go install -trimpath -ldflags "%LDFLAGS%" .

if %errorlevel% equ 0 (
    echo [√] 安装成功！
    for /f "tokens=*" %%i in ('where wxapkg') do echo 安装位置: %%i
    wxapkg --version
) else (
    echo [×] 安装失败
    exit /b 1
)
goto end

:show_help
echo wxapkg 编译脚本
echo.
echo 用法: build.bat [命令]
echo.
echo 命令:
echo   all       编译所有平台 (Windows, macOS, Linux)
echo   current   编译当前平台
echo   clean     清理编译产物
echo   install   编译并安装到本地 GOPATH
echo   help      显示此帮助信息
echo.
echo 选项:
echo   VERSION   设置版本号 (默认: v0.0.1)
echo             示例: set VERSION=v1.0.0 ^&^& build.bat all
echo.
echo 示例:
echo   build.bat all              # 编译所有平台
echo   build.bat current          # 编译当前平台
echo   build.bat clean            # 清理编译产物
echo   build.bat install          # 安装到本地
echo.
goto end

:end
echo.
endlocal

