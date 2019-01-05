use Bootleg.DSL

# Configure the following roles to match your environment.
# `app` defines what remote servers your distillery release should be deployed and managed on.
#
# Some available options are:
#  - `user`: ssh username to use for SSH authentication to the role's hosts
#  - `password`: password to be used for SSH authentication
#  - `identity`: local path to an identity file that will be used for SSH authentication instead of a password
#  - `workspace`: remote file system path to be used for building and deploying this Elixir project

role(:app, ["bsb.stri.nz"],
  workspace: "/root/bootlegbsb",
  identity: Path.expand("~/.ssh/id_rsa"),
  silently_accept_hosts: true,
  user: "root"
)

# For some reason asset compilation is running after releases are built
task :rebuild_release do
  remote :build do
    "MIX_ENV=prod mix release --quiet"
  end
end

after_task(:compile, :rebuild_release)
