FROM python:3.8

ENV PYTHONUNBUFFERED 1
ENV SPACEONE_PORT 50051
ENV SERVER_TYPE grpc
ENV PKG_DIR /tmp/pkg
ENV SRC_DIR /tmp/src
ENV ETC_PATH /etc/spaceone
ENV LOG_PATH /var/log/spaceone
ENV PYTHONPATH /opt/spaceone
ENV EXTENSION extension


COPY pkg/*.txt ${PKG_DIR}/

RUN GRPC_HEALTH_PROBE_VERSION=v0.3.1 && \
    wget -qO/bin/grpc_health_probe https://github.com/grpc-ecosystem/grpc-health-probe/releases/download/${GRPC_HEALTH_PROBE_VERSION}/grpc_health_probe-linux-amd64 && \
    chmod +x /bin/grpc_health_probe

RUN pip install --upgrade pip && \
    pip install --upgrade -r ${PKG_DIR}/pip_requirements.txt

ARG CACHEBUST=1
RUN pip install --upgrade --pre spaceone-core spaceone-api

COPY src ${SRC_DIR}
WORKDIR ${SRC_DIR}
RUN python3 setup.py install && \
    rm -rf /tmp/*

RUN mkdir -p ${PYTHONPATH}/${EXTENSION} && \
    mkdir -p ${ETC_PATH} && \
    mkdir -p ${LOG_PATH}

WORKDIR ${PYTHONPATH}
RUN echo "__path__ = __import__('pkgutil').extend_path(__path__, __name__)" >> __init__.py

WORKDIR ${PYTHONPATH}/${EXTENSION}
RUN echo "name = '${EXTENSION}'" >> __init__.py

EXPOSE ${SPACEONE_PORT}

ENTRYPOINT ["spaceone"]
CMD ["grpc", "spaceone.secret"]
