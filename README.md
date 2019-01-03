# oci-automation
This is a starter kit for automation of [OCI](https://cloud.oracle.com/cloud-infrastructure) infrastructure build & config, using [Terraform](https://www.terraform.io/) and [Ansible](https://www.ansible.com/).

## Purpose
Building & configuring OCI services is easy, at a small scale - just use the cloud console UI. But if you need to do it at scale, consistently & repeatably, you need some automation. 

All the OCI services have REST API endpoints that we can use to automate build & config. But, the API specs are complex & it's hard work to use them directly - we need some kind of wrapper. In principle, you could write one in bash & call all the APIs with curl. Or python, or whatever you prefer. But you'd be writing a lot of code.

Luckily, there are better tools available. There's a Terraform provider (called [terraform-provider-oci](https://github.com/terraform-providers/terraform-provider-oci)) and a set of custom Ansible modules (called [oci-ansible-modules](https://github.com/oracle/oci-ansible-modules)) that we can use. Both are maintained by Oracle dev. By using them, we can make it much simpler to parameterise & automate our build & config. Plus, Terraform & Ansible are both widely-accepted & well-supported tools that a lot of organisations are already using to build & manage cloud-deployed services.

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
There are a bunch of examples in the terraform-provider-oci repo, which is cloned into the Docker container during build - to try them, do the following at the bash prompt in the container. There's also a var file that sets access-related variables, at `/data/Terraform/terraform.tfvars`, so we don't need to source env-vars from the example directory. We can also put the state file in `/data/Terraform/`, because that makes it easier to re-run Terraform against the same targets after stopping & re-starting the container (plus you get a copy of the state on your local storage that you can still see after you stop the container - it's a JSON file that describes what Terraform has done).

1. `cd /root/terraform-provider-oci/docs/examples/[wherever]`
2. `terraform init`
3. `terraform plan --var-file=/data/Terraform/terraform.tfvars --state=/data/Terraform/[filename].tfstate`
4. `terraform apply --var-file=/data/Terraform/terraform.tfvars --state=/data/Terraform/[filename].tfstate`
  
The more complex examples in terraform-provider-oci have readme files that go into more detail. Any of the .tf files can be adapted for different requirements.

Picking up an example that we'll use later - the .tf files in `/root/terraform-provider-oci/docs/examples/database/atp/` describe an Autonomous Transaction Processing database on OCI that we can create with Terraform. From that directory, we can use the `terraform plan|apply` commands above to create it. The `variables.tf` file gives an easy way to change configuration details like name, CPU count, storage size, etc.

## Using Ansible to orchestrate Terraform (and other arbitrary stuff)
Using terraform-provider-oci directly is already a good way to create OCI services. But where it starts to get realistic is when we also include Ansible as an orchestration method. The basic unit of work in Ansible is a task - and we can combine a set of tasks into a playbook. Ansible comes with all kinds of modules that let us define tasks to manage the configuration of hosts & the other kinds of entity that are inside the OCI services - so we can make a playbook that describes what tasks to do in what order to what entity (or group of entities), with repeatability & basic logic & error-handling & parameterisation built in. 

Amongst the modules that Ansible ships with is the [terraform](https://docs.ansible.com/ansible/devel/modules/terraform_module.html) module. Which means that we can have a playbook that executes a set of tasks e.g. as follows...
1. pull some set of .tf files, representing our infrastructure as code, out of source control (e.g. using Ansible's git module)
2. build some OCI services, based on those .tf files (using Ansible's terraform module)
3. do whatever post-install config is needed on each of those services (using whatever other Ansible modules are needed)

So, we can call a single playbook that creates & configures an arbitrary set of OCI services, to build a whole fully configured environment. Add [AWX](https://github.com/ansible/awx/blob/devel/README.md) (or equivalent) into the mix, and we can expose the invocation of the playbook as a REST API, that we can call from whatever other tool - and in the payload of which we can pass whatever runtime parameters we need.

In principle, we could get rid of Terraform entirely, and instead use the oci-ansible-modules by themselves to address OCI infrastructure & services. Two reasons why I'm not doing that here:
1. the supplied examples that are given for terraform-provider-oci are much easier (for me) to follow & adapt & re-use than the equivalent for oci-ansible-modules
2. it's easier (for me) to see how to store/push/pull a bunch of .tf files in a code repository, in a true infrastructure-as-code solution, and then build the corresponding services with a very simple Ansible task using the terraform module, with really only one variable (`project_path`) to worry about - whereas in an all-Ansible picture, it feels (to me) like your config choices & your deployment code are all mixed together in the playbook

I'm still seeing the oci-ansible-modules stuff as being very useful for any post-deployment configuration change at the OCI service level - an example might be scaling a service up or down in CPU count. Terraform for deployment, Ansible for config.

### Coming soonish, as a worked example of a multi-step playbook...
1. ansible pulls a bunch of .tf files out of git
2. terraform makes an ATP autonomous database & a compute instance (incl. networking etc), based on those .tf files
3. ansible downloads & installs JDK & swingbench onto the compute node, configures sqlnet, runs the setup scripts for the OE benchmark into the database
4. ansible runs a test and captures the output

run.sh will do all these things... eventually...

when it does - boom, automated build & execution of a database performance test environment
