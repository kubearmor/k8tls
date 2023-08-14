# SPDX-License-Identifier: Apache-2.0
# Copyright 2022 Authors of KubeArmor

.PHONY: build
build:
	@go mod tidy
	@ginkgo --vv --flake-attempts=10 --timeout=10m 

.PHONY: test
test:
	@ginkgo -r