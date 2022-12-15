{sensors, occupied} =
  IO.stream()
  |> Stream.map(&String.trim/1)
  |> Enum.reduce({[], MapSet.new()}, fn line, {sensors, occupied} ->
    [x1, y1, x2, y2] =
      Regex.scan(~r{-?\d+}, line)
      |> List.flatten()
      |> Enum.map(&String.to_integer/1)

    {
      [{{x1, y1}, abs(x1 - x2) + abs(y1 - y2)} | sensors],
      occupied
      |> MapSet.put({x1, y1})
      |> MapSet.put({x2, y2})
    }
  end)

min_x = sensors |> Enum.map(fn {{x, _y}, radius} -> x - radius end) |> Enum.min()
max_x = sensors |> Enum.map(fn {{x, _y}, radius} -> x + radius end) |> Enum.max()

min_x..max_x
|> Enum.count(fn x ->
  not MapSet.member?(occupied, {x, 2_000_000}) and
    Enum.any?(sensors, fn {{sx, sy}, sradius} ->
      abs(sx - x) + abs(sy - 2_000_000) <= sradius
    end)
end)
|> IO.inspect()
