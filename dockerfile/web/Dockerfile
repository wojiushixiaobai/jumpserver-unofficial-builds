FROM debian:bookworm-slim AS stage-1
ARG TARGETARCH

ARG DEPENDENCIES="                    \
        ca-certificates               \
        wget"

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    set -e \
    && rm -f /etc/apt/apt.conf.d/docker-clean \
    && echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' >/etc/apt/apt.conf.d/keep-cache \
    && apt-get update \
    && apt-get -y install --no-install-recommends ${DEPENDENCIES}

WORKDIR /opt

ARG CHECK_VERSION=v1.0.4
RUN set -e \
    && wget --quiet https://github.com/jumpserver-dev/healthcheck/releases/download/${CHECK_VERSION}/check-${CHECK_VERSION}-linux-${TARGETARCH}.tar.gz \
    && tar -xf check-${CHECK_VERSION}-linux-${TARGETARCH}.tar.gz -C /usr/local/bin/ check \
    && chown root:root /usr/local/bin/check \
    && chmod 755 /usr/local/bin/check \
    && rm -f /opt/*.tar.gz

ARG VERSION

RUN set -e \
    && mkdir -p /opt/lina /opt/luna /opt/download \
    && wget --quiet https://github.com/wojiushixiaobai/jumpserver-unofficial-builds/releases/download/${VERSION}/lina-${VERSION}.tar.gz \
    && wget --quiet https://github.com/wojiushixiaobai/jumpserver-unofficial-builds/releases/download/${VERSION}/luna-${VERSION}.tar.gz \
    && wget --quiet https://github.com/wojiushixiaobai/jumpserver-unofficial-builds/releases/download/${VERSION}/web-${VERSION}.tar.gz \
    && tar -xf lina-${VERSION}.tar.gz -C /opt/lina --strip-components=1 \
    && tar -xf luna-${VERSION}.tar.gz -C /opt/luna --strip-components=1 \
    && tar -xf web-${VERSION}.tar.gz -C /opt/download --strip-components=1 \
    && chown -R root:root /opt/lina /opt/luna /opt/download \
    && rm -f /opt/*.tar.gz

RUN set -e \
    && mkdir -p /data/web \
    && cd /data \
    && \
    if echo ${VERSION} | grep -q 'dev'; then \
        wget --quiet -O web.tar.gz https://github.com/jumpserver/docker-web/archive/refs/heads/dev.tar.gz; \
    else \
        wget --quiet -O web.tar.gz https://github.com/jumpserver/docker-web/archive/refs/tags/${VERSION}.tar.gz; \
    fi \
    && tar -xf web.tar.gz -C /data/web --strip-components=1 \
    && chmod 755 /data/web/*.sh \
    && chown -R root:root /data/web \
    && rm -f /data/*.tar.gz

FROM nginx:stable-bookworm
ENV LANG=en_US.UTF-8

ARG DEPENDENCIES="                    \
        ca-certificates               \
        logrotate"

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    set -e \
    && rm -f /etc/apt/apt.conf.d/docker-clean \
    && echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' >/etc/apt/apt.conf.d/keep-cache \
    && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && apt-get update \
    && apt-get install -y --no-install-recommends ${DEPENDENCIES}

COPY --from=stage-1 /opt /opt
COPY --from=stage-1 /usr/local/bin /usr/local/bin
COPY --from=stage-1 /data/web/includes /etc/nginx/includes
COPY --from=stage-1 /data/web/nginx.conf /etc/nginx/nginx.conf
COPY --from=stage-1 /data/web/default.conf /etc/nginx/conf.d/default.conf
COPY --from=stage-1 /data/web/http_server.conf /etc/nginx/sites-enabled/http_server.conf
COPY --from=stage-1 /data/web/init.sh /docker-entrypoint.d/40-init-config.sh

WORKDIR /opt

ARG VERSION
ENV VERSION=${VERSION}

VOLUME /var/log/nginx