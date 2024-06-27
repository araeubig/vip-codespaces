FROM buildpack-deps:jammy-curl@sha256:7779a591a40bfc86721dcbc2469adc533308056e5c6e7d674b89a04af56878f6

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
