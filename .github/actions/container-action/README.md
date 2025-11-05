# Container Custom Action 範例

這是一個完整的 Container Action 範例，展示如何使用 Docker 容器建立自訂的 GitHub Action。

## 📋 目錄

- [什麼是 Container Action](#什麼是-container-action)
- [檔案結構](#檔案結構)
- [如何使用](#如何使用)
- [輸入參數](#輸入參數)
- [輸出結果](#輸出結果)
- [開發說明](#開發說明)
- [進階功能](#進階功能)

## 什麼是 Container Action

Container Action 是使用 Docker 容器運行的 GitHub Action。它將你的程式碼打包在容器中執行。

### ✅ 優點
- **環境一致性**：完全控制執行環境
- **語言靈活**：可以使用任何程式語言
- **依賴管理**：所有依賴都包含在容器中
- **複雜操作**：適合需要特定系統工具的操作

### ❌ 缺點
- **只支援 Linux**：只能在 Linux runners 上執行
- **啟動較慢**：需要時間建置或拉取 Docker 映像
- **映像大小**：需要考慮映像大小

## 📁 檔案結構

```
container-action/
├── action.yml          # Action 定義檔案
├── Dockerfile          # Docker 映像定義
├── entrypoint.sh       # 容器執行腳本
└── README.md           # 說明文件
```

### action.yml 說明

```yaml
name: 'Container Custom Action'
description: '自訂 Container Action 範例'

inputs:
  text_to_process:      # 輸入參數
    description: '...'
    required: true

outputs:
  result:               # 輸出結果
    description: '...'

runs:
  using: 'docker'       # 使用 Docker 容器
  image: 'Dockerfile'   # 指定 Dockerfile
  # 或使用現有映像:
  # image: 'docker://alpine:3.18'
```

### Dockerfile 說明

```dockerfile
FROM alpine:3.18        # 基礎映像

RUN apk add --no-cache bash  # 安裝依賴

COPY entrypoint.sh /entrypoint.sh  # 複製腳本

RUN chmod +x /entrypoint.sh  # 設定執行權限

ENTRYPOINT ["/entrypoint.sh"]  # 設定進入點
```

## 🚀 如何使用

### 基本使用

在你的 workflow 中使用此 Action：

```yaml
name: Test Container Action
on: [push]

jobs:
  test:
    runs-on: ubuntu-latest  # 必須使用 Linux
    steps:
      - name: Checkout
        uses: actions/checkout@v4
      
      - name: Run Container Action
        id: process
        uses: ./.github/actions/container-action
        with:
          text_to_process: 'Hello GitHub Actions'
          operation: 'uppercase'
          output_format: 'text'
      
      - name: Show results
        run: |
          echo "結果: ${{ steps.process.outputs.result }}"
          echo "原始: ${{ steps.process.outputs.original }}"
          echo "操作: ${{ steps.process.outputs.operation-used }}"
          echo "環境變數: $PROCESSED_TEXT"
```

### 進階使用範例

```yaml
jobs:
  process-multiple:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        text: ['Hello', 'World', 'GitHub']
        operation: ['uppercase', 'lowercase', 'reverse']
    steps:
      - uses: actions/checkout@v4
      
      - name: Process text
        id: process
        uses: ./.github/actions/container-action
        with:
          text_to_process: ${{ matrix.text }}
          operation: ${{ matrix.operation }}
          output_format: 'json'
      
      - name: Display
        run: echo "${{ steps.process.outputs.result }}"
```

## 📥 輸入參數

| 參數名稱 | 描述 | 必填 | 預設值 | 選項 |
|---------|------|------|--------|------|
| `text_to_process` | 要處理的文字 | ✅ 是 | `Hello World` | 任何文字 |
| `operation` | 要執行的操作 | ❌ 否 | `uppercase` | `uppercase`, `lowercase`, `reverse` |
| `output_format` | 輸出格式 | ❌ 否 | `text` | `text`, `json` |

### 使用範例

```yaml
with:
  text_to_process: 'Sample Text'
  operation: 'reverse'
  output_format: 'json'
```

## 📤 輸出結果

| 輸出名稱 | 描述 | 範例 |
|---------|------|------|
| `result` | 處理後的結果 | `HELLO WORLD` |
| `original` | 原始輸入文字 | `hello world` |
| `operation-used` | 使用的操作 | `uppercase` |

### 使用輸出

```yaml
- name: Use outputs
  run: |
    echo "原始文字: ${{ steps.process.outputs.original }}"
    echo "處理結果: ${{ steps.process.outputs.result }}"
    echo "使用操作: ${{ steps.process.outputs.operation-used }}"
```

## 🔧 開發說明

### 1. Dockerfile 基礎知識

#### 選擇基礎映像

```dockerfile
# 輕量級 (推薦用於簡單腳本)
FROM alpine:3.18

# Ubuntu (更多預裝工具)
FROM ubuntu:22.04

# 特定語言環境
FROM python:3.11-slim
FROM node:20-alpine
```

#### 安裝依賴

```dockerfile
# Alpine
RUN apk add --no-cache bash curl jq

# Ubuntu/Debian
RUN apt-get update && apt-get install -y \
    bash \
    curl \
    jq \
    && rm -rf /var/lib/apt/lists/*
```

#### 複製檔案

```dockerfile
# 複製單一檔案
COPY entrypoint.sh /entrypoint.sh

# 複製多個檔案
COPY script1.sh script2.sh /scripts/

# 複製整個目錄
COPY ./app /app
```

### 2. Entrypoint 腳本

#### 讀取輸入參數

輸入參數會轉換為環境變數 `INPUT_<NAME>`：

```bash
#!/bin/bash

# action.yml 中的 text_to_process 變成 INPUT_TEXT-TO-PROCESS
TEXT="${INPUT_TEXT-TO-PROCESS}"
OPERATION="${INPUT_OPERATION}"

echo "文字: ${TEXT}"
echo "操作: ${OPERATION}"
```

#### 設定輸出結果

使用 `$GITHUB_OUTPUT`：

```bash
# 簡單輸出
echo "result=${RESULT}" >> $GITHUB_OUTPUT

# 多行輸出
echo "result<<EOF" >> $GITHUB_OUTPUT
echo "${MULTI_LINE_RESULT}" >> $GITHUB_OUTPUT
echo "EOF" >> $GITHUB_OUTPUT
```

#### 設定環境變數

使用 `$GITHUB_ENV`：

```bash
# 供後續步驟使用
echo "MY_VAR=${VALUE}" >> $GITHUB_ENV
```

#### 錯誤處理

```bash
#!/bin/bash
set -e  # 遇到錯誤立即退出

# 驗證輸入
if [ -z "${INPUT_TEXT}" ]; then
    echo "錯誤：text 參數為空"
    exit 1  # 非零退出碼表示失敗
fi

# Try-catch 風格
if ! command -v jq &> /dev/null; then
    echo "錯誤：jq 未安裝"
    exit 1
fi
```

### 3. 本地測試

#### 測試 Dockerfile

```bash
# 建置映像
docker build -t my-action .

# 執行測試
docker run --rm \
  -e INPUT_TEXT-TO-PROCESS="test text" \
  -e INPUT_OPERATION="uppercase" \
  my-action
```

#### 測試腳本

```bash
# 設定環境變數
export INPUT_TEXT-TO-PROCESS="test"
export INPUT_OPERATION="uppercase"
export GITHUB_OUTPUT="/tmp/output.txt"
export GITHUB_ENV="/tmp/env.txt"

# 執行腳本
bash entrypoint.sh

# 檢查輸出
cat /tmp/output.txt
cat /tmp/env.txt
```

## 🎓 進階功能

### 1. 使用已發布的映像

不使用 Dockerfile，直接使用 Docker Hub 上的映像：

```yaml
# action.yml
runs:
  using: 'docker'
  image: 'docker://alpine:3.18'
  entrypoint: '/bin/sh'
  args:
    - '-c'
    - |
      echo "執行簡單命令"
      echo "result=success" >> $GITHUB_OUTPUT
```

### 2. 使用多階段建置

優化映像大小：

```dockerfile
# 建置階段
FROM golang:1.21 AS builder
WORKDIR /app
COPY . .
RUN go build -o myapp

# 執行階段
FROM alpine:3.18
COPY --from=builder /app/myapp /usr/local/bin/
ENTRYPOINT ["myapp"]
```

### 3. 處理檔案操作

讀取和寫入工作區檔案：

```bash
#!/bin/bash

# GITHUB_WORKSPACE 指向儲存庫根目錄
WORKSPACE="${GITHUB_WORKSPACE}"

# 讀取檔案
if [ -f "${WORKSPACE}/config.json" ]; then
    CONFIG=$(cat "${WORKSPACE}/config.json")
    echo "設定: ${CONFIG}"
fi

# 寫入檔案
echo "處理結果" > "${WORKSPACE}/output.txt"

# 列出檔案
ls -la "${WORKSPACE}"
```

### 4. 使用 Python 腳本

```dockerfile
FROM python:3.11-slim

# 安裝依賴
COPY requirements.txt /
RUN pip install --no-cache-dir -r /requirements.txt

# 複製 Python 腳本
COPY process.py /process.py

# 設定進入點
ENTRYPOINT ["python", "/process.py"]
```

```python
# process.py
import os
import sys

def main():
    # 讀取輸入
    text = os.environ.get('INPUT_TEXT-TO-PROCESS', '')
    operation = os.environ.get('INPUT_OPERATION', 'uppercase')
    
    # 處理
    if operation == 'uppercase':
        result = text.upper()
    elif operation == 'lowercase':
        result = text.lower()
    else:
        result = text[::-1]  # reverse
    
    # 設定輸出
    with open(os.environ['GITHUB_OUTPUT'], 'a') as f:
        f.write(f'result={result}\n')
    
    print(f'✅ 處理完成: {result}')

if __name__ == '__main__':
    main()
```

### 5. 存取 GitHub API

```bash
#!/bin/bash

# 使用 GITHUB_TOKEN (自動提供)
TOKEN="${INPUT_GITHUB-TOKEN}"

# 呼叫 GitHub API
curl -H "Authorization: token ${TOKEN}" \
     -H "Accept: application/vnd.github.v3+json" \
     "https://api.github.com/repos/${GITHUB_REPOSITORY}"
```

在 action.yml 中添加 token 輸入：

```yaml
inputs:
  github-token:
    description: 'GitHub Token'
    required: true
    default: ${{ github.token }}
```

### 6. 快取優化

利用 Docker layer 快取加速建置：

```dockerfile
FROM node:20-alpine

# 先複製 package.json (變化較少)
COPY package*.json ./
RUN npm install

# 再複製程式碼 (變化較多)
COPY . .

ENTRYPOINT ["node", "index.js"]
```

## 🔍 除錯技巧

### 1. 在容器中輸出詳細資訊

```bash
#!/bin/bash
set -x  # 顯示執行的每個命令

echo "=== 環境變數 ==="
env | sort

echo "=== 工作目錄 ==="
pwd
ls -la

echo "=== 系統資訊 ==="
uname -a
```

### 2. 互動式測試

```bash
# 啟動容器並進入 shell
docker run -it --rm \
  -v $(pwd):/github/workspace \
  -e INPUT_TEXT-TO-PROCESS="test" \
  my-action /bin/sh

# 在容器內測試
/entrypoint.sh
```

### 3. 檢查映像大小

```bash
# 建置映像
docker build -t my-action .

# 檢查大小
docker images my-action

# 查看層級
docker history my-action
```

## 📦 映像大小優化

### 技巧 1：使用 Alpine

```dockerfile
# 改用 Alpine 版本
FROM python:3.11-alpine  # 而非 python:3.11
```

### 技巧 2：清理快取

```dockerfile
RUN apk add --no-cache bash curl \
    && rm -rf /var/cache/apk/*
```

### 技巧 3：多階段建置

```dockerfile
FROM golang:1.21 AS build
RUN go build -o app

FROM alpine:3.18
COPY --from=build /go/app /app
```

### 技巧 4：合併 RUN 指令

```dockerfile
# ❌ 不好 - 多個層級
RUN apk update
RUN apk add bash
RUN apk add curl

# ✅ 好 - 單一層級
RUN apk update && apk add --no-cache bash curl
```

## 📚 參考資源

- [GitHub Actions 官方文件](https://docs.github.com/en/actions)
- [Creating a Docker container action](https://docs.github.com/en/actions/creating-actions/creating-a-docker-container-action)
- [Dockerfile reference](https://docs.docker.com/engine/reference/builder/)
- [Best practices for writing Dockerfiles](https://docs.docker.com/develop/dev-best-practices/)

## 💡 最佳實踐

1. **使用輕量級映像**：優先選擇 Alpine 或 slim 版本
2. **固定版本**：使用特定版本標籤，避免使用 `latest`
3. **層級優化**：將較少變化的指令放在前面
4. **清理快取**：移除不必要的檔案和快取
5. **錯誤處理**：使用 `set -e` 確保錯誤被捕獲
6. **日誌清晰**：提供有意義的輸出訊息
7. **文件完整**：詳細說明使用方式和範例
8. **安全考量**：不要在映像中包含敏感資訊

## 🔐 安全注意事項

1. **不要硬編碼密鑰**：使用 secrets 和環境變數
2. **掃描漏洞**：定期更新基礎映像
3. **最小權限**：只安裝必要的套件
4. **驗證輸入**：不信任任何外部輸入
