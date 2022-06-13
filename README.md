# Lab: How to Deploy Google Boutique App on Cisco IKS using Terraform


## Step 1 - Prerequisites

- Create an Intersight API key
- Terraform client
- kubectl

## Step 1 - Deploy Cisco Intersight Kubernetes Service

- cd 1_Deploy_IKS
- Update creds.yml with Intersight API key and Base64 encoded secret key

- tf plan -target=module.iks -out plan.out && apply plan.out

## Step 2 - Deploy Google Boutique App onto IKS


### Resources
Git repository
