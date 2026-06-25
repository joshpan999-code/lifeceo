@echo off
echo =====================================
echo  人生CEO - 生成 Android 签名密钥库
echo =====================================
echo.

REM 检查 Java 是否安装
java -version >nul 2>&1
if %errorlevel% neq 0 (
    echo [错误] 未找到 Java，请先安装 JDK 17+
    echo 下载地址: https://www.oracle.com/java/technologies/downloads/
    echo 或使用 OpenJDK: https://adoptium.net/
    pause
    exit /b 1
)

echo [1/3] Java 已检测到
echo.

REM 设置密钥库信息
set KEYSTORE_PATH=app\lifeceo-release-key.keystore
set KEY_ALIAS=lifeceo
set VALIDITY=10000

echo [2/3] 开始生成密钥库...
echo.
echo 请按照提示输入以下信息：
echo   - 密钥库密码（记住这个密码！）
echo   - 确认密码
echo   - 姓名（可以是花名或真名）
echo   - 组织单位（可选）
echo   - 组织名称（可选）
echo   - 城市（可选）
echo   - 省份（可选）
echo   - 国家代码（CN）
echo.

keytool -genkey -v ^
  -keystore %KEYSTORE_PATH% ^
  -alias %KEY_ALIAS% ^
  -keyalg RSA ^
  -keysize 2048 ^
  -validity %VALIDITY%

if %errorlevel% equ 0 (
    echo.
    echo [3/3] ✅ 密钥库生成成功！
    echo 位置: %CD%\%KEYSTORE_PATH%
    echo.
    echo ⚠️  重要提醒：
    echo    1. 请妥善保管密钥库文件和新码！
    echo    2. 丢失密钥库 = 无法更新应用！
    echo    3. 建议备份到安全位置（云盘/U盘）
    echo.
    echo 下一步：
    echo    1. 编辑 app\build.gradle 配置签名信息
    echo    2. 运行 gradlew assembleRelease 构建发布版
) else (
    echo.
    echo [错误] 密钥库生成失败！
)

echo.
pause
