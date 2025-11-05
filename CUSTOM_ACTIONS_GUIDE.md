# GitHub Actions 自訂 Action 完整範例

這個專案提供完整的 **JavaScript Action** 和 **Container Action** 範例與詳細說明。

## 📚 目錄

- [專案概述](#專案概述)
- [Action 類型比較](#action-類型比較)
- [快速開始](#快速開始)
- [範例說明](#範例說明)
- [使用指南](#使用指南)
- [開發指南](#開發指南)
- [常見問題](#常見問題)

## 專案概述

本專案包含兩種 GitHub Actions 自訂 Action 的完整實作：

1. **JavaScript Action** (`.github/actions/javascript-action/`)
   - 使用 Node.js 撰寫
   - 展示如何使用 GitHub Actions Toolkit
   - 適合快速、跨平台的操作

2. **Container Action** (`.github/actions/container-action/`)
   - 使用 Docker 容器
   - 展示如何使用 Bash 腳本和 Linux 工具
   - 適合需要特定環境的操作

## Action 類型比較

| 特性 | JavaScript Action | Container Action |
|------|------------------|------------------|
| **執行環境** | Node.js runtime | Docker 容器 |
| **平台支援** | Linux, macOS, Windows | 僅 Linux |
| **啟動速度** | ⚡ 快速 (直接執行) | 🐌 較慢 (需建置/拉取映像) |
| **開發語言** | JavaScript/TypeScript | 任何語言 (Bash, Python, Go 等) |
| **依賴管理** | npm packages | Docker 映像內包含 |
| **環境控制** | ⚠️ 受限於 runner 環境 | ✅ 完全控制 |
| **檔案大小** | 較小 (僅程式碼 + node_modules) | 較大 (完整 Docker 映像) |
| **適用場景** | 輕量級處理、API 呼叫、檔案操作 | 需要特定工具、編譯、複雜環境 |

### 何時使用 JavaScript Action？

✅ **適合使用**：
- 快速的資料處理和轉換
- GitHub API 互動
- 需要跨平台支援 (Linux/macOS/Windows)
- 簡單的檔案操作
- npm 生態系統中有現成的工具

❌ **不適合使用**：
- 需要特定系統工具或編譯器
- 需要特定版本的系統依賴
- 只在 Linux 上執行的操作

### 何時使用 Container Action？

✅ **適合使用**：
- 需要特定的系統工具或語言環境
- 需要完全控制執行環境
- 複雜的編譯或建置流程
- 使用非 JavaScript 語言
- 需要多個系統依賴

❌ **不適合使用**：
- 需要在 Windows 或 macOS 上執行
- 追求最快的執行速度
- 簡單的操作

## 快速開始

### 1. Clone 專案

```bash
git clone <repository-url>
cd 20251105-GH200
```

### 2. 查看範例

```bash
# 查看 JavaScript Action
ls -la .github/actions/javascript-action/
cat .github/actions/javascript-action/README.md

# 查看 Container Action
ls -la .github/actions/container-action/
cat .github/actions/container-action/README.md
```

### 3. 測試 Actions

#### 測試 JavaScript Action

```bash
cd .github/actions/javascript-action

# 安裝依賴
npm install

# 設定環境變數
export INPUT_WHO-TO-GREET="本地測試"
export INPUT_MESSAGE-PREFIX="你好"

# 執行
node index.js
```

#### 測試 Container Action

```bash
cd .github/actions/container-action

# 建置 Docker 映像
docker build -t test-container-action .

# 執行測試
docker run --rm \
  -e INPUT_TEXT-TO-PROCESS="測試文字" \
  -e INPUT_OPERATION="uppercase" \
  -e INPUT_OUTPUT-FORMAT="text" \
  -e GITHUB_OUTPUT=/tmp/output.txt \
  test-container-action
```

### 4. 在 Workflow 中使用

查看範例 workflow：

```bash
cat .github/workflows/test-custom-actions.yml
```

## 範例說明

### JavaScript Action 功能

這個範例展示：

1. ✅ **輸入參數處理**
   - 使用 `core.getInput()` 讀取參數
   - 支援必填和可選參數
   - 提供預設值

2. ✅ **輸出設定**
   - 使用 `core.setOutput()` 設定輸出
   - 供後續步驟使用

3. ✅ **日誌記錄**
   - `core.info()` - 資訊訊息
   - `core.warning()` - 警告訊息
   - `core.error()` - 錯誤訊息
   - `core.notice()` - 通知訊息

4. ✅ **環境變數**
   - 使用 `core.exportVariable()` 導出變數

5. ✅ **GitHub 上下文**
   - 存取儲存庫資訊
   - 存取事件資料
   - 存取執行者資訊

6. ✅ **執行摘要**
   - 使用 `core.summary` 建立摘要表格

7. ✅ **錯誤處理**
   - 使用 try-catch 捕獲錯誤
   - 使用 `core.setFailed()` 回報失敗

### Container Action 功能

這個範例展示：

1. ✅ **Dockerfile 設定**
   - 選擇基礎映像
   - 安裝依賴
   - 設定進入點

2. ✅ **輸入參數處理**
   - 透過環境變數讀取 (INPUT_*)
   - 參數驗證

3. ✅ **輸出設定**
   - 寫入 GITHUB_OUTPUT 檔案
   - 支援單行和多行輸出

4. ✅ **環境變數**
   - 寫入 GITHUB_ENV 檔案

5. ✅ **錯誤處理**
   - 使用 `set -e` 自動捕獲錯誤
   - 輸入驗證
   - 適當的退出碼

6. ✅ **日誌美化**
   - 彩色輸出
   - 結構化日誌
   - 進度指示

7. ✅ **檔案操作**
   - 存取 GITHUB_WORKSPACE
   - 讀寫檔案

## 使用指南

### 在 Workflow 中使用 JavaScript Action

```yaml
jobs:
  my-job:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      # 安裝依賴
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
      
      - name: Install dependencies
        run: |
          cd .github/actions/javascript-action
          npm install
      
      # 使用 Action
      - name: Run JavaScript Action
        id: js-action
        uses: ./.github/actions/javascript-action
        with:
          who_to_greet: 'World'
          message_prefix: 'Hello'
      
      # 使用輸出
      - name: Use output
        run: echo "${{ steps.js-action.outputs.greeting-message }}"
```

### 在 Workflow 中使用 Container Action

```yaml
jobs:
  my-job:
    runs-on: ubuntu-latest  # 必須使用 Linux
    steps:
      - uses: actions/checkout@v4
      
      # 使用 Action (會自動建置容器)
      - name: Run Container Action
        id: container-action
        uses: ./.github/actions/container-action
        with:
          text_to_process: 'Hello World'
          operation: 'uppercase'
          output_format: 'text'
      
      # 使用輸出
      - name: Use output
        run: echo "${{ steps.container-action.outputs.result }}"
```

### 組合使用兩種 Actions

```yaml
jobs:
  combined:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
      
      - name: Install dependencies
        run: |
          cd .github/actions/javascript-action
          npm install
      
      # 使用 JavaScript Action 產生資料
      - name: Generate data
        id: generate
        uses: ./.github/actions/javascript-action
        with:
          who_to_greet: 'GitHub'
          message_prefix: 'Hello'
      
      # 使用 Container Action 處理資料
      - name: Process data
        id: process
        uses: ./.github/actions/container-action
        with:
          text_to_process: ${{ steps.generate.outputs.greeting-message }}
          operation: 'uppercase'
      
      # 顯示結果
      - name: Show results
        run: |
          echo "原始: ${{ steps.generate.outputs.greeting-message }}"
          echo "處理後: ${{ steps.process.outputs.result }}"
```

## 開發指南

### 開發 JavaScript Action

1. **建立基本結構**

```bash
mkdir -p my-js-action
cd my-js-action

# 初始化 npm
npm init -y

# 安裝依賴
npm install @actions/core @actions/github
```

2. **建立 action.yml**

```yaml
name: 'My Action'
description: 'My custom action'
inputs:
  my-input:
    description: 'Input description'
    required: true
outputs:
  my-output:
    description: 'Output description'
runs:
  using: 'node20'
  main: 'index.js'
```

3. **撰寫 index.js**

```javascript
const core = require('@actions/core');

async function run() {
  try {
    const input = core.getInput('my-input');
    // 處理邏輯
    core.setOutput('my-output', result);
  } catch (error) {
    core.setFailed(error.message);
  }
}

run();
```

4. **測試**

```bash
export INPUT_MY-INPUT="test"
node index.js
```

### 開發 Container Action

1. **建立基本結構**

```bash
mkdir -p my-container-action
cd my-container-action
```

2. **建立 action.yml**

```yaml
name: 'My Container Action'
description: 'My custom container action'
inputs:
  my-input:
    description: 'Input description'
    required: true
outputs:
  my-output:
    description: 'Output description'
runs:
  using: 'docker'
  image: 'Dockerfile'
```

3. **建立 Dockerfile**

```dockerfile
FROM alpine:3.18

RUN apk add --no-cache bash

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
```

4. **建立 entrypoint.sh**

```bash
#!/bin/bash
set -e

INPUT="${INPUT_MY-INPUT}"

# 處理邏輯
RESULT="..."

# 設定輸出
echo "my-output=${RESULT}" >> $GITHUB_OUTPUT
```

5. **測試**

```bash
# 建置
docker build -t my-action .

# 測試
docker run --rm \
  -e INPUT_MY-INPUT="test" \
  -e GITHUB_OUTPUT=/tmp/output.txt \
  my-action
```

## 常見問題

### JavaScript Action

**Q: node_modules 要不要 commit？**

A: 有兩種方式：
1. Commit node_modules (簡單但增加儲存庫大小)
2. 使用 @vercel/ncc 打包成單一檔案 (推薦)

```bash
npm install -g @vercel/ncc
ncc build index.js -o dist
# 更新 action.yml 的 main 為 'dist/index.js'
```

**Q: 如何在本地除錯？**

A: 設定環境變數後直接執行：

```bash
export INPUT_MY-INPUT="test"
export GITHUB_OUTPUT="/tmp/output.txt"
node index.js
```

**Q: 支援哪些 Node.js 版本？**

A: 建議使用 `node20`。查看 [runner 映像](https://github.com/actions/runner-images)了解預裝版本。

### Container Action

**Q: 為什麼只能在 Linux 上執行？**

A: Container Actions 使用 Docker，目前 GitHub Actions 只在 Linux runners 上支援 Docker。

**Q: 如何減少容器大小？**

A: 
1. 使用 Alpine Linux
2. 多階段建置
3. 清理快取和臨時檔案
4. 合併 RUN 指令

**Q: 容器建置很慢怎麼辦？**

A: 
1. 優化 Dockerfile 層級順序
2. 使用映像快取
3. 考慮發布到 Docker Hub 並直接使用

**Q: 如何存取工作區檔案？**

A: 使用 `$GITHUB_WORKSPACE` 環境變數：

```bash
FILES="${GITHUB_WORKSPACE}/myfile.txt"
```

### 通用問題

**Q: 如何選擇 JavaScript 還是 Container Action？**

A: 參考[Action 類型比較](#action-類型比較)表格。簡單來說：
- 快速、跨平台 → JavaScript
- 需要特定環境 → Container

**Q: 可以在 Action 中呼叫其他 Action 嗎？**

A: 不行。Action 是單一執行單元。但你可以在 workflow 中串連多個 Actions。

**Q: 如何處理敏感資料？**

A: 
1. 使用 GitHub Secrets
2. 作為輸入參數傳入
3. 不要寫入日誌或輸出

```yaml
- uses: my-action
  with:
    token: ${{ secrets.MY_TOKEN }}
```

**Q: 如何發布 Action？**

A: 
1. 建立獨立儲存庫
2. 添加完整的 README
3. 建立 release 和 tags
4. (可選) 發布到 Marketplace

## 📖 詳細文件

- [JavaScript Action 詳細說明](.github/actions/javascript-action/README.md)
- [Container Action 詳細說明](.github/actions/container-action/README.md)
- [測試 Workflow 範例](.github/workflows/test-custom-actions.yml)

## 🔗 相關資源

- [GitHub Actions 官方文件](https://docs.github.com/en/actions)
- [Creating Actions](https://docs.github.com/en/actions/creating-actions)
- [GitHub Actions Toolkit](https://github.com/actions/toolkit)
- [Awesome Actions](https://github.com/sdras/awesome-actions)

## 📝 授權

MIT License

## 🤝 貢獻

歡迎提交 Issues 和 Pull Requests！

---

💡 **提示**：先閱讀各個 Action 的 README 檔案以了解更詳細的使用方式和範例。
