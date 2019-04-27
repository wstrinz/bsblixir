defmodule BSB.Repo.Migrations.AddErrorFieldToFeeds do
  use Ecto.Migration

  def change do
    alter table(:feeds) do
      add(:error, :string)
    end
  end
end
