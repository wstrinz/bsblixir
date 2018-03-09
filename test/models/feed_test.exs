defmodule BSB.FeedTest do
  use BSB.ModelCase

  alias BSB.Feed

  @valid_attrs %{
    description: "some content",
    feed_url: "some content",
    title: "some content",
    updated: ~N[1990-03-05 00:10:50],
    url: "some content"
  }
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Feed.changeset(%Feed{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Feed.changeset(%Feed{}, @invalid_attrs)
    refute changeset.valid?
  end
end
