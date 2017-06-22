defmodule BSB.ModelHelper do
  defmacro __using__(_opts) do
    quote do          # <--
      import BSB.ModelHelper     # <--

      def first do
        BSB.Repo.all(__MODULE__) |> Enum.at(0)
      end

      def update(instance, changes) do
        BSB.Repo.update!(__MODULE__.changeset(Map.merge(instance, changes)))
      end
    end               # <--
  end

end
