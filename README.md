# oci-automation
This is a starter kit for automation of OCI infrastructure build & config, using Terraform and Ansible

## Setup steps
First thing we'll do is to build a Docker container that has the necessary tools installed...
1. install git and docker on your machine if necessary
2. clone this repo (`git clone https://github.com/rdewes/oci-automation.git`)
3. `cd ./oci-automation`
4. find the necessary OCIDs for your tenancy, and update the relevant parameters in the `./OCI/config` and `./Terraform/terraform.tfvars` files. Also create your own API signing key in PEM format at `./OCI/oci_api_key.pem`. All of this is as per [the OCI SDK documentation](https://docs.cloud.oracle.com/iaas/Content/API/Concepts/apisigningkey.htm). If you don't change the OCIDs etc, you'll be working in my tenancy - which is ok within reason, as long as you tidy up afterwards e.g. with `terraform destroy`.
5. build the Docker container (`docker build -t oci-automation .`)
6. run it (`docker run --interactive --tty --rm --volume "$PWD":/data oci-automation:latest`) 

You're now at the bash prompt in an OL7 image in a Docker container, which has the OCI Terraform provider and Ansible modules installed & configured, along with a set of samples that show how to build & configure various OCI services.

## Using Terraform to automate OCI infrastructure build
There are a bunch of examples in the terraform-provider-oci repo - to try them, do the following at the bash prompt in the container that you just built. We already have a var file at /data/Terraform/terraform.tfvars, so we don't need to source env-vars from the example directory. We can also put the state file in /data/Terraform/, because that makes it easier to re-run Terraform against the same targets after stopping & re-starting the container.

1. `cd /root/terraform-provider-oci/docs/examples/[wherever]`
2. `terraform init`
3. `terraform plan --var-file=/data/Terraform/terraform.tfvars --state=/data/Terraform/[filename].tfstate`
4. `terraform apply --var-file=/data/Terraform/terraform.tfvars --state=/data/Terraform/[filename].tfstate`
  
The more complex examples have readme files that go into more detail. Any of the .tf files can be adapted for different requirements.

*examples to follow...*

## Using Ansible to orchestrate Terraform (and other arbitrary stuff)
Using Terraform directly (with terraform-provider-oci) is already a good way to create OCI services. But where it starts to get interesting is when we also include Ansible as an orchestration method. Ansible comes with all kinds of modules that let us manage the configuration of hosts & other kinds of entity - we can make a fairly simple YAML-formatted Ansible playbook that describes what to do in what order to what entity (or group of entities), with some basic logic & error-handling & parameterisation built in. Amongst the modules that Ansible ships with is the *terraform* module. Which means that we can have a playbook that executes a set of tasks as follows...
1. pull some set of .tf files, representing our infrastructure as code, out of source control (using Ansible's git module)
2. build some OCI services, based on those .tf files (using Ansible's terraform module)
3. do whatever post-install config is needed on each of those services (using whatever other Ansible modules are needed)

So, we can call a single playbook that builds & configures an arbitrary set of OCI services. Add Ansible Tower (or equivalent) into the mix, and we can expose the invocation of the playbook as a REST API - in the payload of which we can pass whatever parameters we need.

*examples to follow...*

### Coming soonish, as a worked example...
1. terraform makes an ATP autonomous database & a compute instance (incl. networking etc)
2. ansible downloads & installs JDK & swingbench onto the compute node, configures sqlnet, runs the setup scripts for OE into the database
