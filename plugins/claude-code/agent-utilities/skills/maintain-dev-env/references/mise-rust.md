# mise Rust Workflow

Use this supporting workflow for project-level Rust managed by `mise`, especially when the project isolates Rustup/Cargo with `MISE_RUSTUP_HOME` and/or `MISE_CARGO_HOME`.

## Project-Level Rust Proxy Recovery

Use this workflow when a project declares Rust through `mise.toml` and isolates Rustup/Cargo with `MISE_RUSTUP_HOME` and/or `MISE_CARGO_HOME`, but `mise ls rust` reports `missing`, alternates between `missing` and `symlink`, or the selected commands do not belong to the project toolchain. The Rust backend delegates toolchain management to `rustup`; the mise install entry can be a junction/symlink to the configured Rust proxy, so a matching `rustc --version` alone does not prove that the installation record is healthy.

### Diagnose without changing state

From `<PROJECT_ROOT>`, first read the declared version and Rust home settings from `<LOCAL_MISE_CONFIG>`, `rust-toolchain.toml`, and `Cargo.toml` (`rust-version`). Then capture the project-aware state:

```powershell
mise trust --show
mise ls rust
mise ls --current --json
mise doctor
mise settings get rust.cargo_home
mise settings get rust.rustup_home
$env:MISE_CARGO_HOME
$env:MISE_RUSTUP_HOME
$env:CARGO_HOME
$env:RUSTUP_HOME
Get-Command rustc,cargo,rustup -All
rustc --version
cargo --version
rustup show home
```

On Windows, inspect the mise Rust install entry and its resolved target without editing it:

```powershell
$rustInstall = Get-Item (Join-Path $env:LOCALAPPDATA "mise\installs\rust\<VERSION>")
$rustInstall.ResolvedTarget
```

Compare `ResolvedTarget` with the `bin` directory under the active project `MISE_CARGO_HOME`. If the version is correct but the target points at another project's or the user's Rust proxy, classify this as a stale proxy/junction mismatch. If the first `Get-Command` result is outside the project proxy or mise shim, classify the PATH/activation order separately; do not conflate it with an installation failure.

`mise reshim` only rebuilds mise shims. It does not retarget an existing Rust junction or reconcile Rustup/Cargo homes, so running it repeatedly cannot repair this mismatch. A profile that prepends another tool directory after `mise activate` can make the warning recur; inspect `mise doctor` and the final PATH. Move custom PATH changes before mise activation, or set `$env:MISE_ACTIVATE_AGGRESSIVE = "1"` before activation only when that is the intended shell policy.

### Repair after explicit approval

After the project config has been reviewed and any trust blocker handled, run the force reinstall from `<PROJECT_ROOT>` with the exact declared version:

```powershell
mise install --force rust@<VERSION>
mise reshim
```

`--force` removes and recreates the selected project toolchain, so Rustup may warn that the active or default toolchain is being removed. Treat that warning as expected for this repair, but do not proceed if the active `MISE_CARGO_HOME`/`MISE_RUSTUP_HOME` values are not the reviewed project paths. Never use `rustup self uninstall`, delete `<HOME>\.cargo` or `<HOME>\.rustup`, or change the shared/global Rust install as a shortcut while mise owns the project toolchain.

### Verify the repaired chain

Re-run the original blocked project command, then confirm all layers agree:

```powershell
mise ls rust
$rustInstall = Get-Item (Join-Path $env:LOCALAPPDATA "mise\installs\rust\<VERSION>")
$rustInstall.ResolvedTarget
Get-Command rustc,cargo,rustup -All
rustc --version
cargo --version
rustup show home
```

The expected result is a non-`missing` mise entry, a resolved target under the reviewed project `MISE_CARGO_HOME`, project proxy or mise-shim paths first in `Get-Command`, and a Rustup home under the reviewed project `MISE_RUSTUP_HOME`. `mise reshim` itself is safe for shared state, but `mise install --force` changes the project-scoped Rustup/Cargo installation and must remain an approved action.
