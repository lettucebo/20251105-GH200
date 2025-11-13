# SimpleWeb

A demo project

## 📚 GitHub Actions 自訂 Action 範例

本專案包含完整的 GitHub Actions 自訂 Action 範例與中文文件：

### 🎯 快速導覽

- **[完整指南 (CUSTOM_ACTIONS_GUIDE.md)](./CUSTOM_ACTIONS_GUIDE.md)** - 主要指南文件，包含兩種 Action 類型的完整說明
- **[快速參考 (QUICK_REFERENCE.md)](./QUICK_REFERENCE.md)** - 速查表，快速查找語法和命令
- **[實作總結 (IMPLEMENTATION_SUMMARY.md)](./IMPLEMENTATION_SUMMARY.md)** - 專案實作的詳細總結

### 📁 範例位置

1. **JavaScript Action** 
   - 位置: `.github/actions/javascript-action/`
   - 說明: [README](./.github/actions/javascript-action/README.md)
   - 特色: 使用 Node.js、快速執行、跨平台

2. **Container Action**
   - 位置: `.github/actions/container-action/`
   - 說明: [README](./.github/actions/container-action/README.md)
   - 特色: 使用 Docker、完全控制環境、支援任何語言

3. **測試 Workflow**
   - 位置: `.github/workflows/test-custom-actions.yml`
   - 包含: 基本測試、整合測試、Matrix 測試、錯誤處理測試

### 🚀 快速開始

```bash
# 查看主要指南
cat CUSTOM_ACTIONS_GUIDE.md

# 查看快速參考
cat QUICK_REFERENCE.md

# 測試 JavaScript Action
cd .github/actions/javascript-action
npm install
# 設定環境變數並執行...

# 測試 Container Action
cd .github/actions/container-action
docker build -t test-action .
# 執行測試...
```

### ✨ 包含內容

- ✅ 完整的程式碼範例
- ✅ 詳細的中文文件
- ✅ 本地測試方法
- ✅ 最佳實踐指南
- ✅ 常見問題解答
- ✅ 安全性驗證（通過 CodeQL）

---

## 📖 .NET 技術文件

本專案包含 .NET 相關的技術文件與最佳實踐指南：

- **[.NET 網站專案類型比較分析](./docs/dotnet-web-project-types-comparison.md)** - 完整分析 Web Forms、MVC、Web API 與 Razor Pages 的技術特性、適用場景與選型建議

---

## dotnet user-secrets setting

``` bash
dotnet user-secrets init

dotnet user-secrets set "Storage:Azure:ConnectionString" "xxx"
```

[Safe storage of app secrets in development in ASP.NET Core](https://docs.microsoft.com/en-us/aspnet/core/security/app-secrets)