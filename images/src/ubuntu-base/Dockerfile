FROM buildpack-deps:noble-curl@sha256:95dce6c591d314d57ce19a06404479cdb975550cbd87c7730e1fef02ad22d21a

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
