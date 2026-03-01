# SilverBlue DankLinux Variants &nbsp; [![bluebuild build badge](https://github.com/blue-build/template/actions/workflows/build.yml/badge.svg)](https://github.com/blue-build/template/actions/workflows/build.yml)

See the [BlueBuild docs](https://blue-build.org/how-to/setup/) for quick setup instructions for setting up your own repository based on this template.

This repository builds and distributes two Fedora Silverblue NVIDIA variants:

- `ghcr.io/<user>/danklinux-niri`
- `ghcr.io/<user>/danklinux-hyprland`

Both variants integrate the official DankMaterialShell (DMS) stack from the Dank Linux Fedora repository, including:

- `dms`
- `matugen`
- `cliphist`

Variant defaults are pre-seeded to `/etc/skel` during image build via `dms setup`:

- niri image: DMS is bound to `niri.service`
- hyprland image: Includes `hyprland-session.target` plus required systemd env bootstrap lines in Hyprland config

For existing users (created before rebase), run this once after login to generate user configs:

```bash
dms setup
```

## Installation

> [!WARNING]  
> [This is an experimental feature](https://www.fedoraproject.org/wiki/Changes/OstreeNativeContainerStable), try at your own discretion.

To rebase an existing atomic Fedora installation to the latest build:

- Rebase to `danklinux-niri` (unsigned):
  ```
  rpm-ostree rebase ostree-unverified-registry:ghcr.io/<user>/danklinux-niri:latest
  ```
- Rebase to `danklinux-hyprland` (unsigned):
  ```
  rpm-ostree rebase ostree-unverified-registry:ghcr.io/<user>/danklinux-hyprland:latest
  ```

- Then rebase to the signed image (replace image name as needed):
  ```
  rpm-ostree rebase ostree-image-signed:docker://ghcr.io/<user>/<image-name>:latest
  ```
- Reboot to complete the installation
  ```
  systemctl reboot
  ```

The `latest` tag will automatically point to the latest build. Both recipes are pinned to Fedora 42 via `image-version`.

## ISO

If build on Fedora Atomic, you can generate an offline ISO with the instructions available [here](https://blue-build.org/learn/universal-blue/#fresh-install-from-an-iso). These ISOs cannot unfortunately be distributed on GitHub for free due to large sizes, so for public projects something else has to be used for hosting.

## Verification

These images are signed with [Sigstore](https://www.sigstore.dev/)'s [cosign](https://github.com/sigstore/cosign). You can verify the signature by downloading the `cosign.pub` file from this repo and running the following command:

```bash
cosign verify --key cosign.pub ghcr.io/<user>/<image-name>
```
