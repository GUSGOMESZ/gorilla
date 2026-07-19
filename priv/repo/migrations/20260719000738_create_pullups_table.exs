defmodule Gorilla.Repo.Migrations.CreatePullupsTable do
  use Ecto.Migration

  def change do
    create table(:pullups, primary_key: false) do
      add :id, :uuid, null: false, default: fragment("gen_random_uuid()"), primary_key: true

      add :done_at, :utc_datetime, null: false
      add :set, :integer, null: false
      add :reps, :integer, null: false
      add :date, :date, null: false
    end

    create unique_index(:pullups, [:date, :set], name: "pullups_index")
  end
end
