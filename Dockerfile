FROM ubuntu:22.04

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends openssl ca-certificates curl netcat jq

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

COPY src /home/k8tls
COPY config /home/k8tls
RUN update-ca-certificates

WORKDIR /home/k8tls

ENTRYPOINT ["/home/k8tls/tlsscan"]
