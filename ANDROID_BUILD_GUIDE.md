# 人生CEO - Capacitor Android 构建指南

## ✅ 已完成的准备工作

### 1. ✅ Capacitor 项目已初始化
- 位置：`D:\CURSOR\lifeceo\capacitor\`
- 依赖已安装（`npm install` 成功）
- Android 平台已添加（`npx cap add android` 成功）

### 2. ✅ Web 资源已集成
- `index.html` 已更新，支持 Capacitor 原生功能
- 原生桥接层已创建（`native-bridge.js`）
- Web 资源已复制到 Android assets 目录

### 3. ✅ 签名配置已准备
- `build.gradle` 已更新，支持签名配置
- `generate_keystore.bat` 已创建（密钥库生成脚本）
- `local.properties.template` 已创建（密码配置模板）

---

## 🚀 接下来的步骤（在你电脑上执行）

### 步骤 1：安装 Java JDK（如未安装）

#### 选项 A：Oracle JDK 17+
- 下载：https://www.oracle.com/java/technologies/downloads/
- 安装后设置 `JAVA_HOME` 环境变量

#### 选项 B：OpenJDK（推荐）
- 下载：https://adoptium.net/
- 选择 **OpenJDK 17 (LTS)**
- 安装后会自动设置环境变量

#### 验证安装
```bash
java -version
keytool -version
```

---

### 步骤 2：生成签名密钥库

#### 方法 1：使用提供的脚本（推荐）

```bash
cd D:\CURSOR\lifeceo\capacitor
.\generate_keystore.bat
```

按提示输入：
- **密钥库密码**：记住这个密码！
- **确认密码**
- **姓名**：可以是花名或真名
- **组织单位**：可选
- **组织名称**：可选
- **城市**：可选
- **省份**：可选
- **国家代码**：`CN`

#### 方法 2：手动命令

```bash
cd D:\CURSOR\lifeceo\capacitor\android\app

keytool -genkey -v ^
  -keystore lifeceo-release-key.keystore ^
  -alias lifeceo ^
  -keyalg RSA ^
  -keysize 2048 ^
  -validity 10000
```

---

### 步骤 3：配置签名密码

1. 复制模板文件：
   ```
   D:\CURSOR\lifeceo\capacitor\android\local.properties.template
   ↓ 复制为
   D:\CURSOR\lifeceo\capacitor\android\local.properties
   ```

2. 编辑 `local.properties`，填写密码：
   ```properties
   release_store_file=lifeceo-release-key.keystore
   release_store_password=你的密钥库密码
   release_key_alias=lifeceo
   release_key_password=你的密钥密码
   ```

3. **重要**：确保 `local.properties` 在 `.gitignore` 中（不要提交到 Git）

---

### 步骤 4：构建 APK

#### 方法 A：使用 Android Studio（推荐）

1. 打开 Android Studio
2. 选择 **Open an Existing Project**
3. 选择 `D:\CURSOR\lifeceo\capacitor\android`
4. 等待 Gradle 同步完成
5. 连接 Android 手机（启用 USB 调试）
6. 点击 **▶️ Run** 按钮（构建并安装 Debug 版）
7. 测试无误后，点击 **Build > Generate Signed Bundle / APK**
8. 选择 **APK**，勾选 **V1** 和 **V2** 签名
9. 构建完成，APK 位置：`android/app/release/app-release.apk`

#### 方法 B：使用命令行

```bash
cd D:\CURSOR\lifeceo\capacitor\android

# Debug 版（测试用）
.\gradlew.bat assembleDebug

# Release 版（发布用）
.\gradlew.bat assembleRelease
```

APK 位置：
- Debug：`app\build\outputs\apk\debug\app-debug.apk`
- Release：`app\build\outputs\apk\release\app-release.apk`

---

### 步骤 5：测试应用

#### 安装到手机

```bash
# 卸载旧版本（如有）
adb uninstall com.lifeceo.app

# 安装 Debug 版
adb install app\build\outputs\apk\debug\app-debug.apk

# 安装 Release 版
adb install app\build\outputs\apk\release\app-release.apk
```

#### 查看日志

```bash
# 查看实时日志
adb logcat | findstr "capacitor"  # Windows
adb logcat | grep "capacitor"     # macOS/Linux

# 查看 Web 日志（在手机上）
# 打开应用，在 Chrome 中访问 chrome://inspect
# 选择你的应用，点击 "Inspect"
```

---

### 步骤 6：上架 Google Play（可选）

#### 1. 构建 App Bundle（推荐）

```bash
cd D:\CURSOR\lifeceo\capacitor\android
.\gradlew.bat bundleRelease
```

AAB 位置：`app\build\outputs\bundle\release\app-release.aab`

#### 2. 准备上架材料

- **应用图标**：512 x 512 px（已提供 `icon-512.png`）
- **功能图**：1024 x 500 px
- **截图**：至少 2 张（推荐 8 张）
- **应用描述**：参考 `STORE_DESCRIPTION.md`

#### 3. 提交审核

1. 访问 [Google Play Console](https://play.google.com/console)
2. 创建应用
3. 上传 App Bundle (.aab)
4. 填写商店列表信息
5. 提交审核（通常需要 1-3 天）

---

## 📝 常见问题

### 1. Gradle 构建失败："SDK location not found"

**解决**：设置 `ANDROID_HOME` 环境变量
```
ANDROID_HOME=C:\Users\YourName\AppData\Local\Android\Sdk
```

### 2. 安装 APK 失败："PackageInfo is null"

**原因**：签名问题

**解决**：
- 确保使用 V1 + V2 签名
- 如果是更新，必须使用相同的密钥库签名

### 3. 原生功能不工作

**检查**：
- 确保在真机上测试（模拟器可能不支持生物识别）
- 查看日志：`adb logcat`
- 确认 `native-bridge.js` 已正确加载

### 4. Web 资源未更新

**解决**：
```bash
cd D:\CURSOR\lifeceo\capacitor
npx cap sync android
```

---

## 📚 文件清单

### 已创建的文件

```
D:\CURSOR\lifeceo\capacitor\
├── package.json                      ← 依赖配置
├── capacitor.config.ts              ← Capacitor 配置
├── generate_keystore.bat            ← 密钥库生成脚本
├── public\
│   ├── index.html                 ← 已集成 Capacitor 支持
│   ├── app-data.js
│   ├── app-logic.js
│   └── native-bridge.js           ← 原生功能桥接层
├── android\
│   ├── app\build.gradle          ← 已配置签名
│   └── local.properties.template  ← 密码配置模板
├── CAPACITOR_MIGRATION_GUIDE.md  ← 完整迁移指南
└── ANDROID_BUILD_GUIDE.md       ← 本文档
```

---

## 🎯 下一步行动

### 立即执行（在你的电脑上）

1. **安装 Java JDK**（如未安装）
2. **运行 `generate_keystore.bat`** 生成签名密钥库
3. **配置 `local.properties`** 填写密码
4. **用 Android Studio 打开项目** 并运行
5. **测试所有功能**
6. **构建 Release APK**
7. **上架 Google Play**（可选）

### 需要帮助？

如遇问题，请提供：
- 错误日志（完整输出）
- 执行步骤（哪一步失败）
- 环境信息（Java 版本、Android Studio 版本）

---

**文档版本**：1.0
**创建日期**：2026-06-25
**预计完成时间**：安装 Java 后 1-2 小时
