########################################
# Stage 1: 安裝 FFmpeg 同字體
########################################
FROM alpine:3.19 AS builder

RUN apk update && apk add --no-cache \
    ffmpeg \
    curl \
    font-noto-cjk \
    fontconfig \
    libass \
    && fc-cache -f -v

########################################
# Stage 2: 最終 n8n image
########################################
FROM n8nio/n8n:latest

USER root

# 從 builder 複製 ffmpeg 同相關 libraries
COPY --from=builder /usr/bin/ffmpeg /usr/bin/ffmpeg
COPY --from=builder /usr/bin/ffprobe /usr/bin/ffprobe
COPY --from=builder /usr/bin/curl /usr/bin/curl

# 複製 ffmpeg 依賴嘅 libraries
COPY --from=builder /usr/lib/libavcodec.so* /usr/lib/
COPY --from=builder /usr/lib/libavformat.so* /usr/lib/
COPY --from=builder /usr/lib/libavutil.so* /usr/lib/
COPY --from=builder /usr/lib/libswscale.so* /usr/lib/
COPY --from=builder /usr/lib/libswresample.so* /usr/lib/
COPY --from=builder /usr/lib/libavfilter.so* /usr/lib/
COPY --from=builder /usr/lib/libavdevice.so* /usr/lib/
COPY --from=builder /usr/lib/libpostproc.so* /usr/lib/
COPY --from=builder /usr/lib/libass.so* /usr/lib/
COPY --from=builder /usr/lib/libfribidi.so* /usr/lib/
COPY --from=builder /usr/lib/libharfbuzz.so* /usr/lib/
COPY --from=builder /usr/lib/libfontconfig.so* /usr/lib/
COPY --from=builder /usr/lib/libfreetype.so* /usr/lib/
COPY --from=builder /usr/lib/libpng*.so* /usr/lib/
COPY --from=builder /usr/lib/libbz2.so* /usr/lib/
COPY --from=builder /usr/lib/libbrotli*.so* /usr/lib/
COPY --from=builder /usr/lib/libexpat.so* /usr/lib/
COPY --from=builder /usr/lib/libglib*.so* /usr/lib/
COPY --from=builder /usr/lib/libintl.so* /usr/lib/
COPY --from=builder /usr/lib/libpcre*.so* /usr/lib/
COPY --from=builder /usr/lib/libx264.so* /usr/lib/
COPY --from=builder /usr/lib/libx265.so* /usr/lib/
COPY --from=builder /usr/lib/libvpx.so* /usr/lib/
COPY --from=builder /usr/lib/libmp3lame.so* /usr/lib/
COPY --from=builder /usr/lib/libopus.so* /usr/lib/
COPY --from=builder /usr/lib/libvorbis*.so* /usr/lib/
COPY --from=builder /usr/lib/libogg.so* /usr/lib/
COPY --from=builder /usr/lib/libtheora*.so* /usr/lib/
COPY --from=builder /usr/lib/libwebp*.so* /usr/lib/
COPY --from=builder /usr/lib/libaom.so* /usr/lib/
COPY --from=builder /usr/lib/libdav1d.so* /usr/lib/
COPY --from=builder /usr/lib/librav1e.so* /usr/lib/
COPY --from=builder /usr/lib/libSvtAv1*.so* /usr/lib/
COPY --from=builder /usr/lib/libssl.so* /usr/lib/
COPY --from=builder /usr/lib/libcrypto.so* /usr/lib/
COPY --from=builder /usr/lib/libcurl.so* /usr/lib/
COPY --from=builder /usr/lib/libnghttp2.so* /usr/lib/
COPY --from=builder /usr/lib/libzstd.so* /usr/lib/
COPY --from=builder /lib/libz.so* /lib/

# 複製字體
COPY --from=builder /usr/share/fonts /usr/share/fonts
COPY --from=builder /etc/fonts /etc/fonts
COPY --from=builder /var/cache/fontconfig /var/cache/fontconfig

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
