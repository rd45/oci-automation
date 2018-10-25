#!/usr/bin/bash
git clone https://github.com/terraform-providers/terraform-provider-oci.git
git clone https://github.com/oracle/oci-ansible-modules.git

docker build -t tf-and-ansible ./docker
docker run --interactive --tty --rm --volume "$PWD":/data tf-and-ansible:latest
