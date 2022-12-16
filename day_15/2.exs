sensors =
  IO.stream()
  |> Stream.map(&String.trim/1)
  |> Enum.map(fn line ->
    [x1, y1, x2, y2] =
      Regex.scan(~r{-?\d+}, line)
      |> List.flatten()
      |> Enum.map(&String.to_integer/1)

    {{x1, y1}, abs(x1 - x2) + abs(y1 - y2)}
  end)

Enum.find_value(0..4_000_000, fn y ->
  sensors
  |> Enum.filter(fn {{_sx, sy}, sradius} -> abs(y - sy) <= sradius end)
  |> Enum.map(fn {{sx, sy}, sradius} ->
    remaining = abs(sradius - abs(y - sy))
    {sx - remaining, sx + remaining}
  end)
  |> Enum.sort()
  |> Enum.reduce(0, fn
    {_min, max}, x when x > max -> x
    {min, _max}, x when x < min -> x
    {_min, max}, _x -> max + 1
  end)
  |> case do
    x when x <= 4_000_000 -> x * 4_000_000 + y
    _x -> nil
  end
end)
|> IO.inspect()
