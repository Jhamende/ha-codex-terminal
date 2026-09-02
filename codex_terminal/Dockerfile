FROM alpine:3.23

ARG BUILD_VERSION
ARG BUILD_ARCH

LABEL \
  io.hass.version="${BUILD_VERSION}" \
  io.hass.type="app" \
  io.hass.arch="${BUILD_ARCH}"

ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    TERM=xterm-256color \
    COLORTERM=truecolor

RUN apk add --no-cache \
      bash \
      ca-certificates \
      curl \
      git \
      jq \
      nodejs \
      npm \
      openssh-client \
      python3 \
      ripgrep \
      ttyd \
    && npm install --global @openai/codex@0.152.1 \
    && codex --version \
    && npm cache clean --force \
    && adduser -D -h /data/codex codex \
    && mkdir -p /data/codex/.codex /config /share \
    && chown -R codex:codex /data/codex

COPY run.sh /run.sh
COPY prepare-index.sh /usr/local/bin/prepare-ttyd-index
COPY terminal.sh /usr/local/bin/codex-terminal
COPY session.sh /usr/local/bin/codex-session
RUN chmod 0755 \
      /run.sh \
      /usr/local/bin/prepare-ttyd-index \
      /usr/local/bin/codex-terminal \
      /usr/local/bin/codex-session

EXPOSE 8099
CMD ["/run.sh"]