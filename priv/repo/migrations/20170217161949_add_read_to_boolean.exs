defmodule BSB.Repo.Migrations.AddReadToBoolean do
  use Ecto.Migration

  def change do
    alter table(:stories) do
      add :read, :boolean
    end
  end
end
