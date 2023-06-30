FROM ubuntu:latest

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends openssl ca-certificates curl netcat
RUN curl -LO https://dl.k8s.io/release/v1.27.2/bin/linux/amd64/kubectl --output-dir /usr/local/bin/ && chmod +x /usr/local/bin/kubectl
RUN curl -sfL https://raw.githubusercontent.com/nyrahul/tabled/main/install.sh | sh -s -- -b /usr/local/bin v0.1.2

COPY src /home/kubetls
COPY config /home/kubetls
RUN update-ca-certificates

WORKDIR /home/kubetls

ENTRYPOINT ["/home/kubetls/tlsscan"]
