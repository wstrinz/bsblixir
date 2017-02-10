defmodule BSB.Story do
  use BSB.Web, :model

  schema "stories" do
    field :author, :string
    field :title, :string
    field :subtitle, :string
    field :summary, :string
    field :body, :string
    field :url, :string
    field :updated, Ecto.DateTime

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:author, :title, :subtitle, :summary, :updated])
    |> validate_required([:author, :title, :summary, :updated])
  end

  # http://feeds.feedburner.com/RockPaperShotgun
  # http://slatestarcodex.com/feed/

  def entry_to_story(entry) do
    %BSB.Story{
      author: entry.author,
      title: entry.title,
      subtitle: entry.subtitle,
      summary: entry.description,
      body: entry.content,
      url: entry.id,
      updated: Ecto.DateTime.utc()
    }
  end

  def feedparser_entry_to_story(entry) do
    %BSB.Story{
      author: entry.author,
      title: entry.title,
      summary: entry.description,
      body: entry.content,
      url: entry.id,
      updated: Ecto.DateTime.utc()
    }
  end

  def first_story_for_feed(url) do
     {:ok, %HTTPoison.Response{body: body}} = HTTPoison.get(url)
    #  {:ok, feed, _} = FeederEx.parse(body)
     feed = ElixirFeedParser.parse(body)

     feed.entries
     |> Enum.at(0)
     |> feedparser_entry_to_story
  end
end
