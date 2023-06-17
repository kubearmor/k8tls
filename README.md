# TLS Scanner

Tool to scan/verify if the TLS connection parameters and the certificates usage on the target server ports. The tool does not inject a proxy/sidecar to do this scanning.

Our primary reason to work on this tool was to handle 5G Security Control checks that mandates use of TLS within 5G Control Plane.

## Use-Cases
* :lock: Check if the server port is TLS enabled or not.
* :page_with_curl: Check TLS version, Ciphersuite, Hash, and Signature for the connection. Are these TLS parameters per the TLS best practices guide?
* Certificate Verification
  * :boom: Is the certificate expired or revoked?
  * :writing_hand: Is it a self-signed certificate?
  * :chains: Is there a self-signed certificate in the full certificate chain?
* Verification of TLS enabled communication and validation of TLS parameters are key to most compliance frameworks. For e.g.,
  * Under PCI-DSS 3.2., compliant servers must drop support for TLS 1.0 and “migrate to a minimum of TLS 1.1, Preferably TLS 1.2.”
  * HIPAA mandates use of TLS but technically allows use of all versions of TLS.
  * 5G Security: [3GPP TS 33.501](https://www.etsi.org/deliver/etsi_ts/133500_133599/133501/15.04.00_60/ts_133501v150400p.pdf), Security architecture and procedures for 5G system mandates TLS across all control plane connections.
* Operates in k8s, containerized, and non-containerized environments
  * :rocket: Scans control + data plane services in k8s in full auto pilot mode. No user-inputs needed.
  * :infinity: Integrate this in CI/CD pipeline to identify use of insecure ports early. Json report option is available.
  * :dart: No proxy or no sidecar implies no impact on runtime performance.

## Getting Started

### Scan k8s services

For k8s, the solution gets deployed as a job that scans the k8s service ports.

```
kubectl apply -f https://raw.githubusercontent.com/kubearmor/kubetls/main/k8s/job.yaml
kubectl logs -n kubetls $(kubectl get pod -n kubetls -l job-name=kubetls -o name) -f
```
```
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

### Scan container environment

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

[![KubeTLS](https://asciinema.org/a/r7iDki9n3tYX9NHuMiloTASwQ.svg)](https://asciinema.org/a/r7iDki9n3tYX9NHuMiloTASwQ)

## Roadmap
* Add service scanning for e.g., mysql, cassandra, ssh etc
* Check if the key size
* Add support for DTLS scanning
* In detailed mode, enlist all possible TLS versions, Ciphersuites, Hash/Signature algorithms supported.
* Verify if algorithms supporting PFS (Pure Forward Secrecy) are used.
* Check for presence of HTTP Strict Transport Security (HSTS)
* Check for HTTP Public Key Pinning (HPKP)
* Check for use of TLS Fallback SCSV to Prevent Protocol Downgrade Attacks
* Check if Secure Renegotiation is enabled. (Secure renegotiation is a feature of the SSL/TLS protocols that allows the client or server to request a new TLS handshake in the middle of a session. This can be useful for a variety of reasons, such as refreshing encryption keys or changing the level of encryption.)
* Validate SSL/TLS best practices.
  * [ssllabs](https://github.com/ssllabs/research/wiki/SSL-and-TLS-Deployment-Best-Practices)
  * [NIST SP 800-52](https://csrc.nist.gov/publications/detail/sp/800-52/rev-2/final).
