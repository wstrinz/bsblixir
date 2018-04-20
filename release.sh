mix edeliver build release
mix edeliver deploy release to production --version="0.1.$(git log -1 --date=short --pretty=format:%ct)"