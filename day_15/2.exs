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

Enum.each(0..4_000_000, fn y ->
  IO.inspect(y)

  Enum.each(0..4_000_000, fn x ->
    if not MapSet.member?(occupied, {x, y}) and
         Enum.all?(sensors, fn {{sx, sy}, sradius} ->
           abs(sx - x) + abs(sy - y) > sradius
         end) do
      IO.inspect({x, y})
    end
  end)
end)
