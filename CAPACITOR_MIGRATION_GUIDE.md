# 人生CEO - Capacitor 迁移指南

## 📋 目录

1. [方案概述](#方案概述)
2. [环境准备](#环境准备)
3. [项目初始化](#项目初始化)
4. [集成原生功能](#集成原生功能)
5. [构建 iOS 应用](#构建-ios-应用)
6. [构建 Android 应用](#构建-android-应用)
7. [测试与调试](#测试与调试)
8. [上架准备](#上架准备)
9. [常见问题](#常见问题)

---

## 方案概述

### 为什么选择 Capacitor？

✅ **最快迁移方案** - 直接复用现有 Web 代码
✅ **开发成本低** - 无需重写 UI 组件
✅ **渐进式增强** - 可以先 WebView，后原生组件
✅ **跨平台支持** - 一套代码，iOS + Android 同时支持
✅ **原生功能访问** - 通过插件访问相机、文件系统、生物识别等

### 技术架构

```
┌─────────────────────────────────────────┐
│          Web 应用层（现有代码）         │
│  - index.html                          │
│  - app-data.js                        │
│  - app-logic.js                       │
├─────────────────────────────────────────┤
│       Capacitor 桥接层                  │
│  - native-bridge.js                   │
│  - 调用原生插件                       │
├─────────────────────────────────────────┤
│      原生功能层（Capacitor Plugins）    │
│  - Biometric Auth（生物识别）          │
│  - File System（文件系统）             │
│  - Local Notifications（本地通知）     │
│  - Network（网络状态）                │
│  - Share（分享）                      │
└─────────────────────────────────────────┘
```

---

## 环境准备

### 必需软件

#### 1. Node.js 18+ 
- 下载: https://nodejs.org/
- 验证安装:
  ```bash
  node --version  # 应显示 v18.x.x 或更高
  npm --version
  ```

#### 2. Capacitor CLI
```bash
npm install -g @capacitor/cli
npx cap --version
```

#### 3. iOS 开发（仅 macOS）
- **Xcode 15+**
  - 下载: https://developer.apple.com/xcode/
  - 安装命令行工具: `xcode-select --install`
  
- **CocoaPods**
  ```bash
  sudo gem install cocoapods
  pod --version
  ```

#### 4. Android 开发（Windows/macOS/Linux）
- **Android Studio**
  - 下载: https://developer.android.com/studio
  - 安装 Android SDK (API 34)
  - 配置 ANDROID_HOME 环境变量

---

## 项目初始化

### 步骤 1：进入 Capacitor 项目目录

```bash
cd D:\CURSOR\lifeceo\capacitor
```

### 步骤 2：安装依赖

```bash
npm install
```

这将安装以下 Capacitor 插件：
- `@capacitor/core` - 核心库
- `@capacitor/android` - Android 平台
- `@capacitor/ios` - iOS 平台
- `@capacitor/biometric-auth` - 生物识别
- `@capacitor/filesystem` - 文件系统
- `@capacitor/share` - 分享功能
- `@capacitor/local-notifications` - 本地通知
- `@capacitor/network` - 网络状态
- `@capacitor/status-bar` - 状态栏
- `@capacitor/splash-screen` - 启动屏

### 步骤 3：初始化 Capacitor

```bash
npx cap init com.lifeceo.app 人生CEO --web-dir=public
```

### 步骤 4：添加平台

#### 添加 Android 平台
```bash
npx cap add android
```

#### 添加 iOS 平台（仅 macOS）
```bash
npx cap add ios
```

### 步骤 5：同步 Web 资源

```bash
npx cap sync
```

这将把 `public/` 目录下的 Web 资源复制到 Android 和 iOS 项目中。

---

## 集成原生功能

### 1. 更新 index.html

在 `capacitor/public/index.html` 中添加 Capacitor 支持：

```html
<!DOCTYPE html>
<html lang="zh-CN">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0, viewport-fit=cover" />
  <title>人生CEO-CRM · 向上管理操作系统</title>
  
  <!-- Capacitor 支持 -->
  <script>
    window.addEventListener('DOMContentLoaded', async function() {
      // 检测是否在 Capacitor 环境中
      if (window.Capacitor && window.Capacitor.isNativePlatform()) {
        console.log('[App] 运行在原生平台:', window.Capacitor.getPlatform());
        
        // 初始化原生功能
        if (window.NativeBridge) {
          await window.NativeBridge.init();
        }
      } else {
        console.log('[App] 运行在 Web 浏览器');
      }
    });
  </script>
  
  <!-- 现有的 Tailwind 和样式配置 -->
  <script src="https://cdn.tailwindcss.com"></script>
  <!-- ... 其他配置 ... -->
</head>
<body>
  <!-- 现有的 HTML 结构 -->
</body>
</html>
```

### 2. 集成生物识别

在 `app-logic.js` 中添加：

```javascript
// 在应用启动时检查生物识别
async function checkBiometricLock() {
  if (window.NativeBridge) {
    const unlocked = await window.NativeBridge.authenticate('解锁人生CEO');
    if (!unlocked) {
      // 显示解锁界面
      showLockScreen();
    }
  }
}

// 在 DOMContentLoaded 中调用
document.addEventListener('DOMContentLoaded', async function() {
  await checkBiometricLock();
  // ... 其他初始化 ...
});
```

### 3. 集成备份功能

```javascript
// 导出备份
async function exportBackup() {
  const data = {
    version: '10.14',
    timestamp: new Date().toISOString(),
    relations: getRelations(),
    signals: getSignals(),
    // ... 其他数据 ...
  };
  
  if (window.NativeBridge) {
    // 使用原生文件系统集成
    await window.NativeBridge.exportBackup(data, `lifeceo_backup_${Date.now()}.json`);
  } else {
    // 降级到 Web 下载
    const blob = new Blob([JSON.stringify(data)], { type: 'application/json' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `lifeceo_backup_${Date.now()}.json`;
    a.click();
  }
}
```

---

## 构建 iOS 应用

### 步骤 1：打开 iOS 项目

```bash
npx cap open ios
```

这将使用 Xcode 打开 iOS 项目。

### 步骤 2：配置签名

1. 在 Xcode 中，选择 **签名 & 功能** 标签
2. 选择你的 **开发者团队**
3. 设置 **Bundle Identifier** 为 `com.lifeceo.app`
4. 勾选 **自动管理签名**

### 步骤 3：构建应用

1. 选择目标设备（真机或模拟器）
2. 点击 **▶️ Run** 按钮

### 步骤 4：归档（发布）

1. 菜单 **Product > Archive**
2. 归档完成后，点击 **Distribute App**
3. 选择 **App Store Connect**
4. 按照向导完成上传

---

## 构建 Android 应用

### 步骤 1：打开 Android 项目

```bash
npx cap open android
```

这将使用 Android Studio 打开 Android 项目。

### 步骤 2：配置签名

在 `android/app/build.gradle` 中添加：

```gradle
android {
    signingConfigs {
        release {
            storeFile file('lifeceo-release-key.keystore')
            storePassword 'your_keystore_password'
            keyAlias 'lifeceo'
            keyPassword 'your_key_password'
        }
    }
    
    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'
        }
    }
}
```

### 步骤 3：生成签名密钥库

```bash
keytool -genkey -v -keystore app/lifeceo-release-key.keystore \
  -alias lifeceo \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000
```

### 步骤 4：构建 APK

#### Debug APK（测试）
```bash
./gradlew assembleDebug
```

APK 位置: `app/build/outputs/apk/debug/app-debug.apk`

#### Release APK（发布）
```bash
./gradlew assembleRelease
```

APK 位置: `app/build/outputs/apk/release/app-release.apk`

### 步骤 5：构建 App Bundle（推荐）

```bash
./gradlew bundleRelease
```

AAB 位置: `app/build/outputs/bundle/release/app-release.aab`

---

## 测试与调试

### iOS 调试

1. 连接 iPhone 到 Mac
2. 在 Xcode 中选择设备
3. 点击 **▶️ Run**
4. 查看控制台输出

### Android 调试

1. 连接 Android 手机
2. 启用 **开发者选项** 和 **USB 调试**
3. 在 Android Studio 中选择设备
4. 点击 **▶️ Run**
5. 查看 Logcat 输出

### Web 调试

在 Capacitor 项目中，可以直接在浏览器中调试 Web 层：

```bash
npx cap serve
```

然后打开 `http://localhost:8100` 进行调试。

---

## 上架准备

### iOS App Store

#### 1. 准备截图
- 需要 5.5 英寸（iPhone 8 Plus）或更大屏幕的截图
- 推荐尺寸: 1242 x 2208 px

#### 2. 编写应用描述

**应用名称**: 人生CEO-CRM

**副标题**: 向上管理操作系统

**描述**:
```
人生CEO 是一款创新的向上管理操作系统，帮助你将个人发展视为企业经营。

核心功能：
- 🗺️ 关系地图：四象限管理你的利益相关者
- 📡 信号雷达：捕捉关键人物的动态信号
- 🎯 组局引擎：智能匹配和资源整合
- 💎 健康分：量化你的关系网络价值

所有数据完全离线存储，保护你的隐私安全。
```

#### 3. 配置应用信息
- **主要类别**: 商务
- **次要类别**: 生产力
- **关键词**: CRM, 关系管理, 向上管理, 人脉, 商务

#### 4. 提交审核
- 在 App Store Connect 中创建应用
- 上传截图和元数据
- 提交审核（通常需要 1-3 天）

---

### Google Play Store

#### 1. 准备素材
- **应用图标**: 512 x 512 px
- **功能图**: 1024 x 500 px
- **截图**: 至少 2 张（推荐 8 张）

#### 2. 编写应用描述
（同 iOS 描述）

#### 3. 配置商店列表
- **应用名称**: 人生CEO-CRM
- **简短描述**: 向上管理操作系统（最多 80 字符）
- **完整描述**: （同上）

#### 4. 定价和分发
- **定价**: 免费（或设置价格）
- **分发国家/地区**: 选择目标市场

#### 5. 提交审核
- 在 Google Play Console 中创建应用
- 上传 App Bundle (.aab)
- 提交审核（通常需要 1-3 天）

---

## 常见问题

### 1. Capacitor 插件无法正常工作

**原因**: 未正确安装或同步插件

**解决**:
```bash
npm install @capacitor/plugin-name
npx cap sync
```

### 2. iOS 构建失败: "Code signing is required"

**原因**: 未配置开发者证书

**解决**:
1. 在 Xcode 中登录 Apple Developer 账号
2. 配置自动签名
3. 或使用描述文件手动签名

### 3. Android 构建失败: "SDK location not found"

**原因**: 未配置 ANDROID_HOME 环境变量

**解决**:
```bash
# Windows
setx ANDROID_HOME "C:\Users\YourName\AppData\Local\Android\Sdk"

# macOS/Linux
export ANDROID_HOME=~/Library/Android/sdk
```

### 4. Web 资源未更新

**原因**: 未执行 `npx cap sync`

**解决**:
```bash
npx cap sync  # 同步 Web 资源到原生项目
npx cap copy   # 仅复制 Web 资源（不更新插件）
```

### 5. 生物识别不工作

**原因**: 设备或模拟器不支持

**解决**:
- 在真机上测试
- iOS 模拟器: 使用 **Features > Touch ID / Face ID**
- Android 模拟器: 使用 **设置 > 安全 > 指纹**

### 6. 如何调试原生代码？

**iOS**:
- 在 Xcode 中设置断点
- 查看 **Console** 输出

**Android**:
- 在 Android Studio 中设置断点
- 查看 **Logcat** 输出

---

## 📞 技术支持

如有问题，请检查：
1. Capacitor 版本（建议最新稳定版）
2. iOS/Android 平台版本
3. 插件版本兼容性

---

## 📚 参考资源

- **Capacitor 官方文档**: https://capacitorjs.com/docs
- **Capacitor 插件列表**: https://capacitorjs.com/docs/apis
- **iOS 上架指南**: https://developer.apple.com/app-store/
- **Google Play 上架指南**: https://play.google.com/console

---

**文档版本**: 1.0
**创建日期**: 2026-06-25
**适用版本**: 人生CEO v10.14+
**预计完成时间**: 1-2 周
