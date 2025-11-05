以下內容提供兩種 GitHub Actions 型態：自訂 Container Action 與 JavaScript Action（Node.js Action）的「完整範例 + 詳細說明 + 進階技巧」。  
範例均採用繁體中文說明，並示範目錄結構、action.yml、程式碼、建置與本地測試方式、安全與最佳化策略。你可以直接複製使用或調整。  

---

## 目錄總覽

1. 何時選擇 Container Action vs JavaScript Action  
2. Container Action：完整實作  
3. JavaScript (Node.js) Action：完整實作  
4. Workflow 使用範例  
5. 測試與除錯技巧（act、本地 docker、單元測試）  
6. 常見輸入輸出與資料跨步驟傳遞  
7. 安全性與最佳化建議  
8. 進階：多平台、Matrix、快取、向後相容  
9. 常見問題 FAQ

---

## 1. 選擇指引：Container Action vs JavaScript Action

| 面向 | Container Action | JavaScript Action |
|------|------------------|------------------|
| 執行環境控制 | 完全自訂：OS、套件、工具版本 | 受 GitHub Runner Node 版本限制 (目前 Node20/Node16) |
| 相依套件安裝速度 | 首次拉取較慢（需拉 Docker Image） | 透過 `actions/setup-node` + npm/yarn/pnpm 安裝 |
| 適合場景 | 需特定 CLI、需 OS-level 套件、需多語言混合 | 輕量邏輯、調用 API、處理檔案、GitHub 自動化 |
| 可移植性 | Docker 映像可跨平台重用 | Node.js 為主，其他語言需額外橋接 |
| 效能 | 若大量相依反覆使用可快取 image 層 | 啟動快，適合頻繁觸發 |
| 開發舒適度 | 需掌握 Dockerfile | JS 開發者容易上手 |
| 安全控管 | 映像需定期掃描 | 需維護依賴安全（Dependabot） |

---

## 2. 自訂 Container Action：完整實作

### 2.1 目錄結構範例

```
container-action/
├─ action.yml
├─ Dockerfile
├─ entrypoint.sh
├─ scripts/
│  └─ helper.sh
└─ README.md
```

### 2.2 action.yml (定義輸入/輸出)

```yaml name=container-action/action.yml
name: "Example Container Action"
description: "以 Docker 容器執行的範例，示範輸入、輸出與檔案處理"
author: "你的名稱"
inputs:
  message:
    description: "要輸出的訊息"
    required: true
  fail-on-empty:
    description: "若 message 為空是否失敗"
    required: false
    default: "true"
outputs:
  uppercased:
    description: "大寫後的訊息"
runs:
  using: "docker"
  image: "Dockerfile"
  args:
    - ${{ inputs.message }}
    - ${{ inputs.fail-on-empty }}
branding:
  icon: "package"
  color: "blue"
```

### 2.3 Dockerfile

```dockerfile name=container-action/Dockerfile
FROM ubuntu:22.04

# 保持映像精簡：清除 apt cache
RUN apt-get update \
  && apt-get install -y --no-install-recommends ca-certificates curl jq bash \
  && rm -rf /var/lib/apt/lists/*

# 建立非 root 使用者（安全最佳化）
RUN useradd -ms /bin/bash actionuser
WORKDIR /workspace

COPY entrypoint.sh /entrypoint.sh
COPY scripts/ ./scripts/
RUN chmod +x /entrypoint.sh ./scripts/helper.sh

USER actionuser

ENTRYPOINT ["/entrypoint.sh"]
```

### 2.4 entrypoint.sh

```bash name=container-action/entrypoint.sh
#!/usr/bin/env bash
set -euo pipefail

MESSAGE="${1:-}"
FAIL_ON_EMPTY="${2:-true}"

if [[ -z "$MESSAGE" ]]; then
  if [[ "$FAIL_ON_EMPTY" == "true" ]]; then
    echo "訊息為空，失敗退出" >&2
    exit 1
  else
    MESSAGE="(empty)"
  fi
fi

# 呼叫額外腳本
UPPER=$(bash ./scripts/helper.sh "$MESSAGE")

echo "原始訊息: $MESSAGE"
echo "大寫後: $UPPER"

# 以 GitHub Actions 規範設定輸出 (新版建議寫入 GITHUB_OUTPUT)
echo "uppercased=$UPPER" >> "$GITHUB_OUTPUT"
```

