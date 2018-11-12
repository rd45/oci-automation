#!/bin/bash
ansible-playbook /data/Ansible/main.yaml --extra-vars '{"v_clone_dest":"/data/Terraform/terraform-provider-oci"}'
