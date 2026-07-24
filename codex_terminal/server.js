const http = require('http');
const path = require('path');
const express = require('express');
const pty = require('node-pty');
const { WebSocketServer } = require('ws');

const port = Number.parseInt(process.env.PORT || '8099', 10);
const fontSize = Number.parseInt(process.env.TERMINAL_FONT_SIZE || '13', 10);
const app = express();
const publicDir = path.join(__dirname, 'public');

app.disable('x-powered-by');
app.use(express.static(publicDir, {
  etag: true,
  maxAge: '1h',
  setHeaders: (res, filePath) => {
    if (filePath.endsWith('.html') || filePath.endsWith('.js')) {
      res.setHeader('Cache-Control', 'no-store');
    }
  }
}));

app.get('/health', (_req, res) => res.status(200).send('ok'));
app.get('/config.json', (_req, res) => {
  res.json({ fontSize, scrollback: 50000 });
});
app.use((_req, res) => res.sendFile(path.join(publicDir, 'index.html')));

const server = http.createServer(app);
const wss = new WebSocketServer({ noServer: true });

server.on('upgrade', (request, socket, head) => {
  const pathname = new URL(request.url, 'http://localhost').pathname;
  if (!pathname.endsWith('/ws') && pathname !== '/ws') {
    socket.destroy();
    return;
  }
  wss.handleUpgrade(request, socket, head, (ws) => wss.emit('connection', ws));
});

wss.on('connection', (ws) => {
  const terminal = pty.spawn('/usr/local/bin/codex-terminal', [], {
    name: 'xterm-256color',
    cols: 80,
    rows: 24,
    cwd: process.env.WORKING_DIRECTORY || '/config',
    env: {
      ...process.env,
      TERM: 'xterm-256color',
      COLORTERM: 'truecolor',
      LANG: 'C.UTF-8',
      LC_ALL: 'C.UTF-8'
    }
  });

  const output = terminal.onData((data) => {
    if (ws.readyState === ws.OPEN) {
      ws.send(JSON.stringify({ type: 'data', data }));
    }
  });

  terminal.onExit(({ exitCode }) => {
    if (ws.readyState === ws.OPEN) {
      ws.send(JSON.stringify({ type: 'exit', exitCode }));
      ws.close();
    }
  });

  ws.on('message', (raw) => {
    try {
      const message = JSON.parse(raw.toString());
      if (message.type === 'input' && typeof message.data === 'string') {
        terminal.write(message.data);
      } else if (message.type === 'resize') {
        const cols = Math.max(20, Math.min(500, Number(message.cols) || 80));
        const rows = Math.max(5, Math.min(300, Number(message.rows) || 24));
        terminal.resize(cols, rows);
      }
    } catch (error) {
      console.error('Invalid websocket message:', error.message);
    }
  });

  ws.on('close', () => {
    output.dispose();
    terminal.kill();
  });
});

server.listen(port, '0.0.0.0', () => {
  console.log(`Codex terminal server listening on port ${port}`);
});
