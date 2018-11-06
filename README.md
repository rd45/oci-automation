# oci-automation
Starter kit for automating OCI infrastructure build and config with Terraform and Ansible

# setup steps
1. install git and docker if necessary
2. git clone https://github.com/rdewes/oci-automation.git
3. cd ./oci-automation
3. docker build -t oci-automation .
4. docker run --interactive --tty --rm --volume "$PWD":/data oci-automation:latest 

You now have a OL7 image in a Docker container, which has the OCI Terraform provider and Ansible modules installed & configured, along with a set of samples

# using Terraform to automate OCI infrastructure build
there are a bunch of examples in the terraform-provider-oci repo - to try them, do the following at the bash prompt in the docker container that you just built

1. cd /root/terraform-provider-oci/docs/examples/[wherever]
2. terraform init
3. terraform plan -var-file=/root/terraform.tfvars
4. terraform apply -var-file=/root/terraform.tfvars
  
the more complex examples have readme files that go into more detail
