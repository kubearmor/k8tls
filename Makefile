build:
	docker build -t kubearmor/k8tls:latest .

push:
	docker push kubearmor/k8tls:latest
