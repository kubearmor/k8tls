build:
	docker buildx build -t kubearmor/k8tls:latest .

build-multiarch:
	docker buildx build --platform linux/amd64,linux/arm64 -t kubearmor/k8tls:latest .

push:
	docker push kubearmor/k8tls:latest
