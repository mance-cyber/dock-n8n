FROM n8nio/n8n:latest

USER root

# 安裝 ffmpeg、curl 同繁中字體
RUN apk update && apk add --no-cache \
    ffmpeg \
    curl \
    font-noto-cjk \
    fontconfig \
    && fc-cache -f -v

# 創建工作目錄
RUN mkdir -p /data/videos && chown -R node:node /data

USER node

# 設定環境變數
ENV N8N_DEFAULT_BINARY_DATA_MODE=filesystem
ENV N8N_USER_FOLDER=/home/node/.n8n
ENV EXECUTIONS_DATA_SAVE_ON_ERROR=all
ENV EXECUTIONS_DATA_SAVE_ON_SUCCESS=all

EXPOSE 5678

CMD ["n8n"]
