# tekstaro
A corpus inspection site for Esperanto

## To develop Tekstaro

This is designed to be developed inside a local docker container

Start by cloning the repo:
`git clone https://github.com/gordonguthrie/tekstaro.git`
`cd tekstaro`

You first build the image:
`docker-compose build`

Then start it:
`docker-compose up`

You can shell into the running `docker` container by running the batch file `start_tekstaro.sh` in another shell

It will have mounted the local file system into the directory `/tekstaro`. To start developing do the following:
`cd /tekstaro/tekstaro`

and then install all the dependencies and build the assets:
```
mix local.rebar --force
mix deps.get
cd /tekstaro/tekstaro/assets && npm install
```

Then you can simply run `iex -S mix phx.server` in the normal fashion.

If you have X-Windows (X-Quartz) installed on your host ***AND*** you have started an X-application locally you can use X-Windows to run `observer` and `pgadmin3` - you might need to run `xhost +` in your shell before building and starting the `docker` container
