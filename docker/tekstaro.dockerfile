# this is the first of a pair of docker files
#
# In this one we build an image which we will call `tekastaro_release`
# this is a docker image with all the source code mounted in and XWindows setup
# and all sort of stuff you want to fanny about with installed
#
# The elixir app has Distillery as a dependency and this is used to build a release
#
# the second dockerfile builds another image with based on our `tekastaro_release` and copies the release over
#
# it builds a release in the directory `/.tekstaro`
# (in normal development you will be running code mounted in `/tekstaro/tekstaro`)

FROM elixir:1.9.4 as tekastaro_release

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

USER root

RUN apt-get update
RUN apt-get install -y git
RUN apt-get install -y make
RUN apt-get install -y unzip
RUN apt-get install -y lynx
RUN apt-get install -y emacs
RUN apt-get install -y wget
RUN apt-get install -y nodejs
RUN apt-get install -y npm
RUN apt-get install -y postgresql postgresql-contrib
RUN apt-get install -y sudo
RUN apt-get install -y lsof
RUN apt-get install -y net-tools
RUN apt-get install -y x11-apps
RUN apt-get install -y pgadmin3
RUN apt-get install -y tree

# Replace 1000 with your user / group id
RUN export uid=501 gid=20 && \
    mkdir -p /home/developer && \
    echo "developer:x:${uid}:${gid}:Developer,,,:/home/developer:/bin/bash" >> /etc/passwd && \
    echo "developer:x:${uid}:" >> /etc/group && \
    echo "developer ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/developer && \
    chmod 0440 /etc/sudoers.d/developer && \
    chown ${uid}:${gid} -R /home/developer && \
    mkdir /home/developer/.mix && \
    chown ${uid}:${gid} -R /home/developer/.mix && \
	  mix local.hex --force && \
	  mix archive.install hex phx_new 1.4.12 --force
RUN mkdir /.tekstaro
ADD tekstaro /.tekstaro
WORKDIR /.tekstaro
RUN mix local.rebar --force
RUN mix deps.get
RUN cd /.tekstaro/assets && npm install
RUN MIX_ENV=prod mix distillery.release init
RUN MIX_ENV=prod mix distillery.release --env=prod
# fix up static cache generation with the mix task

USER developer

#CMD ["/bin/bash"]
CMD tail -f /dev/null
