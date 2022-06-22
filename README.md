# Lab: How to Deploy Google Boutique App on Cisco IKS using Terraform


## Step 1 - Prerequisites

- Create an Intersight API key
- Terraform client
- kubectl

## Step 1 - Deploy Cisco Intersight Kubernetes Service

- cd 1_Deploy_IKS
- Update creds.yml with Intersight API key and Base64 encoded secret key
- 
- export CLUSTERNAME=sbox
-
- terraform plan -state=${CLUSTERNAME}-tfstate -target=module.iks -var="iks_cluster_name=${CLUSTERNAME}" -out plan.out && terraform apply -state=${CLUSTERNAME}-tfstate plan.out
- terraform plan -state=${CLUSTERNAME}-tfstate -var="iks_cluster_name=${CLUSTERNAME}" -var="iks_cluster_action=Deploy" -out plan.out && terraform apply -state=${CLUSTERNAME}-tfstate plan.out

## Step 2 - Deploy Google Boutique App onto IKS

- terraform destroy -state=${CLUSTERNAME}-tfstate -var='iks_cluster_name=${CLUSTERNAME}' --auto-approve

### Resources
Git repository
