FROM armhf/alpine:latest
workdir /root
RUN apk add --update libarchive-tools
ADD https://github.com/prometheus/alertmanager/releases/download/v0.16.1/alertmanager-0.16.1.linux-armv6.tar.gz /root/
RUN bsdtar -xvf *.tar.gz -C ./ --strip-components=1
RUN mkdir /etc/alertmanager

RUN cp alertmanager      /bin/alertmanager
RUN cp alertmanager.yml  /etc/alertmanager/config.yml
RUN cp amtool            /bin/amtool
RUN rm /root/*

EXPOSE     9093
VOLUME     [ "/alertmanager" ]
WORKDIR    /alertmanager
ENTRYPOINT [ "/bin/alertmanager" ]
CMD        [ "-config.file=/etc/alertmanager/config.yml", \
             "-storage.path=/alertmanager" ]

