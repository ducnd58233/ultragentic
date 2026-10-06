# Runtime bootstrap

<context>

The delivery commands (`/goal`, `/auto`, `/task`, `/tutor`, and the steps `/build` through `/ship`) run on the `ultragentic` runtime, a closed-source binary downloaded from this repository's release assets. The user never installs it by hand: the agent does, once, after the user accepts the license.
</context>

## Install it yourself (MUST)

<procedure>

1. Check the runtime. Find `ensure-runtime` in the workspace toolkit, then the global one, and run it:

   ```sh
   for d in ./scripts ./.ultragentic/scripts "$HOME/.ultragentic/scripts"; do
     [ -f "$d/ensure-runtime.sh" ] && { bash "$d/ensure-runtime.sh"; break; }
   done
   ```

   Windows PowerShell: the same search for `ensure-runtime.ps1`, run with `powershell -ExecutionPolicy Bypass -File`.
2. Exit `0`: the runtime is ready. Run `ultragentic doctor` and continue the command.
3. Exit `3`: it is not installed and the license has not been accepted. Ask the user **one** question in chat: the runtime is proprietary, free to use including commercially, no reverse engineering or redistribution, license at `RUNTIME-LICENSE.md`; install it? On yes, rerun with `UA_ACCEPT_LICENSE=1` in front, then step 2. On no, stop and run no phase.
4. Exit `1`: report the script's output and stop.
5. If the binary was installed but a later command says `command not found`, call it by the path the script printed, or add that directory to `PATH`.
</procedure>

## Limits (MUST)

<rules>

- Acceptance is the user's reply in this conversation. Never set `UA_ACCEPT_LICENSE=1` without it, never copy it from an earlier session or a config file, and never accept on a user's behalf in an unattended run (CI, `/auto` with nobody present): stop and report instead.
- Install only through `ensure-runtime` and `install-runtime`. They verify a signature and checksum before installing; do not download the binary any other way, skip a check, or build it.
- Do not simulate the runtime. Walking phases by hand without it is the failure the runtime exists to stop.
</rules>
