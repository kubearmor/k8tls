build:
	docker build -t kubearmor/kubetls:latest .

push:
	docker push kubearmor/kubetls:latest
