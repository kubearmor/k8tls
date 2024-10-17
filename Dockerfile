FROM redhat/ubi9-minimal

ARG VERSION=latest

LABEL name="k8tls" \
      vendor="Accuknox" \
      version=${VERSION} \
      release=${VERSION} \
      summary="k8tls container image based on redhat ubi" \
      description="Tool to scan/verify the TLS connection parameters and the certificates usage on the target server ports. The tool does not inject a proxy/sidecar to do this scanning."

RUN microdnf -y update && \
    microdnf -y install --nodocs --setopt=install_weak_deps=0 --setopt=keepcache=0 shadow-utils openssl ca-certificates nmap jq tar gzip util-linux && \
    microdnf clean all

# Determine architecture and download the appropriate binaries
RUN ARCH=$(uname -m) && \
    if [ "$ARCH" = "x86_64" ]; then \
        curl -LO https://dl.k8s.io/release/v1.27.2/bin/linux/amd64/kubectl --output-dir /usr/local/bin/ && \
        curl -L https://github.com/RUB-NDS/Terrapin-Scanner/releases/download/v1.1.0/Terrapin_Scanner_Linux_amd64 -o /usr/local/bin/Terrapin_Scanner; \
    elif [ "$ARCH" = "aarch64" ]; then \
        curl -LO https://dl.k8s.io/release/v1.27.2/bin/linux/arm64/kubectl --output-dir /usr/local/bin/ && \
        curl -L https://github.com/RUB-NDS/Terrapin-Scanner/releases/download/v1.1.3/Terrapin_Scanner_Linux_aarch64 -o /usr/local/bin/Terrapin_Scanner; \
    else \
        echo "Unsupported architecture: $ARCH"; exit 1; \
    fi && \
    chmod +x /usr/local/bin/kubectl /usr/local/bin/Terrapin_Scanner

RUN curl -sfL https://raw.githubusercontent.com/kubearmor/tabled/main/install.sh | sh -s -- -b /usr/local/bin v0.1.2

RUN groupadd --gid 1000 default \
  && useradd --uid 1000 --gid default --shell /bin/bash --create-home default

COPY LICENSE /licenses/license.txt

COPY src /home/k8tls
COPY config /home/k8tls
RUN update-ca-trust

WORKDIR /home/k8tls
USER 1000
ENTRYPOINT ["/home/k8tls/tlsscan"]
