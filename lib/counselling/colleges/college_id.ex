defmodule Counselling.Colleges.CollegeId do
  @behaviour Ecto.Type

  def type, do: :id

  def cast(binary) when is_binary(binary) do
    case Integer.parse(binary) do
      {int, _} when int > 0 -> {:ok, int}
      _ -> :error
    end
  end

  def cast(integer) when is_integer(integer), do: {:ok, integer}
  def cast(_), do: :error

  def dump(integer) when is_integer(integer), do: {:ok, integer}
  def load(integer) when is_integer(integer), do: {:ok, integer}
  def equal?(a, b), do: a == b
  def embed_as(_), do: :self
end
