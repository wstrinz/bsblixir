defmodule BSB.Repo.Migrations.AddScoreModifierAndDecayToFeeds do
  use Ecto.Migration

  def change do
    alter table(:feeds) do
      add :base_score, :float, default: 0
      add :decay_per_hour, :float, default: 1/96
    end
  end
end
