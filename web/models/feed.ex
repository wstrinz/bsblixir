defmodule BSB.Feed do
  use BSB.Web, :model

  schema "feeds" do
    field :title, :string
    field :description, :string
    field :url, :string
    field :feed_url, :string
    field :updated, Ecto.DateTime

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:title, :description, :url, :feed_url, :updated])
    |> validate_required([:title, :description, :url, :feed_url, :updated])
  end

  def feed_for_url(feed_url) do
    {:ok, %HTTPoison.Response{body: body}} = HTTPoison.get(feed_url)
    #  {:ok, feed, _} = FeederEx.parse(body)
    ElixirFeedParser.parse(body)
  end

  def feedparser_feed_to_chgset(feed, feed_url) do
    %BSB.Feed{
      title: feed.title,
      description: feed.description,
      url: feed.url,
      feed_url: feed_url,
      updated: Ecto.DateTime.utc()
    }
  end

  def get_feed(url) do
    feed_for_url(url)
    |> feedparser_feed_to_chgset(url)
  end

  def add_feed(url) do
     get_feed(url)
     |> BSB.Repo.insert
  end

  def update_feed(feed) do
    BSB.StoryFetcher.load_stories(feed.feed_url)
  end

  def update_feeds do
    BSB.Repo.all(BSB.Feed)
    |> Enum.map(&update_feed/1)
  end
end
