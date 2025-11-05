# Container Action 使用 Alpine Linux 作為基礎映像
FROM alpine:3.18

# 安裝必要的套件
RUN apk add --no-cache \
    bash \
    jq \
    python3 \
    py3-pip

# 複製執行腳本到容器
COPY entrypoint.sh /entrypoint.sh

# 設定執行權限
RUN chmod +x /entrypoint.sh

# 設定工作目錄
WORKDIR /github/workspace

# 設定容器的進入點
ENTRYPOINT ["/entrypoint.sh"]
