FROM oraclelinux:7-slim

RUN yum-config-manager --enable ol7_developer ol7_developer_EPEL  \
    && yum -y install coreutils python python-setuptools git ansible terraform terraform-provider-oci \
    && rm -rf /var/cache/yum/*

RUN easy_install pip  \
    && pip install cryptography oci

RUN mkdir /root/.oci

ADD config oci_api_key.pem /root/.oci/

VOLUME ["/data"]
WORKDIR /data

RUN /data/oci-ansible-modules/install.py

CMD ["/bin/bash"]
