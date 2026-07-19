defmodule Gorilla.PullUp do
  use Ecto.Schema

  import Ecto.Changeset
  import Ecto.Query

  alias Gorilla.Repo

  @primary_key {:id, :binary_id, autogenerate: false}

  schema "pullups" do
    field :date, :date
    field :set, :integer
    field :reps, :integer
    field :done_at, :utc_datetime
  end

  def changeset(pull_up, attrs) do
    pull_up
    |> cast(attrs, [:date, :set, :reps, :done_at])
    |> validate_required([:date, :set, :reps, :done_at])
    |> validate_inclusion(:set, 1..10)
    |> unique_constraint([:date, :set], name: :pullups_index)
  end

  def list_all_time do
    Repo.all(from p in __MODULE__)
  end

  def list_for_day(day) do
    Repo.all(from p in __MODULE__, where: p.date == ^day, order_by: p.set)
  end

  def toggle_set(date, set, reps) do
    case Repo.get_by(__MODULE__, date: date, set: set) do
      nil ->
        %__MODULE__{}
        |> changeset(%{date: date, set: set, reps: reps, done_at: DateTime.utc_now()})
        |> Repo.insert()

      pull_up ->
        Repo.delete(pull_up)
    end
  end
end