### 2.5 scripts/helper.sh

```bash name=container-action/scripts/helper.sh
#!/usr/bin/env bash
set -euo pipefail
INPUT="${1:-}"
echo "${INPUT^^}"
```

### 2.6 README (必要文檔)

````markdown name=container-action/README.md
# Example Container Action

## 使用方式

```yaml
jobs:
  demo:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run container action
        uses: ./container-action
        with:
          message: "Hello Container"
      - name: Show output
        run: echo "Upper: ${{ steps.demo.outputs.uppercased }}"
```

## 輸入
- message (必填)
- fail-on-empty (預設 true)

## 輸出
- uppercased

## 本地測試
```bash
docker build -t my-container-action ./container-action
docker run --rm my-container-action "test" "true"
```

## 安全建議
- 使用非 root 使用者
- 固定映像基底版本與 digest
- 定期掃描 (Trivy, Grype)
````

---

## 3. JavaScript (Node.js) Action：完整實作

### 3.1 目錄結構

```
js-action/
├─ action.yml
├─ package.json
├─ src/
│  └─ main.ts
├─ dist/
│  └─ index.js   (由 ncc 編譯後產生)
├─ tsconfig.json
├─ README.md
```

建議使用 TypeScript + `@vercel/ncc` 打包，避免安裝一堆 node_modules。

### 3.2 action.yml

```yaml name=js-action/action.yml
name: "Example JS Action"
description: "使用 Node.js 的 GitHub Action，示範輸入、輸出與錯誤處理"
author: "你的名稱"
inputs:
  token:
    description: "GitHub Token (自動用 secrets.GITHUB_TOKEN)"
    required: true
  issue-number:
    description: "要讀取的 Issue 編號"
    required: true
  to-upper:
    description: "是否將 title 轉大寫"
    required: false
    default: "false"
outputs:
  original-title:
    description: "原始 issue title"
  transformed-title:
    description: "處理後的 issue title"
runs:
  using: "node20"
  main: "dist/index.js"
permissions:
  issues: read
  contents: read
branding:
  icon: "code"
  color: "green"
```

### 3.3 package.json

```json name=js-action/package.json
{
  "name": "example-js-action",
  "version": "1.0.0",
  "private": true,
  "scripts": {
    "build": "ncc build src/main.ts -o dist",
    "lint": "eslint src --ext .ts",
    "test": "vitest run"
  },
  "dependencies": {
    "@actions/core": "^1.10.1",
    "@actions/github": "^6.0.0"
  },
  "devDependencies": {
    "@types/node": "^20.11.0",
    "typescript": "^5.4.0",
    "@vercel/ncc": "^0.38.0",
    "eslint": "^9.0.0",
    "vitest": "^2.0.0"
  }
}
```

### 3.4 tsconfig.json

```json name=js-action/tsconfig.json
{
  "compilerOptions": {
    "target": "ES2020",
    "lib": ["ES2020"],
    "module": "CommonJS",
    "strict": true,
    "esModuleInterop": true,
    "outDir": "build",
    "resolveJsonModule": true,
    "skipLibCheck": true
  },
  "include": ["src"]
}
```

### 3.5 src/main.ts

```typescript name=js-action/src/main.ts
import * as core from '@actions/core';
import * as github from '@actions/github';

async function run(): Promise<void> {
  try {
    const token = core.getInput('token', { required: true });
    const issueNumberStr = core.getInput('issue-number', { required: true });
    const toUpper = core.getInput('to-upper') === 'true';

    const issueNumber = parseInt(issueNumberStr, 10);
    if (Number.isNaN(issueNumber)) {
      core.setFailed(`issue-number 必須是數字，收到: ${issueNumberStr}`);
      return;
    }

    const octokit = github.getOctokit(token);
    const { repo, owner } = github.context.repo;

    const issueResp = await octokit.rest.issues.get({
      owner,
      repo,
      issue_number: issueNumber
    });

    const originalTitle = issueResp.data.title;
    const transformedTitle = toUpper ? originalTitle.toUpperCase() : originalTitle;

    core.info(`原始標題: ${originalTitle}`);
    core.info(`處理後標題: ${transformedTitle}`);

    core.setOutput('original-title', originalTitle);
    core.setOutput('transformed-title', transformedTitle);

  } catch (err: any) {
    if (err instanceof Error) {
      core.setFailed(`Action 失敗: ${err.message}`);
    } else {
      core.setFailed('未知錯誤');
    }
  }
}

run();
```

