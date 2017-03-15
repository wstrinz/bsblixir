from nextjournal/docker-elixir:1.4.1

RUN apk --update add bash grep coreutils inotify-tools openssl-dev git build-base \
  && rm -fr /var/cache/apk/*

RUN mix local.hex --force
RUN mix local.rebar --force

WORKDIR /code
