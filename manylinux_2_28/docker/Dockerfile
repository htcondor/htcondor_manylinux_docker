########################
# Docker file to setup a manylinux_2_28 wheel build environment for HTCondor
# manylinux_2_28 (AlmaLinux 8)
# Tim Theisen August 2025

FROM quay.io/pypa/manylinux_2_28_x86_64

# Install set of packages needed to build condor
RUN dnf install -y krb5-devel libcurl-devel libuuid-devel munge-devel nss-devel openldap-devel openssl-devel pam-devel pcre2-devel scitokens-cpp-devel sqlite-devel voms-devel

# Install setuptools and wheel for more recent Python versions
RUN for dir in /opt/python/cp3*[0-9]/bin; do (PATH=$dir:$PATH pip install setuptools wheel); done

CMD ["/bin/bash"]
