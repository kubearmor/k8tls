FROM ubuntu:latest

RUN apt-get update && apt-get install -y bash openssl

COPY src/tlsscan.sh /home/kubetls/tlsscan.sh
RUN chmod +x /home/kubetls/tlsscan.sh

ENTRYPOINT ["/home/kubetls/tlsscan.sh"]
