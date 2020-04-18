# this is the second of a pair of docker files
#
# In the previous one we build an image - and we call it `tekastaro_release`
# this is a docker image with all the source code mounted in and XWindows setup
# and all sort of stuff you want to fanny about with installed
#
# The elixir app has Distillery as a dependency and this is used to build a release
#
# this second dockerfile builds another image with and pulls the release over from our image `tekastaro_release`
FROM elixir:1.9.4

ARG PHOENIX_SECRET_KEY_BASE
ARG SESSION_COOKIE_NAME
ARG SESSION_COOKIE_SIGNING_SALT
ARG SESSION_COOKIE_ENCRYPTION_SALT
ARG DATABASE_URL

ENV MIX_ENV=prod \
    PHOENIX_SECRET_KEY_BASE=$PHOENIX_SECRET_KEY_BASE \
    SESSION_COOKIE_NAME=$SESSION_COOKIE_NAME \
    SESSION_COOKIE_SIGNING_SALT=$SESSION_COOKIE_SIGNING_SALT \
    SESSION_COOKIE_ENCRYPTION_SALT=$SESSION_COOKIE_ENCRYPTION_SALT \
    DATABASE_URL=$DATABASE_URL

EXPOSE 4000

ENV PORT=4000 \
    MIX_ENV=prod \
    REPLACE_OS_VARS=true \
    SHELL=/bin/bash

WORKDIR /.tekstaro

COPY --from=tekstaro_release:0.1.0 /.tekstaro/_build/prod/rel/tekstaro/releases/0.1.0/tekstaro.tar.gz .

RUN tar zxf tekstaro.tar.gz && rm tekstaro.tar.gz

RUN chown -R root ./releases

RUN cat /.tekstaro/erts-10.7.1/bin/erl
RUN ls -all /.tekstaro/erts-10.7.1/bin
RUN ls /.tekstaro
RUN ls -all /.tekstaro

USER root

CMD ["/.tekstaro/bin/tekstaro", "foreground"]
