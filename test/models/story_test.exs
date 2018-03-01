defmodule BSB.StoryTest do
  use BSB.ModelCase

  alias BSB.Story
  alias BSB.Feed

  @fixture_url "feeds.feedburner.com/RockPaperShotgun"
  @valid_attrs %{
    author: "some content",
    subtitle: "some content",
    summary: "some content",
    title: "some content",
    updated: %{day: 17, hour: 14, min: 0, month: 4, sec: 0, year: 2010}
  }
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    {:ok, feed} = Feed.add_feed(@fixture_url)
    changeset = Story.changeset(%Story{feed_id: feed.id}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Story.changeset(%Story{}, @invalid_attrs)
    refute changeset.valid?
  end
end
