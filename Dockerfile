FROM oraclelinux:7-slim

# install necessary RPMs
RUN yum-config-manager --enable ol7_developer_EPEL  \
    && yum-config-manager --add-repo=http://yum.oracle.com/repo/OracleLinux/OL7/developer/x86_64 \
    && yum -y install coreutils python python-setuptools git ansible terraform terraform-provider-oci \
    && rm -rf /var/cache/yum/*

# install Python SDK for OCI (incl. dependencies)
RUN easy_install pip
RUN pip uninstall -y cryptography 
RUN pip install cryptography>=2.1.3 oci

# copy OCI config files into /root/.oci
RUN mkdir /root/.oci
ADD ./OCI/config ./keys/oci_api_key.pem /root/.oci/

# copy ssh private key to /root/.ssh
RUN mkdir /root/.ssh
ADD ./keys/id_rsa /root/.ssh/

# clone OCI git repos containing terraform and ansible tools
RUN git clone https://github.com/terraform-providers/terraform-provider-oci.git /root/terraform-provider-oci/

RUN git clone https://github.com/oracle/oci-ansible-modules.git /root/oci-ansible-modules/  \
    && /root/oci-ansible-modules/install.py

VOLUME ["/data"]
WORKDIR /data

CMD ["/bin/bash"]
