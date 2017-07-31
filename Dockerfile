FROM debian:stretch-slim
ENV SVC_NAME=keystone SVC_VERSION=10.0.3
ENV RELEASE_URL=https://github.com/openstack/$SVC_NAME/archive/$SVC_VERSION.tar.gz

ENV BUILD_PACKAGES="build-essential libssl-dev libffi-dev python-dev"

# Apply source code patches
RUN mkdir -p /patches
COPY patches/* /patches/

RUN echo 'APT::Install-Recommends "false";' >> /etc/apt/apt.conf && \
    echo 'APT::Get::Install-Suggests "false";' >> /etc/apt/apt.conf && \
    apt update; apt install -y ca-certificates wget python libpython2.7 nginx; \
    update-ca-certificates; \
    wget --no-check-certificate https://bootstrap.pypa.io/get-pip.py; \
    python get-pip.py; \
    rm get-pip.py; \
    wget https://raw.githubusercontent.com/openstack/requirements/stable/newton/upper-constraints.txt -P /app && \
    /patches/stretch-crypto.sh && \
    apt-get clean && apt autoremove && \
    rm -rf /var/lib/apt/lists/*; rm -rf /root/.cache


RUN apt update; apt install -y $BUILD_PACKAGES && \
    wget $RELEASE_URL && tar xvfz $SVC_VERSION.tar.gz -C / && mv $(ls -1d $SVC_NAME*) $SVC_NAME && \
    cd /$SVC_NAME && pip install -r requirements.txt -c /app/upper-constraints.txt && PBR_VERSION=$SVC_VERSION python setup.py install && \
    pip install supervisor uwsgi PyMySQL python-memcached && \
    apt remove -y --auto-remove $BUILD_PACKAGES &&  \
    apt-get clean && apt autoremove && \
    rm -rf /var/lib/apt/lists/* && rm -rf /root/.cache

# prepare directories for supervisor
RUN mkdir -p /etc/supervisord /var/log/supervisord

# prepare necessary stuff
RUN rm /etc/nginx/sites-enabled/default; \
    mkdir -p /var/log/nginx/keystone && \
    useradd -M -s /sbin/nologin keystone && \
    usermod -G www-data keystone && \
    mkdir -p /run/uwsgi/ && chown keystone:keystone /run/uwsgi && chmod 775 /run/uwsgi

# copy keystone configs
COPY configs/keystone/* /etc/keystone/

# copy supervisor config
COPY configs/supervisord/supervisord.conf /etc

# copy uwsgi ini files
RUN mkdir -p /etc/uwsgi
COPY configs/uwsgi/keystone-admin.ini /etc/uwsgi/keystone-admin.ini
COPY configs/uwsgi/keystone-main.ini /etc/uwsgi/keystone-main.ini

# prepare nginx configs
RUN sed -i '1idaemon off;' /etc/nginx/nginx.conf
COPY configs/nginx/keystone.conf /etc/nginx/sites-enabled/keystone.conf

# external volume
VOLUME /keystone-override

# copy startup scripts
COPY scripts /app

# Define workdir
WORKDIR /app
RUN chmod +x /app/*

ENTRYPOINT ["/app/entrypoint.sh"]

# Define default command.
CMD ["/usr/local/bin/supervisord", "-c", "/etc/supervisord.conf"]
