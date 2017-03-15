# Development with Docker

## Requirements

* [docker](https://www.docker.com/get-docker)
* [docker-compose](https://docs.docker.com/compose/install/)

## Usage

*If you've developed without docker before, please get sure that any output directories on your host like `_build`, `deps`, `priv/static`, `_node_modules` and so on are empty, otherwise you could get unexpected issues. Better start with a fresh clone.*

`./bin/cdev` or `./bin/ctest` are just wrappers for docker-compose commands.

- `./bin/cdev up` starts postgres, an elm container which watches files and phoenix
- `./bin/cdev exec phoenix bash` or just `cdev` attaches you to the phoenix container. exec `iex -S mix phoenix.server` to start phoenix then.
- `./bin/cdev down -v` removes everything again (containers and volumes)

- `./bin/ctest up` starts postgres and phoenix
- `./bin/ctest exec phoenix bash` or just `ctest` attaches you to the phoenix test container. exec `mix test` to run tests then.
- `./bin/ctest down -v` removes evertying again (containers and volumes)

see https://docs.docker.com/compose/reference/ for more details.


