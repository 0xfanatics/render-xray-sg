#!/bin/sh
# Render xray entrypoint：按环境变量生成配置并拉起 VLESS+WS
# 必需：UUID、WS_PATH；PORT 由 Render 注入，默认 10000
set -eu
PORT="${PORT:-10000}"
: "${UUID:?UUID env var is required}"
: "${WS_PATH:?WS_PATH env var is required}"
# WS_PATH 必须以 / 开头
case "$WS_PATH" in
  /*) ;;
  *) WS_PATH="/$WS_PATH" ;;
esac
mkdir -p /etc/xray
# 用 shell heredoc 生成配置（UUID 为标准 uuid 格式、WS_PATH 为 /+hex，无需 JSON 转义）
cat > /etc/xray/config.json <<EOF
{
  "log": { "loglevel": "warning" },
  "inbounds": [
    {
      "port": ${PORT},
      "listen": "0.0.0.0",
      "protocol": "vless",
      "settings": {
        "clients": [{ "id": "${UUID}", "flow": "" }],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "ws",
        "wsSettings": { "path": "${WS_PATH}" }
      }
    }
  ],
  "outbounds": [
    { "protocol": "freedom", "settings": {} },
    { "protocol": "blackhole", "settings": {}, "tag": "blocked" }
  ]
}
EOF
echo "xray starting: port=${PORT} ws_path=${WS_PATH}"
exec /usr/local/bin/xray run -config /etc/xray/config.json
