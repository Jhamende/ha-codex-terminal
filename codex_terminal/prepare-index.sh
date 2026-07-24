#!/usr/bin/env bash
set -Eeuo pipefail

OUTPUT="/tmp/ttyd-index.html"
BASE="/tmp/ttyd-index-base.html"
PORT=8100

if [[ -s "$OUTPUT" ]]; then
  exit 0
fi

ttyd --interface 127.0.0.1 --port "$PORT" --readonly /bin/sh -c 'sleep 30' >/tmp/ttyd-bootstrap.log 2>&1 &
bootstrap_pid=$!
trap 'kill "$bootstrap_pid" 2>/dev/null || true' EXIT

for _ in $(seq 1 40); do
  if curl --fail --silent --show-error "http://127.0.0.1:${PORT}/" -o "$BASE"; then
    break
  fi
  sleep 0.1
done

if [[ ! -s "$BASE" ]]; then
  echo "Unable to retrieve ttyd default index" >&2
  cat /tmp/ttyd-bootstrap.log >&2 || true
  exit 1
fi

python3 - "$BASE" "$OUTPUT" <<'PY'
from pathlib import Path
import sys

source = Path(sys.argv[1]).read_text(encoding="utf-8")
output = Path(sys.argv[2])

toolbar = r'''
<style>
#codex-toolbar{position:fixed;z-index:9999;right:10px;bottom:12px;display:flex;gap:8px;padding:6px;border-radius:12px;background:rgba(17,24,39,.88);box-shadow:0 3px 14px rgba(0,0,0,.35);backdrop-filter:blur(6px)}
#codex-toolbar button{min-height:42px;padding:0 14px;border:1px solid rgba(255,255,255,.2);border-radius:9px;background:#263244;color:#fff;font:600 14px system-ui,sans-serif;touch-action:manipulation}
#codex-toolbar button:active{transform:scale(.96);background:#37465d}
.xterm{padding-bottom:62px!important}
</style>
<div id="codex-toolbar" aria-label="Commandes rapides">
  <button type="button" id="codex-bottom">↓ Bas</button>
  <button type="button" id="codex-resume">/resume</button>
</div>
<script>
(()=>{
  const textarea=()=>document.querySelector('.xterm-helper-textarea');
  const bottom=()=>{
    const viewport=document.querySelector('.xterm-viewport');
    if(viewport){viewport.scrollTop=viewport.scrollHeight;}
    textarea()?.focus();
  };
  const sendText=(text)=>{
    const input=textarea();
    if(!input)return;
    input.focus();
    try{
      document.execCommand('insertText',false,text);
    }catch(_){
      input.value=text;
      input.dispatchEvent(new InputEvent('input',{bubbles:true,data:text,inputType:'insertText'}));
    }
    setTimeout(()=>{
      input.dispatchEvent(new KeyboardEvent('keydown',{key:'Enter',code:'Enter',keyCode:13,which:13,bubbles:true,cancelable:true}));
      input.dispatchEvent(new KeyboardEvent('keypress',{key:'Enter',code:'Enter',keyCode:13,which:13,bubbles:true,cancelable:true}));
      input.dispatchEvent(new KeyboardEvent('keyup',{key:'Enter',code:'Enter',keyCode:13,which:13,bubbles:true,cancelable:true}));
      bottom();
    },50);
  };
  document.getElementById('codex-bottom').addEventListener('click',bottom);
  document.getElementById('codex-resume').addEventListener('click',()=>sendText('/resume'));
})();
</script>
'''

marker = "</body>"
if marker not in source:
    raise SystemExit("ttyd index does not contain </body>")
output.write_text(source.replace(marker, toolbar + marker, 1), encoding="utf-8")
PY
