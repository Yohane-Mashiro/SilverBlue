# SilverBlue core 变体 &nbsp; [![bluebuild 构建徽章](https://github.com/blue-build/template/actions/workflows/build.yml/badge.svg)](https://github.com/blue-build/template/actions/workflows/build.yml)

请参考 [BlueBuild 文档](https://blue-build.org/how-to/setup/) 快速完成基于此模板的仓库初始化。

本仓库构建并分发 Fedora Silverblue NVIDIA 变体镜像：

- `ghcr.io/yohane-mashiro/core-hyprland`


## 安装

> [!WARNING]  
> [这是一个实验性功能](https://www.fedoraproject.org/wiki/Changes/OstreeNativeContainerStable)，请自行评估后使用。

将现有 Fedora Atomic 系统 rebase 到最新镜像：
- rebase 到 `core-hyprland`：
  ```
  rpm-ostree rebase ostree-unverified-registry:ghcr.io/yohane-mashiro/core-hyprland:latest
  ```

`latest` 标签会自动指向最新构建。两个配方都通过 `image-version` 固定到 Fedora 43。

## ISO

如果在 Fedora Atomic 上构建，可按 [这里](https://blue-build.org/learn/universal-blue/#fresh-install-from-an-iso) 的说明生成离线 ISO。由于体积较大，公开项目通常无法免费直接在 GitHub 分发 ISO，需要使用其他托管方式。

## 签名验证

镜像使用 [Sigstore](https://www.sigstore.dev/) 的 [cosign](https://github.com/sigstore/cosign) 进行签名。下载本仓库的 `cosign.pub` 后，可执行以下命令验证：

```bash
cosign verify --key cosign.pub ghcr.io/yohane-mashiro/<image-name>
```
