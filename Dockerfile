FROM --platform=linux/amd64 debian:13-slim

RUN dpkg --add-architecture i386 \
 && apt-get update \
 && apt-get install -y --no-install-recommends \
      ca-certificates curl git make cmake ninja-build python3 unzip xz-utils \
      file less procps libc6-i386 zlib1g:i386 openjdk-21-jre-headless \
 && rm -rf /var/lib/apt/lists/*

COPY sdk/host_10_3_1_12_linux_x86 /opt/bbndk/host_10_3_1_12/linux/x86
COPY sdk/target_10_3_1_995_qnx6 /opt/bbndk/target_10_3_1_995/qnx6
COPY sdk/target_10_3_1_995_target-override /opt/bbndk/target_10_3_1_995/target-override
COPY sdk/bbndk-env_10_3_1_995.sh /opt/bbndk/bbndk-env.sh
COPY tools/bbndk_mcp.py /opt/bbndk-mcp/server.py

RUN useradd -ms /bin/bash dev \
 && mkdir -p /workspace \
 && chown -R dev:dev /workspace /opt/bbndk /opt/bbndk-mcp \
 && chmod +x /opt/bbndk-mcp/server.py

USER dev
WORKDIR /workspace
ENV QNX_HOST=/opt/bbndk/host_10_3_1_12/linux/x86
ENV QNX_TARGET=/opt/bbndk/target_10_3_1_995/qnx6
ENV PATH="${QNX_HOST}/usr/bin:${PATH}"
ENV JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64
ENV JDK_JAVA_OPTIONS="-Djava.security.manager=allow --add-exports=java.xml/com.sun.org.apache.xerces.internal.parsers=ALL-UNNAMED"
CMD ["/bin/bash"]
