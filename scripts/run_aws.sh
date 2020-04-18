#!/bin/bash
# just a tester script to be sure image has done built good
# it should crash on boot ;-)
docker run --rm -ti \
             -p 4000:4000 \
             -e COOKIE=a_cookie \
             -e  PHOENIX_SECRET_KEY_BASE="belong to us?" \
             -e  SESSION_COOKIE_NAME="biccie" \
             -e  SESSION_COOKIE_SIGNING_SALT="salty" \
             -e  SESSION_COOKIE_ENCRYPTION_SALT="saltier" \
             -e  DATABASE_URL="blah" \
             tekstaro_aws:0.1.0