編譯後會產生 `dist/index.js`（不需手動編輯）。

### 3.6 README

````markdown name=js-action/README.md
# Example JS Action

## 使用

```yaml
jobs:
  demo-js:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run JS Action
        uses: ./js-action
        with:
          token: ${{ secrets.GITHUB_TOKEN }}
          issue-number: 123
          to-upper: true
      - name: Show Outputs
        run: |
          echo "Original: ${{ steps.demo-js.outputs.original-title }}"
          echo "Transformed: ${{ steps.demo-js.outputs.transformed-title }}"
```

## 建置
```bash
npm install
npm run build
```

## 測試
```bash
npm test
```

## 為何要打包 (ncc)
- 將所有依賴合併單一檔案
- 減少取用 node_modules 的時間
- 避免遺漏相依

## 安全
- 使用 GITHUB_TOKEN least privilege
- 定期跑 Dependabot
````

---

## 4. Workflow 使用範例

### 4.1 同時使用兩種 Action

```yaml name=.github/workflows/demo-actions.yml
name: Demo Both Actions

on:
  workflow_dispatch:
  pull_request:
    types: [opened, synchronize]

jobs:
  container:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run container action
        id: container_step
        uses: ./container-action
        with:
          message: "Hello From Container"
          fail-on-empty: "false"
      - name: Show container output
        run: echo "Uppercased=${{ steps.container_step.outputs.uppercased }}"

  jsaction:
    runs-on: ubuntu-latest
    needs: container
    steps:
      - uses: actions/checkout@v4
      - name: Run JS action
        id: js_step
        uses: ./js-action
        with:
          token: ${{ secrets.GITHUB_TOKEN }}
          issue-number: 1
          to-upper: true
      - name: Print JS outputs
        run: |
          echo "Original=${{ steps.js_step.outputs.original-title }}"
          echo "Transformed=${{ steps.js_step.outputs.transformed-title }}"
```

### 4.2 Matrix + 快取 (Node)

```yaml name=.github/workflows/js-matrix.yml
name: JS Matrix Test

on: push

jobs:
  build:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        node: [18, 20]
    steps:
      - uses: actions/checkout@v4
      - name: Use Node
        uses: actions/setup-node@v4
        with:
          node-version: ${{ matrix.node }}
          cache: npm
      - run: npm ci
      - run: npm test
```

---

## 5. 測試與除錯技巧

| 方法 | 適用於 | 作法 |
|------|--------|------|
| act (第三方工具) | 模擬 GitHub Runner | 安裝 act，於 repo 執行 `act -j container` |
| docker run | Container Action | `docker build -t myact ./container-action && docker run --rm myact "msg" "true"` |
| Node 單元測試 | JS Action 邏輯 | 使用 Vitest/Jest。將核心邏輯抽出為純函式以方便測試 |
| core.debug | JS Action | `core.debug('變數: ' + value)`，需在 workflow 啟用 `ACTIONS_STEP_DEBUG` |
| 步驟輸出檢視 | 兩者 | 檢查 Summary (新版 UI) 和 logs |

啟用除錯環境變數：
```yaml
env:
  ACTIONS_STEP_DEBUG: true
  ACTIONS_RUNNER_DEBUG: true
```

---

## 6. 輸入輸出與資料傳遞

1. 輸入由 `action.yml` 的 `inputs` 定義，在 JS 用 `core.getInput()`，在 Container 用 args 或環境變數。
2. 輸出必須寫入 `$GITHUB_OUTPUT`（新標準）。  
   Container: `echo "myout=value" >> $GITHUB_OUTPUT`  
   JS: `core.setOutput('myout', value)`
3. 跨步驟引用：`steps.<id>.outputs.<outputName>`  
4. 暫存檔案分享：可使用 `actions/upload-artifact@v4`/`download-artifact@v4`。

