# 快速參考指南

## 🚀 五分鐘快速上手

### 選擇 Action 類型

```
需要跨平台？           → JavaScript Action
需要特定系統工具？      → Container Action  
追求最快速度？         → JavaScript Action
需要完全控制環境？      → Container Action
```

## 📋 JavaScript Action 速查表

### 基本結構

```javascript
const core = require('@actions/core');

async function run() {
  try {
    // 取得輸入
    const input = core.getInput('input_name');
    
    // 設定輸出
    core.setOutput('output_name', 'value');
    
    // 記錄訊息
    core.info('資訊訊息');
    core.warning('警告訊息');
    core.error('錯誤訊息');
    core.notice('通知訊息');
    
  } catch (error) {
    core.setFailed(error.message);
  }
}

run();
```

### action.yml

```yaml
name: 'My Action'
inputs:
  input_name:
    description: '說明'
    required: true
outputs:
  output_name:
    description: '說明'
runs:
  using: 'node20'
  main: 'index.js'
```

### 常用功能

| 功能 | 程式碼 |
|-----|-------|
| 取得輸入 | `core.getInput('name')` |
| 設定輸出 | `core.setOutput('name', value)` |
| 導出環境變數 | `core.exportVariable('name', value)` |
| 設定失敗 | `core.setFailed('message')` |
| 分組日誌 | `core.startGroup('title')` ... `core.endGroup()` |

## 📋 Container Action 速查表

### 基本結構

```bash
#!/bin/bash
set -e

# 讀取輸入
INPUT="${INPUT_MY_INPUT}"

# 驗證
if [ -z "${INPUT}" ]; then
    echo "錯誤：輸入為空"
    exit 1
fi

# 處理
RESULT="..."

# 設定輸出
echo "result=${RESULT}" >> $GITHUB_OUTPUT

# 設定環境變數
echo "MY_VAR=${RESULT}" >> $GITHUB_ENV
```

### Dockerfile

```dockerfile
FROM alpine:3.18
RUN apk add --no-cache bash
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
```

### action.yml

```yaml
name: 'My Container Action'
inputs:
  my_input:
    description: '說明'
    required: true
outputs:
  result:
    description: '說明'
runs:
  using: 'docker'
  image: 'Dockerfile'
```

### 環境變數

| Action 輸入 | 環境變數 |
|-----------|---------|
| `my_input` | `INPUT_MY_INPUT` |
| `text_to_process` | `INPUT_TEXT_TO_PROCESS` |

## 📋 使用範例速查

### 在 Workflow 中使用

```yaml
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      # JavaScript Action
      - name: Run JS Action
        id: js
        uses: ./.github/actions/javascript-action
        with:
          who_to_greet: 'World'
      
      # Container Action (僅 Linux)
      - name: Run Container Action
        id: container
        uses: ./.github/actions/container-action
        with:
          text_to_process: 'Hello'
      
      # 使用輸出
      - name: Use outputs
        run: |
          echo "${{ steps.js.outputs.greeting-message }}"
          echo "${{ steps.container.outputs.result }}"
```

## 🧪 本地測試

### JavaScript Action

```bash
cd .github/actions/javascript-action
npm install

# 設定環境變數
export INPUT_WHO_TO_GREET="Test"
export INPUT_MESSAGE_PREFIX="Hello"
export GITHUB_OUTPUT=/tmp/output.txt
export GITHUB_ENV=/tmp/env.txt
export GITHUB_STEP_SUMMARY=/tmp/summary.md

# 執行
node index.js

# 檢查結果
cat /tmp/output.txt
```

### Container Action

```bash
cd .github/actions/container-action

# 建置
docker build -t test-action .

# 測試
docker run --rm \
  -e INPUT_TEXT_TO_PROCESS="test" \
  -e INPUT_OPERATION="uppercase" \
  -e GITHUB_OUTPUT=/tmp/output.txt \
  test-action
```

## ⚡ 常用命令

### JavaScript Action 開發

```bash
# 初始化
npm init -y
npm install @actions/core @actions/github

# 打包（推薦用於發布）
npm install -g @vercel/ncc
ncc build index.js -o dist
```

### Container Action 開發

```bash
# 建置測試
docker build -t my-action .

# 互動式除錯
docker run -it --rm my-action /bin/sh

# 檢查映像大小
docker images my-action

# 查看層級
docker history my-action
```

## 🔍 除錯技巧

### 啟用 Debug 日誌

在儲存庫 Settings → Secrets 中設定：
```
ACTIONS_STEP_DEBUG = true
```

### JavaScript Action 除錯

```javascript
// 使用 debug (需要 ACTIONS_STEP_DEBUG=true)
core.debug('除錯訊息');

// 顯示變數
console.log('變數:', JSON.stringify(variable, null, 2));
```

### Container Action 除錯

```bash
# 顯示所有命令
set -x

# 顯示環境變數
env | sort

# 顯示工作目錄
pwd
ls -la
```

## ❗ 常見錯誤

| 錯誤 | 原因 | 解決方法 |
|-----|-----|---------|
| `INPUT_XXX` 未定義 | 輸入參數名稱錯誤 | 檢查是否使用底線 |
| `GITHUB_OUTPUT` 不存在 | 本地測試未設定 | `touch /tmp/output.txt` |
| 容器建置失敗 | 網路問題或套件名稱錯誤 | 使用更小的基礎映像 |
| 權限錯誤 | 檔案不可執行 | `chmod +x entrypoint.sh` |

## 📌 最佳實踐檢查清單

- [ ] 輸入參數使用底線命名
- [ ] 有完整的錯誤處理（try-catch 或 set -e）
- [ ] 有輸入驗證
- [ ] 有清晰的日誌訊息
- [ ] 有完整的 README 文件
- [ ] 已設定 Workflow 權限
- [ ] 已通過本地測試
- [ ] 已通過安全掃描

## 🔗 本專案範例檔案

- JavaScript Action: `.github/actions/javascript-action/`
- Container Action: `.github/actions/container-action/`
- 測試 Workflow: `.github/workflows/test-custom-actions.yml`
- 完整指南: `CUSTOM_ACTIONS_GUIDE.md`
- 實作總結: `IMPLEMENTATION_SUMMARY.md`

---

💡 **提示**: 先閱讀 `CUSTOM_ACTIONS_GUIDE.md` 了解完整說明，再使用此速查表作為快速參考。
