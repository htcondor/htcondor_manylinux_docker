########################
# Docker file to setup a manylinux_2_28 wheel build environment for HTCondor
# manylinux_2_28 (AlmaLinux 8)
# Tim Theisen October 2023

FROM quay.io/pypa/manylinux_2_28_x86_64

# Add in EPEL
RUN yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm

# Enable code ready build repository
RUN /usr/bin/crb enable

# Install minimal set of packages except for externals that we wish to build newer versions of
RUN yum install -y readline-devel libicu-devel pam-devel cyrus-sasl-devel uuid-devel libuuid-devel libxml2-devel libtool byacc perl-Archive-Tar flex nss-devel e2fsprogs-devel libselinux-devel krb5-devel keyutils-libs-devel openldap-devel libedit libedit-devel libcurl-devel pcre2-devel openssl-devel voms-devel munge-devel scitokens-cpp-devel

# Build external packages
COPY build_scripts /build_scripts
RUN PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:/usr/local/lib64/pkgconfig:/usr/lib64/pkgconfig build_scripts/build_external.sh boost 1.83.0

# Patch auditwheel
RUN pushd $(dirname $(readlink -f $(which auditwheel)))/../lib/python[1-9].[1-9]*/site-packages/auditwheel && patch < /build_scripts/auditwheel.patch && popd

# Cleanup
RUN rm -rf build_scripts

CMD ["/bin/bash"]
