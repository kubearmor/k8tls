FROM ubuntu:24.04

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends openssl ca-certificates curl netcat jq
RUN curl -LO https://dl.k8s.io/release/v1.27.2/bin/linux/amd64/kubectl --output-dir /usr/local/bin/ && chmod +x /usr/local/bin/kubectl
RUN curl -sfL https://raw.githubusercontent.com/kubearmor/tabled/main/install.sh | sh -s -- -b /usr/local/bin v0.1.2
RUN curl -L https://github.com/RUB-NDS/Terrapin-Scanner/releases/download/v1.1.0/Terrapin_Scanner_Linux_amd64 -o /usr/local/bin/Terrapin_Scanner && chmod +x /usr/local/bin/Terrapin_Scanner

COPY src /home/k8tls
COPY config /home/k8tls
RUN update-ca-certificates

WORKDIR /home/k8tls

ENTRYPOINT ["/home/k8tls/tlsscan"]