---

## 7. 安全性與最佳化建議

- 最小權限：在 workflow `permissions` 區段限制 scope。例如：
  ```yaml
  permissions:
    contents: read
    issues: read
  ```
- 避免硬編碼 Token：使用 `secrets.GITHUB_TOKEN` 或 PAT。
- Container 映像：
  - 使用 digest pin：`FROM ubuntu@sha256:<digest>`。
  - 扫描: Trivy (`trivy image my-image`)、Grype。
- JS 相依：
  - 啟用 Dependabot (`.github/dependabot.yml`)。
  - 避免執行不信任的子程序。
- 不要將敏感資訊印在 logs：改用 `core.setSecret()`（遮罩）。
- 防止輸入注入：
  - shell 指令使用陣列語法而非字串拼接（Container entrypoint）。
  - JS 嚴格驗證輸入型態。

---

## 8. 進階技巧

### 8.1 多平台 Container
如果需要 multi-arch (arm64 + amd64)，可使用 buildx：
```bash
docker buildx build --platform linux/amd64,linux/arm64 -t ghcr.io/owner/action:latest --push .
```

### 8.2 Layer 最佳化順序
將變動頻率低的步驟放前面（例如：安裝系統套件）以增加快取命中。

### 8.3 JS Action 維護向後相容
- 避免移除既有輸出命名。
- 重大變更提升 major 版本並標記 release：`v2` tag。

### 8.4 使用 GitHub API 速率最佳化
- 合理重用 octokit 實例。
- 批次查詢（GraphQL）降低 REST 多次呼叫。

### 8.5 Composite Action?
雖本次重點不在 Composite，但若要組合多個 shell/其他 actions 可用：
```yaml
runs:
  using: "composite"
  steps:
    - run: echo "Hello"
      shell: bash
```
適合簡單聚合，不適用需客製 runtime 的場景。

---

## 9. 常見問題 FAQ

| 問題 | 解答 |
|------|------|
| 為何我的 Container Action 無法取得輸入？ | 確認 `action.yml` 中 `args:` 順序與 `steps.uses.with` 對應。 |
| 為何 JS Action 無法使用 `node12`？ | GitHub 已淘汰舊 runtime，請改用 `node16` 或 `node20`。 |
| 要不要提交 `dist/`？ | JS Action 通常要提交打包後檔案（使用者才能直接引用 tag）。 |
| 可以同一 Repo 放多個 actions？ | 可以，使用者以 `uses: owner/repo/path/to/action` 方式。 |
| 如何調試輸出不出來？ | 確認使用 `$GITHUB_OUTPUT` 而非舊的 `::set-output`（已棄用）。 |
| Container Action 一定要 ENTRYPOINT? | 建議使用，確保參數與環境一致。 |
| 為何 build 很慢？ | 採用較小 base image (alpine/ubi)，利用快取策略。 |

---

## 額外建議

- 在 repo 加上 `release` 與對應 tag：`v1`, `v1.1.0`，讓使用者穩定引用。
- 加入 CI 對 Action 自動測試（可建立一個 workflow 使用自己 action）。
- 撰寫 CHANGELOG：透明版本差異。
- 加入使用限制（Rate limit / retry/backoff）。

---

## 快速複製指引

1. 將上述 `container-action` 與 `js-action` 目錄加入你的 repository。
2. 執行：
   ```bash
   cd js-action
   npm install
   npm run build
   git add .
   git commit -m "Add container & js actions"
   git tag -a v1 -m "Initial version"
   git push --tags
   ```
3. Workflow 中引用：
   ```yaml
   - uses: lettucebo/20251105-GH200/js-action@v1
   ```
   若在同一 repo 且未發佈 tag，可相對路徑：
   ```yaml
   - uses: ./js-action
   ```

---

若你希望我「再延伸：加入測試框架示例、Dependabot 設定、版本升級策略、自動釋出 Workflow」等，告訴我，我可以繼續補充。  
需要再產生英文版或簡化版也可以提出需求。  

有任何特定情境（例如：要呼叫 Azure CLI、Terraform、或整合 Bicep）都可以再細化容器內容。  
請告訴我下一步想深入哪一塊。
