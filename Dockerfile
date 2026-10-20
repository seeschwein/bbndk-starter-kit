FROM --platform=linux/amd64 debian:13-slim AS base

# ---------- Arguments for reproducibility ----------
ARG BBNDK_VERSION=10.3.1.995
ARG BBNDK_SHA256=d723d49fa3bc8360ee15c78b0d36ff24954a58695ea959c3eedb257cce0dade8
ARG BBNDK_URL=https://github.com/seeschwein/bbndk-starter-kit/releases/download/v0.1.0/bbndk-sdk-${BBNDK_VERSION}.tar.zst

# ---------- System packages ----------
RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates curl git make cmake ninja-build python3 unzip xz-utils \
        file less procps libc6-i386 zlib1g:i386 libstdc++6 openjdk-21-jre-headless \
        zstd && \   # needed to unpack the SDK
    rm -rf /var/lib/apt/lists/*

# ---------- Fetch and unpack the BBNDK SDK ----------
RUN mkdir -p /opt/bbndk && \
    curl -fSL -o /tmp/bbndk-sdk.tar.zst "${BBNDK_URL}" && \
    echo "${BBNDK_SHA256}  /tmp/bbndk-sdk.tar.zst" | sha256sum -c - && \
    # The archive is a ZSTD‑compressed tar containing the three SDK dirs.
    tar --use-compress-program=zstd -xf /tmp/bbndk-sdk.tar.zst -C /opt/bbndk && \
    rm -f /tmp/bbndk-sdk.tar.zst && \
    # Basic sanity check
    test -d /opt/bbndk/host_10_3_1_12_linux_x86 && \
    test -d /opt/bbndk/target_10_3_1_995_qnx6 && \
    test -d /opt/bbndk/target_10_3_1_995_target-override && \
    test -f /opt/bbndk/bbndk-env_10_3_1_995.sh

# ---------- Optional host overlay (safe to skip) ----------
# If a host provides a ./sdk/ directory it will overlay the fetched SDK.
COPY --chown=dev:dev sdk/ /opt/bbndk/ || true

# ---------- Copy the rest of the starter‑kit files ----------
COPY --chown=dev:dev --chmod=755 tools/bbndk_mcp.py   /opt/bbndk-mcp/server.py
COPY --chown=dev:dev scripts                          /opt/bbndk-tools/scripts
COPY --chown=dev:dev cmake                            /opt/bbndk-tools/cmake
COPY --chown=dev:dev --chmod=755 tools/bbndk          /usr/local/bin/bbndk

# ---------- Create non‑root user ----------
RUN useradd -ms /bin/bash dev && \
    mkdir -p /workspace && \
    chown -R dev:dev /workspace /opt/bbndk /opt/bbndk-mcp /opt/bbndk-tools && \
    find /opt/bbndk-tools/scripts -type f -name '*.sh' -exec chmod +x {} +

# ---------- Java TLS 1.0 workaround (needed for blackberry‑deploy) ----------
ENV JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64
ENV JDK_JAVA_OPTIONS="-Djava.security.manager=allow --add-exports=java.xml/com.sun.org.apache.xerces.internal.parsers=ALL-UNNAMED"
RUN echo "jdk.tls.disabledAlgorithms=" >> ${JAVA_HOME}/conf/security/java.security \
 && echo "jdk.zip.disableZip64 = false" >> ${JAVA_HOME}/conf/security/java.security

# ---------- Final image setup ----------
USER dev
WORKDIR /workspace
ENV BBNDK_TOOLS_ROOT=/opt/bbndk-tools
ENV QNX_HOST=/opt/bbndk/host_10_3_1_12/linux/x86
ENV QNX_TARGET=/opt/bbndk/target_10_3_1_995/qnx6
ENV PATH="${QNX_HOST}/usr/bin:${PATH}"
CMD ["/bin/bash"]