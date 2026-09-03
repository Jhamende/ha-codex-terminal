#!/usr/bin/env python3
import json
import os
from pathlib import Path

CODEX_HOME = Path(os.environ.get("CODEX_HOME", "/data/codex/.codex"))
SESSIONS_DIR = CODEX_HOME / "sessions"
MAX_SCAN_LINES = 20000
MAX_SCAN_BYTES = 32 * 1024 * 1024
MAX_MESSAGES = 12
MAX_MESSAGE_CHARS = 6000


def newest_rollout() -> Path | None:
    if not SESSIONS_DIR.exists():
        return None

    files = list(SESSIONS_DIR.rglob("rollout-*.jsonl"))
    if not files:
        return None

    return max(files, key=lambda path: path.stat().st_mtime)


def tail_lines(path: Path) -> list[str]:
    size = path.stat().st_size
    if size == 0:
        return []

    block_size = 256 * 1024
    data = b""
    position = size

    with path.open("rb") as handle:
        while position > 0 and data.count(b"\n") <= MAX_SCAN_LINES and len(data) < MAX_SCAN_BYTES:
            read_size = min(block_size, position, MAX_SCAN_BYTES - len(data))
            if read_size <= 0:
                break
            position -= read_size
            handle.seek(position)
            data = handle.read(read_size) + data

    lines = data.decode("utf-8", errors="replace").splitlines()
    return lines[-MAX_SCAN_LINES:]


def content_text(content) -> str:
    if isinstance(content, str):
        return content
    if not isinstance(content, list):
        return ""

    parts = []
    for item in content:
        if not isinstance(item, dict):
            continue
        if item.get("type") in {"input_text", "output_text", "text"}:
            text = item.get("text")
            if isinstance(text, str):
                parts.append(text)
    return "\n".join(parts)


def extract_message(record: dict):
    record_type = record.get("type")
    payload = record.get("payload")
    if not isinstance(payload, dict):
        return None

    if record_type == "event_msg":
        event_type = payload.get("type")
        if event_type == "user_message":
            text = payload.get("message")
            if isinstance(text, str) and text.strip():
                return "user", text
        if event_type in {"agent_message", "assistant_message"}:
            text = payload.get("message") or payload.get("text")
            if isinstance(text, str) and text.strip():
                return "assistant", text

    if record_type == "response_item" and payload.get("type") == "message":
        role = payload.get("role")
        if role in {"user", "assistant"}:
            text = content_text(payload.get("content"))
            if text.strip():
                return role, text

    return None


def main() -> int:
    rollout = newest_rollout()
    if rollout is None:
        print("Aucune session Codex trouvée dans", SESSIONS_DIR)
        return 1

    messages: list[tuple[str, str]] = []
    malformed = 0

    for line in tail_lines(rollout):
        try:
            record = json.loads(line)
        except json.JSONDecodeError:
            malformed += 1
            continue

        message = extract_message(record)
        if message is None:
            continue

        role, text = message
        text = text.strip()

        # Codex peut persister le même tour sous plusieurs formes. Évite les doublons
        # consécutifs sans supprimer de véritables messages répétés plus tard.
        if messages and messages[-1] == (role, text):
            continue
        messages.append((role, text))

    recent = messages[-MAX_MESSAGES:]
    stat = rollout.stat()

    print()
    print("═" * 72)
    print("Derniers échanges présents sur disque")
    print("═" * 72)
    print(f"Session : {rollout.name}")
    print(f"Taille  : {stat.st_size / (1024 * 1024):.1f} MiB")
    print(f"Scan    : dernières {MAX_SCAN_LINES} lignes, max {MAX_SCAN_BYTES // (1024 * 1024)} MiB")
    if malformed:
        print(f"Note    : {malformed} ligne(s) JSON incomplète(s)/ignorée(s)")
    print()

    if not recent:
        print("Aucun message utilisateur/assistant détecté dans la fenêtre analysée.")
        print("La session peut être très dense en appels d'outils ; relance la commande")
        print("manuellement après quelques instants ou inspecte directement le rollout.")
        print()
        return 2

    for role, text in recent:
        label = "TOI" if role == "user" else "CODEX"
        if len(text) > MAX_MESSAGE_CHARS:
            text = text[:MAX_MESSAGE_CHARS] + "\n[… message tronqué pour l’affichage …]"
        print(f"── {label} " + "─" * max(1, 66 - len(label)))
        print(text)
        print()

    print("═" * 72)
    print("Lecture seule : aucun fichier de session n'a été modifié.")
    print("═" * 72)
    print()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
