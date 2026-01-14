# n8n with FFmpeg - Zeabur 部署指南

呢個係自訂嘅 n8n Docker image，包含：
- ✅ FFmpeg（視頻處理）
- ✅ curl（下載文件）
- ✅ Noto Sans CJK 字體（繁體中文字幕）

## 部署步驟

### 方法 1：透過 GitHub Repo 部署（推薦）

1. **創建 GitHub Repo**
   - 將 `Dockerfile` 同 `zeabur.json` 上傳到新嘅 GitHub repo

2. **連接 Zeabur**
   - 登入 [Zeabur Dashboard](https://dash.zeabur.com)
   - 點擊 "New Project" → "Deploy from GitHub"
   - 選擇你嘅 repo

3. **設定環境變數**
   在 Zeabur 嘅 Variables 頁面加入：
   ```
   N8N_BASIC_AUTH_USER=你的用戶名
   N8N_BASIC_AUTH_PASSWORD=你的密碼
   N8N_ENCRYPTION_KEY=隨機32字符字串
   ```

4. **綁定 Domain**
   - 喺 Networking 設定自訂域名
   - 或者使用 Zeabur 提供嘅 `.zeabur.app` 域名

### 方法 2：使用現有 n8n 服務 + 遷移

如果你已經有 n8n 數據：

1. **備份現有數據**
   ```bash
   # 導出 workflows
   n8n export:workflow --all --output=workflows.json
   
   # 導出 credentials（加密）
   n8n export:credentials --all --output=credentials.json
   ```

2. **部署新 image**
   - 跟隨方法 1 部署

3. **導入數據**
   ```bash
   n8n import:workflow --input=workflows.json
   n8n import:credentials --input=credentials.json
   ```

## 驗證安裝

部署完成後，可以喺 n8n 用 Execute Command node 測試：

```bash
# 測試 ffmpeg
ffmpeg -version

# 測試字體
fc-list | grep -i noto

# 測試 curl
curl --version
```

## 視頻輸出目錄

預設視頻輸出目錄：`/data/videos`

喺 workflow 入面設定 `output_folder` 為 `/data/videos` 或其他你想用嘅路徑。

## 注意事項

1. **記憶體**：視頻處理需要較多記憶體，建議至少 1GB RAM
2. **存儲**：視頻文件較大，確保有足夠存儲空間
3. **超時**：長視頻處理可能超時，需要調整 `EXECUTIONS_TIMEOUT`

## 環境變數說明

| 變數 | 說明 | 預設值 |
|------|------|--------|
| N8N_BASIC_AUTH_USER | 登入用戶名 | - |
| N8N_BASIC_AUTH_PASSWORD | 登入密碼 | - |
| N8N_ENCRYPTION_KEY | 加密密鑰 | - |
| GENERIC_TIMEZONE | 時區 | Asia/Hong_Kong |
| EXECUTIONS_TIMEOUT | 執行超時（秒） | 3600 |

## 故障排除

### FFmpeg 無法找到字體
```bash
# 重新生成字體緩存
fc-cache -f -v
```

### 視頻處理超時
在 Zeabur Variables 加入：
```
EXECUTIONS_TIMEOUT=7200
```

### 存儲空間不足
考慮：
1. 定期清理臨時文件
2. 使用外部存儲（S3/R2）
3. 升級 Zeabur 計劃
