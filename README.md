# TLS View

Tool to scan/verify if the TLS connection parameters and the certificates usage on the target server ports.

## Scan k8s services

For k8s, the solution gets deployed as a job that scans the k8s service ports.

```
$ kubectl apply -f https://raw.githubusercontent.com/kubetls/tlsview/main/k8s/job.yaml
$ kubectl logs -n kubetls $(kubectl get pod -n kubetls -l job-name=kubetls -o name)

| Name                                                             | Address              | Status | Version | Ciphersuite            | Hash   | Signature | Verification                                 |
| ---------------------------------------------------------------- | -------------------- | ------ | ------- | ---------------------- | ------ | --------- | -------------------------------------------- |
| accuknox-agents/agents-operator[health-check]                    | 10.100.17.218:9090   | NO_TLS |         |                        |        |           |                                              |
| accuknox-agents/agents-operator[spire-agent]                     | 10.100.17.218:9091   | NO_TLS |         |                        |        |           |                                              |
| accuknox-agents/discovery-engine                                 | 10.100.16.51:9089    | NO_TLS |         |                        |        |           |                                              |
| default/kubernetes[https]                                        | 10.100.0.1:443       | TLS    | TLSv1.3 | TLS_AES_128_GCM_SHA256 | SHA256 | RSA-PSS   | unable to verify the first certificate       |
| kube-system/kube-dns[dns-tcp]                                    | 10.100.0.10:53       | NO_TLS |         |                        |        |           |                                              |
| kube-system/kubearmor                                            | 10.100.212.208:32767 | NO_TLS |         |                        |        |           |                                              |
| kube-system/kubearmor-annotation-manager-metrics-service[https]  | 10.100.162.219:443   | TLS    | TLSv1.3 | TLS_AES_128_GCM_SHA256 | SHA256 | RSA-PSS   | unable to verify the first certificate       |
| kube-system/kubearmor-host-policy-manager-metrics-service[https] | 10.100.35.162:8443   | TLS    | TLSv1.3 | TLS_AES_128_GCM_SHA256 | SHA256 | RSA-PSS   | self-signed certificate in certificate chain |
| kube-system/kubearmor-policy-manager-metrics-service[https]      | 10.100.145.145:8443  | TLS    | TLSv1.3 | TLS_AES_128_GCM_SHA256 | SHA256 | RSA-PSS   | self-signed certificate in certificate chain |
| vault/vault[http]                                                | 10.100.85.110:8200   | NO_TLS |         |                        |        |           |                                              |
| vault/vault[https-internal]                                      | 10.100.85.110:8201   | NO_TLS |         |                        |        |           |                                              |
| vault/vault-agent-injector-svc[https]                            | 10.100.198.112:443   | TLS    | TLSv1.3 | TLS_AES_128_GCM_SHA256 | SHA256 | ECDSA     | unable to verify the first certificate       |
| wordpress-mysql/mysql                                            | 10.100.212.210:3306  | NO_TLS |         |                        |        |           |                                              |
| wordpress-mysql/wordpress                                        | 10.100.189.9:80      | NO_TLS |         |                        |        |           |                                              |
```

## Scan any general addresses

One can provide a list of addresses as part of address list file and get it scanned.

```
❯ ./src/tlsscan.sh --csv /tmp/out.csv -f addr.list; csvlook /tmp/out.csv
checking [google.com:443 Google]...
checking [accuknox.com:443 Accuknox]...
checking [expired.badssl.com:443 BadSSL]...
checking [wrong.host.badssl.com:443 BadSSL]...
checking [self-signed.badssl.com:443 BadSSL]...
checking [untrusted-root.badssl.com:443 BadSSL]...
checking [revoked.badssl.com:443 BadSSL]...
checking [pinning-test.badssl.com:443 BadSSL]...
checking [dh480.badssl.com:443 BadSSL]...
checking [isunknownaddress.com:12345 LocalTest]...
checking [localhost:1234]...
checking [localhost:22 namespace:deployment/wordpress]...
| Name                           | Address                       | Status   | Version | Ciphersuite                 | Hash   | Signature | Verification                                 |
| ------------------------------ | ----------------------------- | -------- | ------- | --------------------------- | ------ | --------- | -------------------------------------------- |
| Google                         | google.com:443                | TLS      | TLSv1.3 | TLS_AES_256_GCM_SHA384      | SHA256 | ECDSA     | OK                                           |
| Accuknox                       | accuknox.com:443              | TLS      | TLSv1.3 | TLS_AES_256_GCM_SHA384      | SHA256 | RSA-PSS   | OK                                           |
| BadSSL                         | expired.badssl.com:443        | TLS      | TLSv1.2 | ECDHE-RSA-AES128-GCM-SHA256 | SHA512 | RSA       | certificate has expired                      |
| BadSSL                         | wrong.host.badssl.com:443     | TLS      | TLSv1.2 | ECDHE-RSA-AES128-GCM-SHA256 | SHA512 | RSA       | OK                                           |
| BadSSL                         | self-signed.badssl.com:443    | TLS      | TLSv1.2 | ECDHE-RSA-AES128-GCM-SHA256 | SHA512 | RSA       | self-signed certificate                      |
| BadSSL                         | untrusted-root.badssl.com:443 | TLS      | TLSv1.2 | ECDHE-RSA-AES128-GCM-SHA256 | SHA512 | RSA       | self-signed certificate in certificate chain |
| BadSSL                         | revoked.badssl.com:443        | TLS      | TLSv1.2 | ECDHE-RSA-AES128-GCM-SHA256 | SHA512 | RSA       | certificate has expired                      |
| BadSSL                         | pinning-test.badssl.com:443   | TLS      | TLSv1.2 | ECDHE-RSA-AES128-GCM-SHA256 | SHA512 | RSA       | OK                                           |
| BadSSL                         | dh480.badssl.com:443          | CONNFAIL |         |                             |        |           |                                              |
| LocalTest                      | isunknownaddress.com:12345    | CONNFAIL |         |                             |        |           |                                              |
| localhost:1234                 | localhost:1234                | CONNFAIL |         |                             |        |           |                                              |
| namespace:deployment/wordpress | localhost:22                  | CONNFAIL |         |                             |        |           |                                              |
```

## Scan container environment

```
docker run --rm -v $PWD:/home/kubetls/data nyrahul/tlsscan --infile data/addr.list --csv data/out.csv
```
> Note: The command assumes that the current folder contains `addr.list` file containing the list of addresses to scan.
