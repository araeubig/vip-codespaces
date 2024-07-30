FROM buildpack-deps:noble-curl@sha256:fbdafd2edc3ad1a27612fb5a8e10e71f81940b2b9a3db77ec06a7a54eb2cf672

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        gettext \
        moreutils \
        runit \
        tzdata \
    && rm -rf /var/lib/apt/lists/*

RUN \
    update-rc.d -f procps remove && \
    touch /etc/runit/no.emulate.sysv

ENTRYPOINT ["/lib/runit/runit-init"]
