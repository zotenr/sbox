FROM alpine:3.21

ARG TARGETARCH

RUN apk add --no-cache supervisor cloudflared openssh jq curl python3 ca-certificates tzdata

# 精简版 sing-box（vless/vmess + ws/http/httpupgrade/tcp + TLS/REALITY + 内置cloudflared隧道 + socks/http入口）
RUN set -eux; \
    ARCH="$TARGETARCH"; \
    [ "$TARGETARCH" = "arm" ] && ARCH="armv7"; \
    curl -fL --retry 3 -o /usr/local/bin/sbox "https://sb.vir.kdns.fr/sbox-${ARCH}"; \
    chmod +x /usr/local/bin/sbox; \
    /usr/local/bin/sbox version | head -1

COPY sbox_app.py /opt/sbox/sbox_app.py
COPY entrypoint.sh /entrypoint.sh
COPY svm /usr/local/bin/svm
RUN chmod +x /entrypoint.sh /usr/local/bin/svm

ENV SSH_ENABLED=false \
    SSH_PORT=2022 \
    SSH_PUBLIC_KEY="" \
    CLFL_TOKEN="" \
    SBOX_BIN=/usr/local/bin/sbox \
    FILE_PATH=/var/lib/sbox \
    PORT=3000 \
    SHOW_LOG=true \
    TZ=UTC

EXPOSE 22 3000

ENTRYPOINT ["/entrypoint.sh"]
