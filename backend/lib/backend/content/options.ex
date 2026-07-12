defmodule Backend.Content.Options do
  @moduledoc """
  Converts the human-friendly admin `key=value` format to task option maps.
  """

  @doc "Parses one non-empty `key=value` option per line."
  def parse(text) when is_binary(text) do
    text
    |> String.split(~r/\R/, trim: true)
    |> Enum.map(&String.trim/1)
    |> Enum.reject(&(&1 == ""))
    |> Enum.reduce_while({:ok, %{}}, &parse_line/2)
    |> case do
      {:ok, options} when map_size(options) > 0 -> {:ok, options}
      {:ok, _options} -> {:error, "добавьте хотя бы один вариант в формате key=value"}
      error -> error
    end
  end

  def parse(_text), do: {:error, "добавьте варианты ответа в формате key=value"}

  @doc "Renders an options map back to stable, editable text."
  def format(options) when is_map(options) do
    options
    |> Enum.sort_by(fn {key, _value} -> to_string(key) end)
    |> Enum.map_join("\n", fn {key, value} -> "#{key}=#{value}" end)
  end

  def format(_options), do: ""

  defp parse_line(line, {:ok, options}) do
    case String.split(line, "=", parts: 2) do
      [key, value] ->
        key = String.trim(key)
        value = String.trim(value)

        cond do
          key == "" -> {:halt, {:error, "у каждого варианта должен быть ключ"}}
          value == "" -> {:halt, {:error, "у варианта #{key} должно быть значение"}}
          Map.has_key?(options, key) -> {:halt, {:error, "ключ #{key} повторяется"}}
          true -> {:cont, {:ok, Map.put(options, key, value)}}
        end

      _other ->
        {:halt, {:error, "строка «#{line}» должна быть в формате key=value"}}
    end
  end
end
