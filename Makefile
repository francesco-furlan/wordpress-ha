.PHONY: init
init:
	terraform init
.PHONY: plan
plan:
	terraform fmt && terraform validate && terraform plan -out=terraform.plan
.PHONY: apply
apply:
	terraform apply terraform.plan
.PHONY: destroy
destroy:
	terraform destroy
