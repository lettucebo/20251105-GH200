#!/bin/bash

###############################################################################
# Container Action 執行腳本
#
# 此腳本示範：
# 1. 如何讀取輸入參數 (透過環境變數)
# 2. 如何處理資料
# 3. 如何設定輸出結果
# 4. 如何進行錯誤處理
###############################################################################

set -e  # 遇到錯誤立即退出

# 顏色輸出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 函數：輸出資訊
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

###############################################################################
# 1. 讀取輸入參數
###############################################################################

log_info "讀取輸入參數..."

# GitHub Actions 會將輸入轉換為環境變數: INPUT_<INPUT_NAME>
TEXT_TO_PROCESS="${INPUT_TEXT_TO_PROCESS}"
OPERATION="${INPUT_OPERATION}"
OUTPUT_FORMAT="${INPUT_OUTPUT_FORMAT}"

echo "📥 輸入參數:"
echo "  - 文字: ${TEXT_TO_PROCESS}"
echo "  - 操作: ${OPERATION}"
echo "  - 輸出格式: ${OUTPUT_FORMAT}"
echo ""

###############################################################################
# 2. 驗證輸入
###############################################################################

if [ -z "${TEXT_TO_PROCESS}" ]; then
    log_error "錯誤：text-to-process 參數為空"
    exit 1
fi

###############################################################################
# 3. 執行主要邏輯
###############################################################################

log_info "開始處理文字..."

RESULT=""

case "${OPERATION}" in
    "uppercase")
        log_info "將文字轉換為大寫..."
        RESULT=$(echo "${TEXT_TO_PROCESS}" | tr '[:lower:]' '[:upper:]')
        ;;
    "lowercase")
        log_info "將文字轉換為小寫..."
        RESULT=$(echo "${TEXT_TO_PROCESS}" | tr '[:upper:]' '[:lower:]')
        ;;
    "reverse")
        log_info "反轉文字..."
        RESULT=$(echo "${TEXT_TO_PROCESS}" | rev)
        ;;
    *)
        log_error "未知的操作: ${OPERATION}"
        log_warning "支援的操作: uppercase, lowercase, reverse"
        exit 1
        ;;
esac

###############################################################################
# 4. 輸出結果
###############################################################################

log_success "處理完成！"
echo ""
echo "📤 處理結果:"

if [ "${OUTPUT_FORMAT}" = "json" ]; then
    # JSON 格式輸出 (如果有 jq)
    if command -v jq &> /dev/null; then
        JSON_OUTPUT=$(jq -n \
            --arg original "${TEXT_TO_PROCESS}" \
            --arg result "${RESULT}" \
            --arg operation "${OPERATION}" \
            '{
                original: $original,
                result: $result,
                operation: $operation,
                timestamp: now | strftime("%Y-%m-%d %H:%M:%S")
            }')
        
        echo "${JSON_OUTPUT}" | jq '.'
    else
        # 簡單的 JSON 格式 (不使用 jq)
        echo "{"
        echo "  \"original\": \"${TEXT_TO_PROCESS}\","
        echo "  \"result\": \"${RESULT}\","
        echo "  \"operation\": \"${OPERATION}\","
        echo "  \"timestamp\": \"$(date '+%Y-%m-%d %H:%M:%S')\""
        echo "}"
    fi
    
    # 設定輸出 (JSON 需要轉義)
    echo "result=${RESULT}" >> $GITHUB_OUTPUT
    echo "original=${TEXT_TO_PROCESS}" >> $GITHUB_OUTPUT
    echo "operation-used=${OPERATION}" >> $GITHUB_OUTPUT
    
else
    # 純文字格式
    echo "  原始文字: ${TEXT_TO_PROCESS}"
    echo "  執行操作: ${OPERATION}"
    echo "  處理結果: ${RESULT}"
    
    # 設定輸出給 GitHub Actions
    echo "result=${RESULT}" >> $GITHUB_OUTPUT
    echo "original=${TEXT_TO_PROCESS}" >> $GITHUB_OUTPUT
    echo "operation-used=${OPERATION}" >> $GITHUB_OUTPUT
fi

###############################################################################
# 5. 設定環境變數 (供後續步驟使用)
###############################################################################

echo "PROCESSED_TEXT=${RESULT}" >> $GITHUB_ENV

###############################################################################
# 6. 額外資訊 - 顯示系統資訊
###############################################################################

echo ""
log_info "容器環境資訊:"
echo "  - 主機名稱: $(hostname)"
echo "  - 作業系統: $(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)"
echo "  - Bash 版本: ${BASH_VERSION}"

###############################################################################
# 7. 檢查是否在 GitHub Workspace
###############################################################################

if [ -n "${GITHUB_WORKSPACE}" ]; then
    echo ""
    log_info "GitHub Workspace 資訊:"
    echo "  - 工作目錄: ${GITHUB_WORKSPACE}"
    echo "  - 儲存庫: ${GITHUB_REPOSITORY:-N/A}"
    echo "  - 分支: ${GITHUB_REF:-N/A}"
    echo "  - SHA: ${GITHUB_SHA:-N/A}"
    echo "  - 執行者: ${GITHUB_ACTOR:-N/A}"
fi

echo ""
log_success "Container Action 執行完成！"

exit 0
