# Container Action 使用 Bash 作為基礎映像
FROM bash:5.2-alpine3.18

# 安裝 jq 用於 JSON 處理
RUN apk add --no-cache jq || true

# 複製執行腳本到容器
COPY entrypoint.sh /entrypoint.sh

# 設定執行權限
RUN chmod +x /entrypoint.sh

# 設定工作目錄
WORKDIR /github/workspace

# 設定容器的進入點
ENTRYPOINT ["/entrypoint.sh"]
