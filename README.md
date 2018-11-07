# oci-automation
This is a starter kit for automation of OCI infrastructure build & config with Terraform and Ansible

# Setup steps
1. install git and docker on your machine if necessary
2. git clone https://github.com/rdewes/oci-automation.git
3. cd ./oci-automation
4. find &/or create the keys and OCIDs for your tenancy, and update the relevant parameters in the config and terraform.tfvars files - as per https://docs.cloud.oracle.com/iaas/Content/API/Concepts/apisigningkey.htm (if you don't change the OCIDs etc, you'll be working in my tenancy - that's ok within reason, as long as you tidy up afterwards e.g. with "terraform destroy")
5. build the Docker container (docker build -t oci-automation .)
6. run it (docker run --interactive --tty --rm --volume "$PWD":/data oci-automation:latest) 

You're now at the bash prompt in an OL7 image in a Docker container, which has the OCI Terraform provider and Ansible modules installed & configured, along with a set of samples that show how to build & configure various OCI services.

# Using Terraform to automate OCI infrastructure build
There are a bunch of examples in the terraform-provider-oci repo - to try them, do the following at the bash prompt in the container that you just built. We already have a var file at /data/Terraform/terraform.tfvars, so we don't need to source env-vars from the example directory. We can also put the state file in /data/Terraform/, because that makes it easier to re-run Terraform against the same targets after stopping & re-starting the container.

1. cd /root/terraform-provider-oci/docs/examples/[wherever]
2. terraform init
3. terraform plan --var-file=/data/Terraform/terraform.tfvars --state=/data/Terraform/[filename].tfstate
4. terraform apply --var-file=/data/Terraform/terraform.tfvars --state=/data/Terraform/[filename].tfstate
  
The more complex examples have readme files that go into more detail. Any of the .tf files can be adapted for different requirements.

# Using Ansible for configuration management
to follow...

# *Coming soonish...*
1. terraform makes an ATP autonomous database & a compute instance (incl. networking etc)
2. ansible downloads & installs JDK & swingbench onto the compute node, configures sqlnet, runs the setup scripts for OE into the database
