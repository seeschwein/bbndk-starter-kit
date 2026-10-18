# Distribution strategy

## Recommended layout

Keep source, templates, and scripts in Git. Put the SDK archive in a GitHub Release or object storage, and publish the ready-to-run image in a registry such as GHCR. This avoids cloning roughly 1.7 GB of immutable binaries with every source checkout.

## GitHub Release

```bash
brew install zstd gh
./scripts/package-sdk.sh
gh release create v0.1.0 \
  output/bbndk-sdk-10.3.1.995.tar.zst \
  output/bbndk-sdk-10.3.1.995.tar.zst.sha256 \
  templates/hello-cli.zip templates/cascades-qml.zip
```

Each release asset must remain below 2 GiB. The packaging script checks this. If necessary, publish separate host and target archives.

## GHCR

After making the package public, users can pull anonymously:

```bash
docker pull ghcr.io/seeschwein/bbndk-starter-kit:latest
```

The workflow publishes on version tags or manual dispatch. Set repository variable `BBNDK_SDK_URL` and secret `BBNDK_SDK_SHA256`; the URL must be reachable by GitHub Actions. Review `THIRD_PARTY_NOTICE.md` before publishing a bundled SDK.

## Other registries

Docker Hub, GitLab Container Registry, Quay, and S3-compatible object storage also work. Hosting elsewhere does not change the SDK's licensing status.
