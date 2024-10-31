FROM buildpack-deps:noble-curl@sha256:61a02a85f7bd808d46ba3bd1dd757f277dc3026c68497a61d40c954ae277519a

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        gettext \
        moreutils \
        runit \
        tzdata \
    && rm -rf /var/lib/apt/lists/* \
    && deluser --remove-home ubuntu

RUN \
    update-rc.d -f procps remove && \
    touch /etc/runit/no.emulate.sysv

ENTRYPOINT ["/lib/runit/runit-init"]
