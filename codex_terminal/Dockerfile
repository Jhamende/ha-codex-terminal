FROM alpine:3.23

ARG BUILD_VERSION
ARG BUILD_ARCH

LABEL \
  io.hass.version="${BUILD_VERSION}" \
  io.hass.type="app" \
  io.hass.arch="${BUILD_ARCH}"

RUN apk add --no-cache \
      bash \
      ca-certificates \
      curl \
      git \
      jq \
      nodejs \
      npm \
      openssh-client \
      ripgrep \
      ttyd \
    && npm install --global @openai/codex \
    && npm cache clean --force \
    && adduser -D -h /data/codex codex \
    && mkdir -p /data/codex /config /share \
    && chown -R codex:codex /data/codex

COPY run.sh /run.sh
COPY terminal.sh /usr/local/bin/codex-terminal

RUN chmod 0755 /run.sh /usr/local/bin/codex-terminal

EXPOSE 8099

CMD ["/run.sh"]
