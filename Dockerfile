FROM ubuntu:22.04
LABEL org.opencontainers.image.source=https://github.com/openwebwork/renderer

ARG RENDERER_TIMEZONE=America/New_York

WORKDIR /usr/app

ENV DEBIAN_FRONTEND noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN true
ENV DEBCONF_NOWARNINGS yes
ENV TZ=$RENDERER_TIMEZONE

RUN apt-get update \
	&& apt-get install -y --no-install-recommends --no-install-suggests \
	apt-utils \
	ca-certificates \
	cpanminus \
	curl \
	dvipng \
	dvisvgm \
	gcc \
	git \
	imagemagick \
	libarchive-zip-perl \
	libc6-dev \
	libclass-accessor-perl \
	libclass-tiny-perl \
	libcrypt-jwt-perl \
	libdata-structure-util-perl \
	libdatetime-perl \
	libdbi-perl \
	libencode-perl \
	libfuture-asyncawait-perl \
	libgd-perl \
	libhtml-parser-perl \
	libhttp-async-perl \
	libjson-perl \
	libjson-xs-perl \
	liblocale-maketext-lexicon-perl \
	libmath-random-secure-perl \
	libproc-processtable-perl \
	libssl-dev \
	libstorable-perl \
	libstring-shellquote-perl \
	libtie-ixhash-perl \
	libtimedate-perl \
	libuuid-tiny-perl \
	libyaml-libyaml-perl \
	make \
	openssl \
	pdf2svg \
	texlive \
	texlive-latex-extra \
	texlive-latex-recommended \
	texlive-plain-generic \
	&& curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
	&& apt-get install -y --no-install-recommends --no-install-suggests nodejs \
	&& apt-get clean \
	&& rm -fr /var/lib/apt/lists/* /tmp/*

RUN cpanm install -nf \
	Mojolicious \
	Statistics::R::IO::Rserve \
	&& rm -fr ./cpanm /root/.cpanm /tmp/*

COPY . .

RUN cp render_app.conf.dist render_app.conf

RUN cp conf/pg_config.yml lib/PG/conf/pg_config.yml

RUN cd public && npm install && cd ..

RUN cd lib/PG/htdocs && npm install && cd ../../..

EXPOSE 3000

HEALTHCHECK CMD curl -I localhost:3000/health

CMD hypnotoad -f ./script/render_app
