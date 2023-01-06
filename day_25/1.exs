sum =
  IO.stream()
  |> Stream.map(&String.trim/1)
  |> Stream.map(fn snafu ->
    snafu
    |> String.reverse()
    |> String.graphemes()
    |> Enum.with_index()
    |> Enum.reduce(0, fn {digit, position}, total ->
      value =
        case digit do
          "=" -> -2
          "-" -> -1
          n -> String.to_integer(n)
        end

      total + value * 5 ** position
    end)
  end)
  |> Enum.sum()

max_position =
  0
  |> Stream.iterate(&(&1 + 1))
  |> Enum.find(&(2 * 5 ** &1 >= sum))

max_position..0//-1
|> Enum.map_reduce(sum, fn position, remaining ->
  unit = 5 ** position

  diff =
    if remaining < 0 do
      round(remaining / unit)
      |> max(-2)
    else
      round(remaining / unit)
      |> min(2)
    end

  {
    case diff do
      -2 -> "="
      -1 -> "-"
      n -> Integer.to_string(n)
    end,
    remaining - diff * unit
  }
end)
|> elem(0)
|> Enum.join()
|> IO.puts()
