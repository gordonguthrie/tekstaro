# this is the first of a pair of docker files
#
# In this one we build an image called `builder`
# this is a docker image with all the source code mounted in and XWindows setup
# and all sort of stuff you want to fanny about with installed
#
# The elixir app has Distillery as a dependency and this is used to build a release
#
# the second dockerfile builds another image with based on our `builder` and copies the release over
FROM elixir:1.9.4 as builder

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
WORKDIR /tekstaro/tekstaro/
RUN mix deps.get
RUN mix Ecto.setup
RUN cd assets && npm install
RUN mix distillery.release init
RUN mix distillery.release --env=prod
# fix up static cache generation with the mix task

USER developer

#CMD ["/bin/bash"]
CMD tail -f /dev/null
