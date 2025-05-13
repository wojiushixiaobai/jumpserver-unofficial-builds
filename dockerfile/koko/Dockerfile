FROM redis:7-bookworm AS stage-1
FROM golang:1.24-bookworm AS stage-2
ARG TARGETARCH

WORKDIR /opt

ARG CHECK_VERSION=v1.0.4
RUN set -e \
    && wget --quiet https://github.com/jumpserver-dev/healthcheck/releases/download/${CHECK_VERSION}/check-${CHECK_VERSION}-linux-${TARGETARCH}.tar.gz \
    && tar -xf check-${CHECK_VERSION}-linux-${TARGETARCH}.tar.gz -C /usr/local/bin/ check \
    && chown root:root /usr/local/bin/check \
    && chmod 755 /usr/local/bin/check \
    && rm -f /opt/*.tar.gz

ARG WISP_VERSION=v0.2.6
RUN set -e \
    && wget --quiet https://github.com/jumpserver-dev/wisp/releases/download/${WISP_VERSION}/wisp-${WISP_VERSION}-linux-${TARGETARCH}.tar.gz \
    && tar -xf wisp-${WISP_VERSION}-linux-${TARGETARCH}.tar.gz -C /usr/local/bin/ wisp \
    && chown root:root /usr/local/bin/wisp \
    && chmod 755 /usr/local/bin/wisp \
    && rm -f /opt/*.tar.gz

ARG USQL_VERSION=v0.0.6
RUN set -e \
    && wget --quiet https://github.com/jumpserver-dev/usql/releases/download/${USQL_VERSION}/usql-${USQL_VERSION}-linux-${TARGETARCH}.tar.gz \
    && tar -xf usql-${USQL_VERSION}-linux-${TARGETARCH}.tar.gz -C /usr/local/bin/ usql \
    && chown root:root /usr/local/bin/usql \
    && chmod 755 /usr/local/bin/usql \
    && rm -f /opt/*.tar.gz

ARG HELM_VERSION=v3.17.3
ARG KUBECTL_VERSION=v1.33.0
RUN set -e \
    && wget --quiet -O kubectl.tar.gz https://dl.k8s.io/${KUBECTL_VERSION}/kubernetes-client-linux-${TARGETARCH}.tar.gz \
    && tar -xf kubectl.tar.gz --strip-components=3 -C /opt kubernetes/client/bin/kubectl \
    && mv kubectl /usr/local/bin/rawkubectl \
    && mkdir /opt/kubectl-aliases/ \
    && wget --quiet https://github.com/ahmetb/kubectl-aliases/raw/master/.kubectl_aliases \
    && mv .kubectl_aliases /opt/kubectl-aliases/ \
    && chown -R root:root /opt/kubectl-aliases/ \
    && wget --quiet https://get.helm.sh/helm-${HELM_VERSION}-linux-${TARGETARCH}.tar.gz \
    && tar -xf helm-${HELM_VERSION}-linux-${TARGETARCH}.tar.gz --strip-components=1 linux-${TARGETARCH}/helm \
    && mv helm /usr/local/bin/rawhelm \
    && chmod 755 /usr/local/bin/rawhelm /usr/local/bin/rawkubectl \
    && chown root:root /usr/local/bin/rawhelm /usr/local/bin/rawkubectl \
    && rm -f /opt/*.tar.gz

ARG MONGOSH_VERSION=2.5.1
RUN set -e \
    && \
    case "${TARGETARCH}" in \
        amd64) \
            wget https://downloads.mongodb.com/compass/mongosh-${MONGOSH_VERSION}-linux-x64.tgz \
            && tar -xf mongosh-${MONGOSH_VERSION}-linux-x64.tgz \
            && chown root:root mongosh-${MONGOSH_VERSION}-linux-x64/bin/* \
            && mv mongosh-${MONGOSH_VERSION}-linux-x64/bin/mongosh /usr/local/bin/ \
            && mv mongosh-${MONGOSH_VERSION}-linux-x64/bin/mongosh_crypt_v1.so /usr/local/lib/ \
            && rm -rf mongosh-${MONGOSH_VERSION}-linux-x64* \
            ;; \
        arm64|ppc64le|s390x) \
            wget https://downloads.mongodb.com/compass/mongosh-${MONGOSH_VERSION}-linux-${TARGETARCH}.tgz \
            && tar -xf mongosh-${MONGOSH_VERSION}-linux-${TARGETARCH}.tgz \
            && chown root:root mongosh-${MONGOSH_VERSION}-linux-${TARGETARCH}/bin/* \
            && mv mongosh-${MONGOSH_VERSION}-linux-${TARGETARCH}/bin/mongosh /usr/local/bin/ \
            && mv mongosh-${MONGOSH_VERSION}-linux-${TARGETARCH}/bin/mongosh_crypt_v1.so /usr/local/lib/ \
            && rm -rf mongosh-${MONGOSH_VERSION}-linux-${TARGETARCH}* \
            ;; \
        *) \
            echo "Unsupported architecture: ${TARGETARCH}" \
            ;; \
    esac

ARG VERSION

RUN set -e \
    && mkdir -p /opt/koko \
    && wget --quiet https://github.com/wojiushixiaobai/jumpserver-unofficial-builds/releases/download/${VERSION}/koko-${VERSION}.tar.gz \
    && tar -xf /opt/koko-${VERSION}.tar.gz -C /opt/koko --strip-components=1 \
    && rm -f /opt/*.tar.gz

RUN --mount=type=cache,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build \
    set -e \
    && cd /opt/koko \
    && make linux-${TARGETARCH} BUILDDIR=dist VERSION=${VERSION} \
    && mv dist/*.tar.gz /opt \
    && rm -rf /opt/koko

WORKDIR /opt/koko

RUN set -e \
    && tar -xf /opt/koko-${VERSION}-linux-${TARGETARCH}.tar.gz -C /opt/koko --strip-components=1 \
    && chown -R root:root /opt/koko \
    && mv /opt/koko/kubectl /usr/local/bin/ \
    && mv /opt/koko/helm /usr/local/bin/ \
    && chmod 755 /usr/local/bin/helm /usr/local/bin/kubectl /opt/koko/*.sh \
    && chown -R root:root /opt/koko \
    && rm -f /opt/*.tar.gz

FROM debian:bookworm-slim
ENV LANG=en_US.UTF-8

ARG DEPENDENCIES="                    \
        ca-certificates"

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    set -e \
    && rm -f /etc/apt/apt.conf.d/docker-clean \
    && echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' >/etc/apt/apt.conf.d/keep-cache \
    && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && apt-get update \
    && apt-get install -y --no-install-recommends ${DEPENDENCIES}

COPY --from=stage-1 /usr/local/bin/redis-cli /usr/local/bin/redis-cli
COPY --from=stage-2 /usr/local/bin /usr/local/bin
COPY --from=stage-2 /usr/local/lib /usr/local/lib
COPY --from=stage-2 /opt/koko /opt/koko
COPY --from=stage-2 /opt/kubectl-aliases /opt/kubectl-aliases

WORKDIR /opt/koko

ARG VERSION
ENV VERSION=${VERSION}

VOLUME /opt/koko/data

ENTRYPOINT ["./entrypoint.sh"]

EXPOSE 2222 5000

STOPSIGNAL SIGQUIT

CMD [ "./koko" ]