FROM alpine:3.23
ARG BUILD_VERSION
ARG BUILD_ARCH
LABEL io.hass.version="${BUILD_VERSION}" io.hass.type="app" io.hass.arch="${BUILD_ARCH}"
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8 TERM=xterm-256color COLORTERM=truecolor CHROME_BIN=/usr/bin/chromium-browser CHROMIUM_BIN=/usr/bin/chromium-browser
RUN apk add --no-cache bash ca-certificates chromium curl git jq nodejs npm openssh-client python3 ripgrep screen ttyd \
    && npm install --global @openai/codex@0.157.0 \
    && codex --version \
    && npm cache clean --force \
    && mkdir -p /data/codex/.codex /data/codex/uploads /data/codex/screenshots /config /share /app/public
WORKDIR /app
COPY package.json /app/package.json
RUN npm install --omit=dev && npm cache clean --force
COPY server.js /app/server.js
COPY public/index.html /app/public/index.html
COPY run.sh /run.sh
COPY prepare-index.sh /usr/local/bin/prepare-ttyd-index
COPY terminal.sh /usr/local/bin/codex-terminal
COPY session.sh /usr/local/bin/codex-session
COPY last-exchanges.py /usr/local/bin/codex-last-exchanges
RUN chmod 0755 /run.sh /app/server.js /usr/local/bin/prepare-ttyd-index /usr/local/bin/codex-terminal /usr/local/bin/codex-session /usr/local/bin/codex-last-exchanges
EXPOSE 8099
CMD ["/run.sh"]
