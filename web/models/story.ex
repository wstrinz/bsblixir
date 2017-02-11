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
end
