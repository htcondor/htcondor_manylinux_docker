########################
# Docker file to setup a manylinux2010 wheel build environment for HTCondor
# manylinux2010 (CentOS 6)
# Jason Patton Feb 2020

FROM quay.io/pypa/manylinux2010_x86_64:latest

# Install minimal set of packages except for externals that we wish to build newer versions of
RUN yum install -y "https://repo.opensciencegrid.org/osg/3.4/osg-3.4-el6-release-latest.rpm"
RUN yum install -y readline-devel libicu-devel pam-devel cyrus-sasl-devel pcre-devel uuid-devel uuid-c++-devel libxml2-devel libtool byacc perl-Archive-Tar flex nss-devel c-ares-devel e2fsprogs-devel libselinux-devel python-devel krb5-devel keyutils-libs-devel openldap-devel scitokens-cpp-devel

# Install cmake (latest available from PyPI)
RUN /opt/python/cp37-cp37m/bin/pip install cmake && \
    ln -s /opt/python/cp37-cp37m/bin/cmake /usr/local/bin/cmake

# There is an updated automake in the image, but it was built without pkg-config,
# so link in the pkg-config macros where the updated autoconf can see them.
RUN ln -s /usr/share/aclocal/pkg.m4 /usr/local/share/aclocal-1.16/pkg.m4

# Build external packages
COPY build_scripts /build_scripts
#RUN build_scripts/build_external.sh pcre 8.43
RUN build_scripts/build_external.sh openssl 1.1.1d
RUN PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:/usr/local/lib64/pkgconfig:/usr/lib64/pkgconfig build_scripts/build_external.sh voms 2.1.0-rc0
RUN PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:/usr/local/lib64/pkgconfig:/usr/lib64/pkgconfig build_scripts/build_external.sh gct 6.2.1541705016
RUN PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:/usr/local/lib64/pkgconfig:/usr/lib64/pkgconfig build_scripts/build_external.sh munge 0.5.13
RUN PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:/usr/local/lib64/pkgconfig:/usr/lib64/pkgconfig build_scripts/build_external.sh boost 1.68.0

# Patch auditwheel
RUN pushd $(dirname $(readlink -f $(which auditwheel)))/../lib/python?.?/site-packages/auditwheel && patch < /build_scripts/auditwheel.patch && popd

# Cleanup
RUN rm -rf build_scripts

CMD ["/bin/bash"]
