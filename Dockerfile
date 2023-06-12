FROM ubuntu:latest

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends openssl csvkit

COPY src/tlsscan.sh /home/kubetls/tlsscan.sh
RUN chmod +x /home/kubetls/tlsscan.sh

WORKDIR /home/kubetls

ENTRYPOINT ["/home/kubetls/tlsscan.sh"]
