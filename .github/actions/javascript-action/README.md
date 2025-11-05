# JavaScript Custom Action 範例

這是一個完整的 JavaScript Action 範例，展示如何建立自訂的 GitHub Action。

## 📋 目錄

- [什麼是 JavaScript Action](#什麼是-javascript-action)
- [檔案結構](#檔案結構)
- [如何使用](#如何使用)
- [輸入參數](#輸入參數)
- [輸出結果](#輸出結果)
- [開發說明](#開發說明)
- [進階功能](#進階功能)

## 什麼是 JavaScript Action

JavaScript Action 是使用 JavaScript (Node.js) 撰寫的 GitHub Action。它具有以下特點：

### ✅ 優點
- **快速執行**：直接在 runner 上執行，不需要下載 Docker 映像
- **跨平台**：可以在 Linux、macOS、Windows 上執行
- **開發簡單**：使用熟悉的 JavaScript/TypeScript
- **豐富生態**：可使用 npm 套件

### ❌ 缺點
- **環境依賴**：依賴 runner 上已安裝的 Node.js 版本
- **套件管理**：需要 commit node_modules 或使用打包工具

## 📁 檔案結構

```
javascript-action/
├── action.yml          # Action 定義檔案
├── index.js            # 主要執行程式
├── package.json        # Node.js 套件設定
└── README.md           # 說明文件
```

### action.yml 說明

```yaml
name: 'JavaScript Custom Action'
description: '自訂 JavaScript Action 範例'

inputs:
  who-to-greet:         # 輸入參數名稱
    description: '...'   # 參數說明
    required: true       # 是否必填
    default: 'World'     # 預設值

outputs:
  time:                  # 輸出結果名稱
    description: '...'   # 輸出說明

runs:
  using: 'node20'        # 使用 Node.js 20
  main: 'index.js'       # 進入點檔案
```

## 🚀 如何使用

### 基本使用

在你的 workflow 中使用此 Action：

```yaml
name: Test JavaScript Action
on: [push]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4
      
      - name: Run JavaScript Action
        id: greet
        uses: ./.github/actions/javascript-action
        with:
          who-to-greet: 'GitHub Actions'
          message-prefix: 'Hi'
      
      - name: Get the output
        run: |
          echo "執行時間: ${{ steps.greet.outputs.time }}"
          echo "問候訊息: ${{ steps.greet.outputs.greeting-message }}"
          echo "環境變數: $CUSTOM_GREETING"
```

### 從其他儲存庫使用

如果將 Action 發布到獨立的儲存庫：

```yaml
- name: Run JavaScript Action
  uses: username/javascript-action@v1
  with:
    who-to-greet: 'World'
```

## 📥 輸入參數

| 參數名稱 | 描述 | 必填 | 預設值 |
|---------|------|------|--------|
| `who-to-greet` | 要問候的人名 | ✅ 是 | `World` |
| `message-prefix` | 訊息前綴 | ❌ 否 | `Hello` |

### 使用範例

```yaml
with:
  who-to-greet: 'GitHub'
  message-prefix: 'Welcome'
```

## 📤 輸出結果

| 輸出名稱 | 描述 | 範例 |
|---------|------|------|
| `time` | 執行時間 | `14:30:45 GMT+0000 (Coordinated Universal Time)` |
| `greeting-message` | 完整的問候訊息 | `Hello GitHub!` |

### 使用輸出

```yaml
- name: Use outputs
  run: |
    echo "Time: ${{ steps.greet.outputs.time }}"
    echo "Message: ${{ steps.greet.outputs.greeting-message }}"
```

## 🔧 開發說明

### 1. 安裝依賴

```bash
cd .github/actions/javascript-action
npm install
```

### 2. 核心套件

#### @actions/core

提供 Action 核心功能：

```javascript
const core = require('@actions/core');

// 取得輸入
const input = core.getInput('input-name');

// 設定輸出
core.setOutput('output-name', 'value');

// 記錄訊息
core.info('資訊訊息');
core.warning('警告訊息');
core.error('錯誤訊息');
core.notice('通知訊息');

// 設定失敗
core.setFailed('錯誤訊息');

// 導出環境變數
core.exportVariable('VAR_NAME', 'value');

// 新增摘要
await core.summary
  .addHeading('標題')
  .addTable([...])
  .write();
```

#### @actions/github

提供 GitHub API 和上下文資訊：

```javascript
const github = require('@actions/github');

// 取得上下文
const context = github.context;
console.log(context.repo.owner);
console.log(context.repo.repo);
console.log(context.eventName);
console.log(context.sha);

// 使用 Octokit (需要 token)
const octokit = github.getOctokit(token);
const { data } = await octokit.rest.repos.get({
  owner: context.repo.owner,
  repo: context.repo.repo
});
```

### 3. 本地測試

在本地測試前，需要設定環境變數：

```bash
# 設定輸入參數
export INPUT_WHO-TO-GREET="Local Test"
export INPUT_MESSAGE-PREFIX="Hello"

# 執行
node index.js
```

### 4. 錯誤處理

良好的錯誤處理：

```javascript
try {
  // 主要邏輯
  const result = await someAsyncOperation();
  core.setOutput('result', result);
} catch (error) {
  core.setFailed(`失敗: ${error.message}`);
  // 也可以記錄完整的堆疊追蹤
  core.debug(error.stack);
}
```

## 🎓 進階功能

### 1. 多步驟處理

```javascript
async function run() {
  try {
    // 步驟 1: 驗證輸入
    core.startGroup('驗證輸入');
    validateInputs();
    core.endGroup();
    
    // 步驟 2: 執行主要邏輯
    core.startGroup('執行處理');
    const result = await processData();
    core.endGroup();
    
    // 步驟 3: 輸出結果
    core.startGroup('設定輸出');
    setOutputs(result);
    core.endGroup();
    
  } catch (error) {
    core.setFailed(error.message);
  }
}
```

### 2. 使用 GitHub API

```javascript
async function createIssueComment(token) {
  const octokit = github.getOctokit(token);
  const context = github.context;
  
  if (context.payload.pull_request) {
    await octokit.rest.issues.createComment({
      owner: context.repo.owner,
      repo: context.repo.repo,
      issue_number: context.payload.pull_request.number,
      body: '✅ Action 執行成功！'
    });
  }
}
```

### 3. 讀取檔案

```javascript
const fs = require('fs');
const path = require('path');

function readConfigFile() {
  const configPath = path.join(process.env.GITHUB_WORKSPACE, 'config.json');
  if (fs.existsSync(configPath)) {
    const content = fs.readFileSync(configPath, 'utf8');
    return JSON.parse(content);
  }
  return null;
}
```

### 4. 設定 Job Summary

```javascript
await core.summary
  .addHeading('執行結果', 2)
  .addCodeBlock(`
    執行時間: ${time}
    處理檔案: ${files.length} 個
    狀態: 成功
  `, 'text')
  .addList([
    '✅ 步驟 1 完成',
    '✅ 步驟 2 完成',
    '✅ 步驟 3 完成'
  ])
  .write();
```

## 📦 發布 Action

### 1. 處理 node_modules

選項 A：提交 node_modules (簡單但增加儲存庫大小)

```bash
git add node_modules
git commit -m "Add dependencies"
```

選項 B：使用 @vercel/ncc 打包 (推薦)

```bash
npm install -g @vercel/ncc
ncc build index.js -o dist

# 更新 action.yml
runs:
  using: 'node20'
  main: 'dist/index.js'
```

### 2. 建立版本標籤

```bash
git tag -a -m "v1.0.0" v1.0.0
git push --follow-tags
```

### 3. 發布到 GitHub Marketplace

1. 在 action.yml 中添加 branding
2. 建立 release
3. 勾選 "Publish this Action to the GitHub Marketplace"

## 🔍 除錯技巧

### 1. 啟用 Debug 日誌

在儲存庫設定 Secret：`ACTIONS_STEP_DEBUG = true`

### 2. 在程式中使用 debug

```javascript
core.debug('這是除錯訊息');
core.debug(`變數值: ${JSON.stringify(variable)}`);
```

### 3. 使用 console.log

```javascript
console.log('🔍 檢查點 1');
console.log('變數:', variable);
```

## 📚 參考資源

- [GitHub Actions 官方文件](https://docs.github.com/en/actions)
- [actions/toolkit](https://github.com/actions/toolkit)
- [Creating a JavaScript action](https://docs.github.com/en/actions/creating-actions/creating-a-javascript-action)

## 💡 最佳實踐

1. **輸入驗證**：始終驗證輸入參數
2. **錯誤處理**：使用 try-catch 處理所有可能的錯誤
3. **清晰日誌**：提供有意義的日誌訊息
4. **文件完整**：保持 README 和註解的更新
5. **版本管理**：使用語義化版本 (semver)
6. **測試**：本地測試後再推送
