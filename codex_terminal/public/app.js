(() => {
  const status = document.getElementById('status');
  const container = document.getElementById('terminal');
  const fitAddon = new FitAddon.FitAddon();
  const linksAddon = new WebLinksAddon.WebLinksAddon();
  let socket;
  let reconnectTimer;

  const terminal = new Terminal({
    cursorBlink: true,
    fontSize: 13,
    fontFamily: "'Roboto Mono','Noto Sans Mono','DejaVu Sans Mono',monospace",
    scrollback: 50000,
    convertEol: true,
    allowTransparency: false,
    theme: { background: '#111827', foreground: '#f3f4f6', cursor: '#f9fafb' }
  });

  terminal.loadAddon(fitAddon);
  terminal.loadAddon(linksAddon);
  terminal.open(container);

  fetch('./config.json', { cache: 'no-store' }).then((r) => r.json()).then((config) => {
    terminal.options.fontSize = config.fontSize || 13;
    terminal.options.scrollback = config.scrollback || 50000;
    fitAddon.fit();
  }).catch(() => fitAddon.fit());

  function wsUrl() {
    // Resolve the websocket relative to the current Ingress page. This keeps
    // Home Assistant's /api/hassio_ingress/<token>/ prefix intact.
    const url = new URL('ws', document.baseURI);
    url.protocol = location.protocol === 'https:' ? 'wss:' : 'ws:';
    url.search = '';
    url.hash = '';
    return url.toString();
  }

  function scheduleReconnect() {
    clearTimeout(reconnectTimer);
    reconnectTimer = setTimeout(connect, 2000);
  }

  function connect() {
    clearTimeout(reconnectTimer);
    const endpoint = wsUrl();
    status.textContent = 'Connexion…';

    try {
      socket = new WebSocket(endpoint);
    } catch (error) {
      status.textContent = `Erreur WebSocket : ${error.message}`;
      scheduleReconnect();
      return;
    }

    const timeout = setTimeout(() => {
      if (socket.readyState !== WebSocket.OPEN) {
        status.textContent = 'Connexion WebSocket impossible — nouvelle tentative…';
        socket.close();
      }
    }, 8000);

    socket.addEventListener('open', () => {
      clearTimeout(timeout);
      status.textContent = 'Connecté';
      fitAddon.fit();
      sendResize();
      terminal.focus();
    });

    socket.addEventListener('message', (event) => {
      try {
        const message = JSON.parse(event.data);
        if (message.type === 'data') terminal.write(message.data);
        if (message.type === 'exit') status.textContent = `Session terminée (${message.exitCode})`;
      } catch (error) {
        status.textContent = `Réponse invalide : ${error.message}`;
      }
    });

    socket.addEventListener('close', (event) => {
      clearTimeout(timeout);
      status.textContent = `Déconnecté (${event.code}) — reconnexion…`;
      scheduleReconnect();
    });

    socket.addEventListener('error', () => {
      clearTimeout(timeout);
      status.textContent = 'Erreur de connexion WebSocket';
    });
  }

  function send(payload) {
    if (socket?.readyState === WebSocket.OPEN) socket.send(JSON.stringify(payload));
  }

  function sendResize() {
    send({ type: 'resize', cols: terminal.cols, rows: terminal.rows });
  }

  terminal.onData((data) => send({ type: 'input', data }));
  window.addEventListener('resize', () => { fitAddon.fit(); sendResize(); });
  new ResizeObserver(() => { fitAddon.fit(); sendResize(); }).observe(container);

  document.querySelectorAll('[data-key]').forEach((button) => {
    button.addEventListener('click', () => {
      send({ type: 'input', data: button.dataset.key });
      terminal.focus();
    });
  });
  document.getElementById('keyboard').addEventListener('click', () => terminal.focus());

  let lastY = null;
  container.addEventListener('touchstart', (event) => {
    if (event.touches.length === 1) lastY = event.touches[0].clientY;
  }, { passive: true });
  container.addEventListener('touchmove', (event) => {
    if (event.touches.length !== 1 || lastY === null) return;
    const currentY = event.touches[0].clientY;
    const delta = currentY - lastY;
    lastY = currentY;
    if (Math.abs(delta) >= 4) {
      terminal.scrollLines(-Math.trunc(delta / 8));
      event.preventDefault();
    }
  }, { passive: false });
  container.addEventListener('touchend', () => { lastY = null; }, { passive: true });

  connect();
})();
