########################
# Docker file to setup a manylinux_2_28 wheel build environment for HTCondor
# manylinux_2_28 (AlmaLinux 8)
# Tim Theisen August 2025

FROM quay.io/pypa/manylinux_2_28_x86_64

# Install set of packages needed to build condor
RUN dnf install -y pam-devel libuuid-devel nss-devel krb5-devel openldap-devel libcurl-devel pcre2-devel openssl-devel voms-devel munge-devel scitokens-cpp-devel

# Install setuptools and wheel for more recent Python versions
RUN for dir in /opt/python/cp3*[0-9]/bin; do (PATH=$dir:$PATH pip install setuptools wheel); done

CMD ["/bin/bash"]
