# TLS Scan

Tool to scan/verify if the TLS connection parameters and the certificates usage on the target server ports. The tool does not inject a proxy/sidecar to do this scanning.

## Use-Cases:
* Check if the server port is TLS enabled or not.
* Check TLS version, Ciphersuite, Hash, and Signature for the connection.
* Certificate Verification
  * Is certificate expired or revoked?
  * Is it a self-signed certificate?
* Verification of TLS enabled communication and validation of TLS parameters are key to most compliance frameworks. For e.g.,
  * Under PCI-DSS 3.2., compliant servers must drop support for TLS 1.0 and “migrate to a minimum of TLS 1.1, Preferably TLS 1.2.”
  * HIPAA mandates use of TLS but technically allows use of all versions of TLS.
  * 5G Security: [3GPP TS 33.501](https://www.etsi.org/deliver/etsi_ts/133500_133599/133501/15.04.00_60/ts_133501v150400p.pdf), Security architecture and procedures for 5G system mandates TLS across all control plane connections.
* Operates in k8s, containerized, and non-containerized environments

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
| default/kubernetes[https]                                        | 10.100.0.1:443       | TLS    | TLSv1.3 | TLS_AES_128_GCM_SHA256 | SHA256 | RSA-PSS   | OK                                           |
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

## Scan container environment

```
docker run --rm -v $PWD:/home/kubetls/data nyrahul/tlsscan --infile data/addr.list --csv data/out.csv

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
> Note: The command assumes that the current folder contains `addr.list` file containing the list of addresses to scan.

## Roadmap
* Add service scanning for e.g., mysql, cassandra, ssh etc
* Add support for DTLS scanning
* In detailed mode, enlist all possible TLS versions, Ciphersuites, Hash/Signature algorithms supported.
