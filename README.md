# PhantomRE

免Root 安卓逆向工程平台（Android 10+）

## 功能
- 虚拟沙盒：免root运行目标APK
- 脱壳：动态/静态/整体加固/so脱壳
- 动态Hook：Frida Gadget（Java/Native）
- 签名绕过：去签名校验/过完整性/过检测
- 资源解密：arsc/加密assets/字符串
- 反编译：jadx/apktool/baksmali
- 抓包：免root VPN + SSL绕过
- 日志：logcat + Hook日志
- Xposed模块：加载标准模块
- AI助手：第三方API（自填Base URL/Key/模型）

## 编译
本项目通过 GitHub Actions 自动编译 APK。push 后进入 Actions 页面下载 artifact。

本地编译：
```
flutter pub get
flutter build apk --release
```

## 声明
仅限自有软件安全研究与学习使用，禁止用于未授权逆向。
