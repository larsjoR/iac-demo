az account set -s <Subscription ID>

terraform init 
terraform plan -var-file .\auto.tfvars #-state .\state.tfstate 
terraform apply -var-file .\auto.tfvars -auto-approve #-state .\state.tfstate 
terraform destroy -var-file .\auto.tfvars # -state .\state.tfstate # -auto-approve