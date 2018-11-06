# oci-automation
This is a starter kit for automation of OCI infrastructure build & config with Terraform and Ansible

# Setup steps
1. install git and docker if necessary
2. git clone https://github.com/rdewes/oci-automation.git
3. cd ./oci-automation
4. docker build -t oci-automation .
5. docker run --interactive --tty --rm --volume "$PWD":/data oci-automation:latest 

You're now at the bash prompt in an OL7 image in a Docker container, which has the OCI Terraform provider and Ansible modules installed & configured, along with a set of samples that show how to build & configure various OCI services.

# Using Terraform to automate OCI infrastructure build
There are a bunch of examples in the terraform-provider-oci repo - to try them, do the following at the bash prompt in the docker container that you just built. We already have a var file at /data/Terraform/terraform.tfvars, so we don't need to source env-vars from the example directory. We can put the state file in the same directory (/data/Terraform/), because it makes it easier for us to re-run Terraform after stopping & re-starting the container.

1. cd /root/terraform-provider-oci/docs/examples/[wherever]
2. terraform init
3. terraform plan --var-file=/data/Terraform/terraform.tfvars --state=/data/Terraform/terraform.tfstate
4. terraform apply --var-file=/data/Terraform/terraform.tfvars --state=/data/Terraform/terraform.tfstate
  
The more complex examples have readme files that go into more detail. Any of the .tf files can be adapted for different requirements.
