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

WORKDIR /opt/codex-terminal

RUN apk add --no-cache bash ca-certificates curl git jq nodejs npm openssh-client python3 make g++ ripgrep tmux

COPY package.json ./package.json
RUN npm install --omit=dev \
    && npm install --global @openai/codex \
    && mkdir -p public/vendor \
    && cp node_modules/@xterm/xterm/css/xterm.css public/vendor/xterm.css \
    && cp node_modules/@xterm/xterm/lib/xterm.js public/vendor/xterm.js \
    && cp node_modules/@xterm/addon-fit/lib/addon-fit.js public/vendor/addon-fit.js \
    && cp node_modules/@xterm/addon-web-links/lib/addon-web-links.js public/vendor/addon-web-links.js \
    && npm cache clean --force \
    && apk del make g++ python3 \
    && adduser -D -h /data/codex codex \
    && mkdir -p /data/codex /config /share \
    && chown -R codex:codex /data/codex

COPY server.js ./server.js
COPY public ./public
COPY run.sh /run.sh
COPY terminal.sh /usr/local/bin/codex-terminal
COPY session.sh /usr/local/bin/codex-session
RUN chmod 0755 /run.sh /usr/local/bin/codex-terminal /usr/local/bin/codex-session

EXPOSE 8099
CMD ["/run.sh"]
