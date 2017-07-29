FROM alpine:3.5
ENV SVC_NAME=keystone SVC_VERSION=10.0.1
ENV RELEASE_URL=https://github.com/openstack/$SVC_NAME/archive/$SVC_VERSION.tar.gz

RUN apk add --no-cache ca-certificates wget python nginx libxml2; \
    update-ca-certificates; \
    wget --no-check-certificate https://bootstrap.pypa.io/get-pip.py; \
    python get-pip.py; \
    rm get-pip.py; \
    wget https://raw.githubusercontent.com/openstack/requirements/stable/newton/upper-constraints.txt && \
    apk add --no-cache git gcc python-dev musl-dev libffi-dev libressl-dev libxml2-dev linux-headers libxslt-dev && \
    wget $RELEASE_URL && tar xvfz $SVC_VERSION.tar.gz -C / && mv $(ls -1d $SVC_NAME*) $SVC_NAME && \
    cd /$SVC_NAME && pip install -r requirements.txt -c /upper-constraints.txt && PBR_VERSION=$SVC_VERSION python setup.py install && \
    pip install uwsgi supervisor PyMySQL python-memcached && \
    apk del git gcc python-dev musl-dev libffi-dev libressl-dev libxml2-dev linux-headers libxslt-dev && \
    rm -rf /root/.cache

# prepare directories for supervisor
RUN mkdir -p /etc/supervisord /var/log/supervisord

RUN rm /etc/nginx/conf.d/default; \
    mkdir -p /var/log/nginx/keystone && \
    addgroup -S keystone && \
    adduser -D -H -S -G keystone -s /bin/false keystone && \
    adduser keystone www-data && \
    mkdir -p /run/nginx/ && \
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
COPY configs/nginx/keystone.conf /etc/nginx/conf.d/keystone.conf

# external volume
VOLUME /keystone-override

# copy startup scripts
COPY scripts /app

# Define workdir
WORKDIR /app
RUN chmod +x /app/*

ENTRYPOINT ["/app/entrypoint.sh"]

# Define default command.
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]

