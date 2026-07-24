# Codex Terminal for Home Assistant

A local Home Assistant app/add-on that exposes OpenAI Codex CLI in a browser terminal through Home Assistant Ingress.

## Main features

- Codex CLI directly in the Home Assistant sidebar
- Home Assistant Ingress authentication
- Persistent Codex login and configuration
- Read/write access to `/config` and `/share`
- No Docker socket, host network, or privileged host access
- Supports `amd64` and `aarch64`

## Install as a repository

1. In Home Assistant, go to **Settings → Apps → App store**.
2. Open the menu and select **Repositories**.
3. Add:

   ```text
   https://github.com/Jhamende/ha-codex-terminal
   ```

4. Reload the app store.
5. Install **Codex Terminal**.
6. Start it and enable **Show in sidebar**.
7. Open the terminal.
8. At first launch, run:

   ```bash
   codex login --device-auth
   ```

9. Follow the displayed URL and code, then run:

   ```bash
   codex
   ```

## Security warning

Codex can modify the Home Assistant configuration because `/config` is mounted read/write. Review proposed commands and changes before approving them. Keep the app restricted to Home Assistant administrators.
