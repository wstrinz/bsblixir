defmodule BSB.Feed do
  use BSB.ModelHelper, :first
  use BSB.Web, :model

  schema "feeds" do
    field :title, :string
    field :description, :string
    field :url, :string
    field :feed_url, :string
    field :updated, Ecto.DateTime
    field :base_score, :float
    field :decay_per_hour, :float
    has_many :stories, BSB.Story

    timestamps()
  end

  # def first do
  #   first()
  # end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:title, :description, :url, :feed_url, :updated, :decay_per_hour, :base_score])
    |> validate_required([:title, :url, :feed_url, :updated])
  end

  def feed_for_url(feed_url) do
    {:ok, %HTTPoison.Response{body: body}} = HTTPoison.get(feed_url, [], follow_redirect: true)
    #  {:ok, feed, _} = FeederEx.parse(body)
    IO.inspect(body)
    case ElixirFeedParser.parse(body) do
      {:ok, result} ->
        result
    end
  end

  def feedparser_feed_to_chgset(feed, feed_url) do
    %BSB.Feed{
      title: feed.title,
      description: feed.description,
      url: feed.url,
      feed_url: feed_url,
      base_score: 100.0,
      decay_per_hour: 0.01,
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
    BSB.StoryFetcher.load_stories(feed)
  end

  def update_feeds do
    BSB.Repo.all(BSB.Feed)
    |> Enum.map(&(Task.async(fn -> update_feed(&1) end)))
    |> Enum.map(&Task.await/1)
  end

  def seed do
    ["http://feeds.feedburner.com/RockPaperShotgun", "https://hnrss.org/frontpage?points=50"]
    |> Enum.map(&add_feed/1)
    |> Enum.map(fn({:ok, f}) -> update_feed(f) end)
  end
end
