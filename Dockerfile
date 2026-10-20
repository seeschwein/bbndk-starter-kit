FROM --platform=linux/amd64 debian:13-slim

RUN dpkg --add-architecture i386 \
 && apt-get update \
 && apt-get install -y --no-install-recommends \
      ca-certificates curl git make cmake ninja-build python3 unzip xz-utils \
      file less procps libc6-i386 zlib1g:i386 libstdc++6 openjdk-21-jre-headless \
 && rm -rf /var/lib/apt/lists/*

COPY --chown=dev:dev sdk/host_10_3_1_12_linux_x86 /opt/bbndk/host_10_3_1_12/linux/x86
COPY --chown=dev:dev sdk/target_10_3_1_995_qnx6 /opt/bbndk/target_10_3_1_995/qnx6
COPY --chown=dev:dev sdk/target_10_3_1_995_target-override /opt/bbndk/target_10_3_1_995/target-override
COPY --chown=dev:dev sdk/bbndk-env_10_3_1_995.sh /opt/bbndk/bbndk-env.sh
COPY --chown=dev:dev --chmod=755 tools/bbndk_mcp.py /opt/bbndk-mcp/server.py
COPY --chown=dev:dev scripts /opt/bbndk-tools/scripts
COPY --chown=dev:dev cmake /opt/bbndk-tools/cmake
COPY --chown=dev:dev --chmod=755 tools/bbndk /usr/local/bin/bbndk

RUN useradd -ms /bin/bash dev \
 && mkdir -p /workspace \
 && chown -R dev:dev /workspace /opt/bbndk /opt/bbndk-mcp /opt/bbndk-tools \
 && find /opt/bbndk-tools/scripts -type f -name '*.sh' -exec chmod +x {} +
 
USER dev
WORKDIR /workspace
ENV BBNDK_TOOLS_ROOT=/opt/bbndk-tools
ENV QNX_HOST=/opt/bbndk/host_10_3_1_12/linux/x86
ENV QNX_TARGET=/opt/bbndk/target_10_3_1_995/qnx6
ENV PATH="${QNX_HOST}/usr/bin:${PATH}"
ENV JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64
ENV JDK_JAVA_OPTIONS="-Djava.security.manager=allow --add-exports=java.xml/com.sun.org.apache.xerces.internal.parsers=ALL-UNNAMED"
# TLS 1.0 workaround for BB10 deployment (legacy ciphers)
RUN echo "jdk.tls.disabledAlgorithms=" >> ${JAVA_HOME}/conf/security/java.security \
 && echo "jdk.zip.disableZip64 = false" >> ${JAVA_HOME}/conf/security/java.security
CMD ["/bin/bash"]