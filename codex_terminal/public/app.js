(() => {
  const status = document.getElementById('status');
  const container = document.getElementById('terminal');
  const fitAddon = new FitAddon.FitAddon();
  const linksAddon = new WebLinksAddon.WebLinksAddon();
  let socket;

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

  fetch('./config.json').then((r) => r.json()).then((config) => {
    terminal.options.fontSize = config.fontSize || 13;
    terminal.options.scrollback = config.scrollback || 50000;
    fitAddon.fit();
  }).catch(() => fitAddon.fit());

  function wsUrl() {
    const protocol = location.protocol === 'https:' ? 'wss:' : 'ws:';
    const base = location.pathname.endsWith('/') ? location.pathname : `${location.pathname}/`;
    return `${protocol}//${location.host}${base}ws`;
  }

  function connect() {
    status.textContent = 'Connexion…';
    socket = new WebSocket(wsUrl());
    socket.addEventListener('open', () => {
      status.textContent = 'Connecté';
      fitAddon.fit();
      sendResize();
      terminal.focus();
    });
    socket.addEventListener('message', (event) => {
      const message = JSON.parse(event.data);
      if (message.type === 'data') terminal.write(message.data);
      if (message.type === 'exit') status.textContent = `Session terminée (${message.exitCode})`;
    });
    socket.addEventListener('close', () => {
      status.textContent = 'Déconnecté — reconnexion…';
      setTimeout(connect, 1500);
    });
    socket.addEventListener('error', () => socket.close());
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

  // Standard mobile terminal scrolling. This works for shell output; Codex
  // conversations themselves can be reopened with /resume after reconnecting.
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
