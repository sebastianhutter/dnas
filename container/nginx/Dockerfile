#
# compile nginx with ldap authentication
#
FROM fedora:23

# the nginx version to download and compile
ENV nginx_version 1.9.9

# install the necessary tools for download and compilation
RUN dnf install -y python-pip openssl tar gzip git make gcc pcre-devel openssl-devel openldap-devel findutils
# install j2cli
RUN pip install --upgrade j2cli

# download the nginx source, extract it, download the nginx ldap plugin and compile everything
WORKDIR /tmp/build
RUN curl -O http://nginx.org/download/nginx-${nginx_version}.tar.gz
RUN tar -xvzf nginx-${nginx_version}.tar.gz
WORKDIR /tmp/build/nginx-${nginx_version}
# simple auth with ldap backend
RUN git clone https://github.com/kvspb/nginx-auth-ldap.git
# enable proxying of aws s3 (we need to use the v4 branch to enable aws4-hmac-sha256 enc.)
RUN git clone -b AuthV4-dev https://github.com/anomalizer/ngx_aws_auth.git
RUN ./configure --user=root --group=root --prefix=/etc/nginx \
                --sbin-path=/usr/sbin/nginx --conf-path=/etc/nginx/nginx.conf \
                --pid-path=/var/run/nginx.pid --lock-path=/var/run/nginx.lock \
                --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log \
                --with-http_gzip_static_module --with-http_stub_status_module --with-http_ssl_module \
                --with-pcre --with-file-aio --with-http_realip_module \
                --add-module=nginx-auth-ldap
RUN make
RUN make install

# copy default nginx configuration
ADD build/nginx.conf /etc/nginx/nginx.conf

# add the docker entrypoint script
ADD build/docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh

# create the default nginx html directory
RUN mkdir -p /usr/share/nginx/html

# do some cleanup
# remove the build directory
# remove unused locales 
# deinstall unused packages
WORKDIR /
RUN rm -rf /tmp/build && \
    localedef --list-archive | grep -v -i ^en_US | xargs localedef --delete-from-archive && \
    mv /usr/lib/locale/locale-archive /usr/lib/locale/locale-archive.tmpl && build-locale-archive && \
    dnf remove -y gcc pcre-devel openssl-devel openldap-devel findutils && dnf clean -y all

# expose http and https ports
EXPOSE 80 443
# run the docker entrypoint script
ENTRYPOINT ["/docker-entrypoint.sh"]
