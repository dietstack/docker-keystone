FROM alpine:3.5
ENV SVC_NAME=keystone SVC_VERSION=10.0.1
ENV RELEASE_URL=https://github.com/openstack/$SVC_NAME/archive/$SVC_VERSION.tar.gz

RUN apk add --no-cache ca-certificates wget python; \
    update-ca-certificates; \
    wget --no-check-certificate https://bootstrap.pypa.io/get-pip.py; \
    python get-pip.py; \
    rm get-pip.py; \
    wget https://raw.githubusercontent.com/openstack/requirements/stable/newton/upper-constraints.txt && \
    apk add --no-cache git gcc python-dev musl-dev libffi-dev libressl-dev libxml2-dev linux-headers libxslt-dev && \
    wget $RELEASE_URL && tar xvfz $SVC_VERSION.tar.gz -C / && mv $(ls -1d $SVC_NAME*) $SVC_NAME && \
    cd /$SVC_NAME && pip install -r requirements.txt -c /upper-constraints.txt && PBR_VERSION=$SVC_VERSION python setup.py install && \
    apk del git gcc python-dev musl-dev libffi-dev libressl-dev libxml2-dev linux-headers libxslt-dev && \
    rm -rf /root/.cache
