FROM registry.gitlab.com/tvaughan/docker-clojure:1.10
MAINTAINER "Tom Vaughan <tvaughan@tocino.cl>"

COPY ./kibit-runner /opt/kibit-runner
WORKDIR /opt/kibit-runner
