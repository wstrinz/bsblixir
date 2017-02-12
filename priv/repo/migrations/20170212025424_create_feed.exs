defmodule BSB.Repo.Migrations.CreateFeed do
  use Ecto.Migration

  def change do
    create table(:feeds) do
      add :title, :string
      add :description, :text
      add :url, :string
      add :feed_url, :string
      add :updated, :naive_datetime

      timestamps()
    end

  end
end
