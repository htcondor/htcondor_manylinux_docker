########################
# Docker file to setup a manylinux2014 wheel build environment for HTCondor
# manylinux2014 (CentOS 7)
# Jason Patton Nov 2021

FROM quay.io/pypa/manylinux2014_x86_64

# Install minimal set of packages except for externals that we wish to build newer versions of
RUN yum install -y readline-devel libicu-devel pam-devel cyrus-sasl-devel uuid-devel uuid-c++-devel libuuid-devel libxml2-devel libtool byacc perl-Archive-Tar flex nss-devel e2fsprogs-devel libselinux-devel krb5-devel keyutils-libs-devel openldap-devel libedit libedit-devel libcurl-devel pcre2-devel


# Build external packages
COPY build_scripts /build_scripts
RUN build_scripts/build_external.sh openssl 1.1.1q
RUN PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:/usr/local/lib64/pkgconfig:/usr/lib64/pkgconfig build_scripts/build_external.sh voms 2.1.0-rc0
RUN PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:/usr/local/lib64/pkgconfig:/usr/lib64/pkgconfig build_scripts/build_external.sh munge 0.5.15
RUN PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:/usr/local/lib64/pkgconfig:/usr/lib64/pkgconfig build_scripts/build_external.sh boost 1.68.0

# Patch auditwheel
RUN pushd $(dirname $(readlink -f $(which auditwheel)))/../lib/python?.?/site-packages/auditwheel && patch < /build_scripts/auditwheel.patch && popd

# Cleanup
RUN rm -rf build_scripts

CMD ["/bin/bash"]