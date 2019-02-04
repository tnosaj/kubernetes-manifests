FROM armhf/alpine:latest
workdir /root
RUN apk add --update libarchive-tools ca-certificates && update-ca-certificates
ADD https://github.com/prometheus/blackbox_exporter/releases/download/v0.13.0/blackbox_exporter-0.13.0.linux-armv6.tar.gz /root/
RUN bsdtar -xvf *.tar.gz -C ./ --strip-components=1
RUN mkdir /etc/blackbox_exporter

RUN cp blackbox_exporter  /bin/blackbox_exporter
COPY blackbox.yml       /etc/blackbox_exporter/config.yml
RUN rm /root/*

EXPOSE      9115
ENTRYPOINT  [ "/bin/blackbox_exporter" ]
CMD         [ "--config.file=/etc/blackbox_exporter/config.yml" ]

