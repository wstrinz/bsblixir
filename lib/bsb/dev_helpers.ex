defmodule BSB.DevHelpers do
  alias BSB.{Feed, Repo, Story}

  def reload_all do
    IO.inspect Repo.delete_all(Story)
    Feed.update_feeds
  end
end