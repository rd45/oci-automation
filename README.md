# oci-automation
This is a starter kit for automation of OCI infrastructure build & config, using Terraform and Ansible

## Setup steps
First thing we'll do is to build a Docker container that has all the tools installed...
1. install Docker on your machine if necessary
2. make a local copy of this repo (e.g. `git clone https://github.com/rdewes/oci-automation.git`)
3. `cd ./oci-automation`
4. find the necessary OCIDs for your tenancy, and update the relevant parameters in the `./OCI/config` and `./Terraform/terraform.tfvars` files. Also create your own API signing key in PEM format at `./OCI/oci_api_key.pem`. All of this is as per [the OCI SDK documentation](https://docs.cloud.oracle.com/iaas/Content/API/Concepts/apisigningkey.htm). If you don't change the OCIDs etc, you'll be working in my tenancy - which is ok within reason, as long as you tidy up afterwards e.g. with `terraform destroy`.
5. build the Docker container (`docker build -t oci-automation .`)
6. run it (`docker run --interactive --tty --rm --volume "$PWD":/data oci-automation:latest`) 

You're now at the bash prompt in a containerised OL7 image, which has the OCI Terraform provider and Ansible modules installed & configured, along with a set of samples that show how to build & configure various OCI services.

## Using Terraform to automate OCI infrastructure build
There are a bunch of examples in the terraform-provider-oci repo - to try them, do the following at the bash prompt in the container that you just built. We already have a var file at /data/Terraform/terraform.tfvars, so we don't need to source env-vars from the example directory. We can also put the state file in /data/Terraform/, because that makes it easier to re-run Terraform against the same targets after stopping & re-starting the container.

1. `cd /root/terraform-provider-oci/docs/examples/[wherever]`
2. `terraform init`
3. `terraform plan --var-file=/data/Terraform/terraform.tfvars --state=/data/Terraform/[filename].tfstate`
4. `terraform apply --var-file=/data/Terraform/terraform.tfvars --state=/data/Terraform/[filename].tfstate`
  
The more complex examples have readme files that go into more detail. Any of the .tf files can be adapted for different requirements.

Picking up an example that we'll use later - the .tf files in `/root/terraform-provider-oci/docs/examples/database/atp/` describe an Autonomous Transaction Processing database on OCI that we can create with Terraform. From that directory, we can use the `terraform` commands above to create it. The `variables.tf` file gives an easy way to change configuration details like name, CPU count, storage size, etc.

## Using Ansible to orchestrate Terraform (and other arbitrary stuff)
Using Terraform directly (with terraform-provider-oci) is already a good way to create OCI services. But where it starts to get interesting is when we also include Ansible as an orchestration method. Ansible comes with all kinds of modules that let us manage the configuration of hosts & other kinds of entity - we can make a fairly simple YAML-formatted Ansible playbook that describes what to do in what order to what entity (or group of entities), with some basic logic & error-handling & parameterisation built in. Amongst the modules that Ansible ships with is the *terraform* module. Which means that we can have a playbook that executes a set of tasks e.g. as follows...
1. pull some set of .tf files, representing our infrastructure as code, out of source control (e.g. using Ansible's git module)
2. build some OCI services, based on those .tf files (using Ansible's terraform module)
3. do whatever post-install config is needed on each of those services (using whatever other Ansible modules are needed)

So, we can call a single playbook that builds & configures an arbitrary set of OCI services, to build a whole fully configured environment. Add Ansible Tower (or equivalent) into the mix, and we can expose the invocation of the playbook as a REST API - in the payload of which we can pass whatever runtime parameters we need.

Following this line of thinking one stage further - we could actually get rid of Terraform entirely, and instead use the [Ansible modules](https://github.com/oracle/oci-ansible-modules/tree/master/docs/modules) that directly address OCI infrastructure & services. Two reasons why I'm not doing that here:
1. the supplied examples that are given for terraform-provider-oci are much easier (for me) to follow & adapt & re-use than the equivalent for oci-ansible-modules
2. it's easier (for me) to see how to store/push/pull a bunch of .tf files in a code repository, in a true infrastructure-as-code solution - whereas in an all-Ansible picture, it feels (to me) like your config choices & your deployment code are all mixed together in the playbook - although maybe this is just my imperfect knowledge of Ansible getting in my way

### Coming soonish, as a worked example of a multi-step playbook...
1. terraform makes an ATP autonomous database & a compute instance (incl. networking etc)
2. ansible downloads & installs JDK & swingbench onto the compute node, configures sqlnet, runs the setup scripts for OE into the database
