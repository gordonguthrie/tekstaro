FROM elixir:1.9.4

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

RUN useradd developer
RUN mkdir /home/developer
RUN chown developer /home/developer

RUN systemctl enable postgresql

USER developer

RUN mix local.hex --force
RUN mix archive.install hex phx_new 1.4.12 --force


#CMD ["/bin/bash"]
CMD tail -f /dev/null
