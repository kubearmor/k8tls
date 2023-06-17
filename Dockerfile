FROM ubuntu:latest

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends openssl csvkit ca-certificates curl netcat
RUN curl -LO https://dl.k8s.io/release/v1.27.2/bin/linux/amd64/kubectl --output-dir /usr/local/bin/ && chmod +x /usr/local/bin/kubectl
#RUN curl -sL https://github.com/mikefarah/yq/releases/download/v4.34.1/yq_linux_amd64 -o /usr/local/bin/yq && chmod +x /usr/local/bin/yq

COPY src /home/kubetls
RUN update-ca-certificates

WORKDIR /home/kubetls

ENTRYPOINT ["/home/kubetls/tlsscan.sh"]
