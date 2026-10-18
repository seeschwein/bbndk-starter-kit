# SDK payload location

The Docker build expects:

```text
sdk/bbndk-env_10_3_1_995.sh
sdk/host_10_3_1_12_linux_x86/
sdk/target_10_3_1_995_qnx6/
sdk/target_10_3_1_995_target-override/
```

Install from a local release archive:

```bash
./scripts/install-sdk.sh --archive ~/Downloads/bbndk-sdk-10.3.1.995.tar.zst
```

Or from a URL:

```bash
BBNDK_SDK_URL=https://example.invalid/bbndk-sdk-10.3.1.995.tar.zst \
BBNDK_SDK_SHA256='<expected sha256>' \
./scripts/install-sdk.sh
```

Read `THIRD_PARTY_NOTICE.md` before redistribution.
