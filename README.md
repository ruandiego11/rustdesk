# Suporte Dktec

**Português:** cliente de suporte remoto usado pela Dktec para atender seus clientes. É um fork do
[RustDesk](https://github.com/rustdesk/rustdesk) (AGPL-3.0) com a marca Dktec, interface em português
do Brasil e o servidor próprio da Dktec já configurado. Os binários são gerados pelo GitHub Actions a
partir deste repositório e publicados em [Releases](https://github.com/ruandiego11/rustdesk/releases).

---

Suporte Dktec is the remote support client that Dktec, an IT support company in Brazil, uses to assist
its customers. The customer runs the app, reads the ID and one-time password shown on screen to the Dktec
technician, and the technician connects to help them.

It is a visible fork of [RustDesk](https://github.com/rustdesk/rustdesk), the open source remote desktop
application, licensed under AGPL-3.0. This fork only adds:

- Dktec branding (name, logo, icons, colors) and a redesigned home screen;
- a user interface fixed to Brazilian Portuguese;
- the Dktec self-hosted ID/relay server and its public key preconfigured at build time;
- build workflow changes to produce the Dktec Windows and Linux packages.

All branding is applied by [`marca/personalizar.py`](marca/personalizar.py) from
[`marca/dktec.json`](marca/dktec.json) and the patches in [`marca/patches`](marca/patches), so every change
against upstream is reviewable in this repository.

## Download

Windows (`.exe` portable/installer and `.msi`) and Linux (`.AppImage`, `.deb`, `.rpm`) packages are published
for free on the [Releases page](https://github.com/ruandiego11/rustdesk/releases). Every release is built by
the [`Build the flutter version of RustDesk`](.github/workflows/flutter-build.yml) GitHub Actions workflow on
GitHub-hosted runners, from the `dktec` branch, when a `dktec-*` tag is pushed.

## Install and uninstall

- **Windows, `.exe`:** run it to use the app without installing. To install, click *Instalar* inside the app.
  To uninstall, use *Settings > Apps > Installed apps > SuporteDktec > Uninstall* (or *Control Panel >
  Programs and Features*).
- **Windows, `.msi`:** installs the app; uninstall it the same way as above.
- **Linux, `.AppImage`:** run it directly; delete the file to remove it.
- **Linux, `.deb` / `.rpm`:** install with the package manager; uninstall with `sudo apt remove rustdesk` or
  `sudo dnf remove rustdesk`.

Installing on Windows asks for administrator permission (UAC) because it registers a Windows service, which
allows the technician to keep working while the app elevates privileges; uninstalling removes the service.

## Building

The [build workflow](.github/workflows/flutter-build.yml) is the reference build. It checks out this
repository, runs `python3 marca/personalizar.py . --sem-imagens` to apply the branding, and then builds with
the upstream RustDesk tooling (`build.py`, Flutter, Rust). See the upstream
[build instructions](https://github.com/rustdesk/rustdesk#build) for local builds.

## License

[GNU Affero General Public License v3.0](LICENCE), the same license as upstream RustDesk.
Copyright © Purslane Tech Pte. Ltd. and RustDesk contributors; Dktec changes © Dktec.

## Code signing policy

Free code signing provided by [SignPath.io](https://signpath.io), certificate by
[SignPath Foundation](https://signpath.org).

> The application to SignPath Foundation is pending. Until it is approved, Windows releases are not signed.

- Committers and reviewers: [@ruandiego11](https://github.com/ruandiego11)
- Approvers: [@ruandiego11](https://github.com/ruandiego11)

Only files built by the GitHub Actions workflow of this repository from its own source code are signed:
`SuporteDktec.exe`, `librustdesk.dll`, the portable `SuporteDktec-<version>-x86_64.exe` and the
`SuporteDktec-<version>-x86_64.msi` installer. Third-party libraries included in the packages (for example
Flutter plugin DLLs) are distributed unchanged and are not signed with this certificate. Every signing request
is approved manually by an approver.

## Privacy policy

Suporte Dktec does not collect telemetry or usage data and does not send personal data to Dktec or to third
parties. Update checks against the upstream RustDesk servers are disabled in this build. The network
connections the app makes are:

- **Dktec ID/relay server** (configured at build time and operated by Dktec, the company providing the
  support): registers the device ID and online status and brokers or relays remote sessions.
- **The technician's computer**, directly or through the relay, during a remote session. A session only
  starts after the customer gives the technician the ID and password shown on screen, and the customer can end
  it at any time.
- **Public STUN servers** (`stun.l.google.com`, `stun.cloudflare.com`, `stun.nextcloud.com`), inherited from
  upstream RustDesk, used to discover the network's public address so that direct connections are possible.
  These servers only see the IP address of the computer making the request.

Files, clipboard contents and screen images are only transferred during a remote session, between the
customer's and the technician's computers.
