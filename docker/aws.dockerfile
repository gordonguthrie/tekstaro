FROM elixir:1.9.4

RUN apt-get update
RUN apt-get install -y nodejs
RUN apt-get install -y npm

ARG PHOENIX_SECRET_KEY_BASE
ARG SESSION_COOKIE_NAME
ARG SESSION_COOKIE_SIGNING_SALT
ARG SESSION_COOKIE_ENCRYPTION_SALT
ARG DATABASE_URL
ARG TAG
ARG DOCKER_LOGIN
ARG DOCKER_PASSWORD

ENV MIX_ENV=prod \
    PHOENIX_SECRET_KEY_BASE=$PHOENIX_SECRET_KEY_BASE \
    SESSION_COOKIE_NAME=$SESSION_COOKIE_NAME \
    SESSION_COOKIE_SIGNING_SALT=$SESSION_COOKIE_SIGNING_SALT \
    SESSION_COOKIE_ENCRYPTION_SALT=$SESSION_COOKIE_ENCRYPTION_SALT \
    DATABASE_URL=$DATABASE_URL \
    TAG=$TAG

EXPOSE 4000

ENV PORT=4000 \
    MIX_ENV=prod \
    REPLACE_OS_VARS=true \
    SHELL=/bin/bash

RUN env
RUN mix local.hex --force
RUN mix archive.install hex phx_new 1.4.12 --force
RUN mkdir /tmp/tekstaro
ADD ./ /tmp/tekstaro
WORKDIR /tmp/tekstaro
RUN mix local.rebar --force
RUN mix deps.get
RUN cd /tmp/tekstaro/assets && npm install
RUN mix phx.digest
RUN MIX_ENV=prod mix distillery.release --env=prod --name=tekstaro --verbose

RUN mkdir -p /tekstaro_aws
RUN cp -R /tmp/tekstaro/_build/prod/rel/tekstaro/* /tekstaro_aws

WORKDIR /tekstaro_aws

CMD ["/tekstaro_aws/bin/tekstaro", "foreground"]
#CMD tail -f /dev/null
