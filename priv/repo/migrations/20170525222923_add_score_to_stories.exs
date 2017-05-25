defmodule BSB.Repo.Migrations.AddScoreToStories do
  use Ecto.Migration

  def change do
    alter table(:stories) do
      add :score, :float, default: 0
    end
  end
end
