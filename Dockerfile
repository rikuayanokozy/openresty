FROM ubuntu:latest

RUN sed -ie 's/archive.ubuntu.com/mirrors.aliyun.com/g' /etc/apt/sources.list && apt-get update && apt-get dist-upgrade -y && apt-get install -y ca-certificates libssl-dev libpcre++-dev

COPY . /build/openresty
RUN apt-get install -y git build-essential automake autoconf libtool unzip zip wget curl && \
  cd /build && \
  git clone https://github.com/google/ngx_brotli && cd ngx_brotli && git submodule update --init && \
  cd /build/openresty; ./configure -j4 --user=www-data --group=www-data --with-file-aio --with-ipv6 --with-pcre-jit --with-http_realip_module --with-http_stub_status_module --with-http_v2_module --add-module=../ngx_brotli && make -j4 install && \
  for file in /usr/local/openresty/bin/*; do ln -s $file /usr/bin; done && \
  apt-get remove -y build-essential automake autoconf libtool unzip zip wget && apt-get autoremove -y && apt-get clean && rm -rf /build /var/cache/apt

CMD openresty -g "daemon off;"
