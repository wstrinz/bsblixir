defmodule BSB.FeedView do
  use BSB.Web, :view

  def render("index.json", %{feeds: feeds}) do
    %{data: render_many(feeds, BSB.FeedView, "feed.json")}
  end

  def render("show.json", %{feed: feed}) do
    %{data: render_one(feed, BSB.FeedView, "feed.json")}
  end

  def render("feed.json", %{feed: feed}) do
    %{
      id: feed.id,
      title: feed.title,
      description: feed.description,
      url: feed.url,
      feed_url: feed.feed_url,
      base_score: feed.base_score,
      error: feed.error,
      decay_per_hour: feed.decay_per_hour,
      unreadCount: BSB.Feed.unread_story_count(feed),
      updated: feed.updated
    }
  end
end
