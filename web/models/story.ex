defmodule BSB.Story do
  use BSB.Web, :model
  import Ecto.Query, only: [from: 2]

  schema "stories" do
    field :author, :string
    field :title, :string
    field :subtitle, :string
    field :summary, :string
    field :body, :string
    field :url, :string
    field :read, :boolean
    field :updated, Ecto.DateTime

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:author, :title, :subtitle, :summary, :updated, :body, :url, :read])
    |> validate_required([:author, :title, :updated])
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
