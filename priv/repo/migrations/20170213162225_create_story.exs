defmodule BSB.Repo.Migrations.CreateStory do
  use Ecto.Migration

  def change do
    create table(:stories) do
      add :author, :string
      add :title, :string
      add :subtitle, :string
      add :summary, :text
      add :body, :text
      add :url, :string
      add :updated, :naive_datetime
      add :feed_id, references(:feeds)

      timestamps()
    end

  end
end
