defmodule BSB.Story do
  use BSB.Web, :model
  use BSB.ModelHelper, :first
  import Ecto.Query, only: [from: 2]

  schema "stories" do
    field :author, :string
    field :title, :string
    field :subtitle, :string
    field :summary, :string
    field :body, :string
    field :url, :string
    field :read, :boolean
    field :score, :float
    field :updated, Ecto.DateTime
    belongs_to(:feed, BSB.Feed)

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:author, :title, :subtitle, :summary, :updated, :body, :url, :read, :score, :feed_id])
    |> validate_required([:title, :updated, :feed_id])
  end

  def story_for_url(url) do
    (from s in BSB.Story,
      where: s.url == ^url,
      select: s)
    |> BSB.Repo.all
  end
  # http://feeds.feedburner.com/RockPaperShotgun
  # http://slatestarcodex.com/feed/
end
