# Render Free — xray VLESS+WS (B 路线：Docker 多阶段)
# 官方 ghcr.io/xtls/xray-core 没 shell，直接用起不来；多阶段把二进制叠到带 shell 的 Alpine。
# Render 侧 TLS 由平台托管，容器内只走 WS 明文；出口 *.onrender.com 为 HTTPS。
# syntax=docker/dockerfile:1
FROM ghcr.io/xtls/xray-core:latest AS xray
FROM alpine:3.20
RUN apk add --no-cache ca-certificates
COPY --from=xray /usr/local/bin/xray /usr/local/bin/xray
COPY --from=xray /usr/local/share/xray/geoip.dat /usr/local/share/xray/geoip.dat
COPY --from=xray /usr/local/share/xray/geosite.dat /usr/local/share/xray/geosite.dat
COPY entrypoint.sh /entrypoint.sh
COPY config.template.json /etc/xray/config.template.json
RUN chmod +x /entrypoint.sh /usr/local/bin/xray
# Render 注入 PORT（默认 10000）；不要写死端口
EXPOSE 10000
ENTRYPOINT ["/entrypoint.sh"]
