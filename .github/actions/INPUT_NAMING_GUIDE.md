# GitHub Actions 輸入參數命名注意事項

## 重要提示

在 GitHub Actions 中，輸入參數名稱會轉換為環境變數。為了確保相容性，建議使用**底線 (`_`)** 而非**破折號 (`-`)**。

### 原因

- GitHub Actions 將輸入參數轉換為環境變數時，會將破折號轉換為底線
- 某些 shell 環境不接受包含破折號的變數名稱
- 使用底線可以確保在所有環境下都能正常運作

### 範例

#### ✅ 推薦做法

```yaml
inputs:
  who_to_greet:
    description: '要問候的人名'
    required: true
```

使用時：
```yaml
- uses: ./.github/actions/my-action
  with:
    who_to_greet: 'World'
```

在程式中存取：
```javascript
// JavaScript
const name = core.getInput('who_to_greet');
```

```bash
# Bash
NAME="${INPUT_WHO_TO_GREET}"
```

#### ❌ 不推薦做法

```yaml
inputs:
  who-to-greet:  # 使用破折號
    description: '要問候的人名'
    required: true
```

這可能會在某些情況下導致問題。

## 本專案的命名慣例

本專案中的所有輸入參數都使用底線命名：

### JavaScript Action
- `who_to_greet` ✓
- `message_prefix` ✓

### Container Action
- `text_to_process` ✓
- `operation` ✓
- `output_format` ✓

## 參考資料

- [GitHub Actions - Metadata syntax for GitHub Actions](https://docs.github.com/en/actions/creating-actions/metadata-syntax-for-github-actions)
- [GitHub Actions - Environment variables](https://docs.github.com/en/actions/learn-github-actions/variables)
