FROM ubuntu:latest

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends openssl csvkit ca-certificates curl
RUN curl -LO https://dl.k8s.io/release/v1.27.2/bin/linux/amd64/kubectl --output-dir /usr/local/bin/ && chmod +x /usr/local/bin/kubectl

COPY src /home/kubetls
RUN update-ca-certificates

WORKDIR /home/kubetls

ENTRYPOINT ["/home/kubetls/tlsscan.sh"]
