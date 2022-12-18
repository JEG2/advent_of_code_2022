scan =
  IO.stream()
  |> Stream.map(&String.trim/1)
  |> Enum.into(MapSet.new(), fn xyz ->
    xyz
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
    |> List.to_tuple()
  end)

scan
|> Enum.map(fn {x, y, z} ->
  [
    {1, 0, 0},
    {-1, 0, 0},
    {0, 1, 0},
    {0, -1, 0},
    {0, 0, 1},
    {0, 0, -1}
  ]
  |> Enum.count(fn {xo, yo, zo} ->
    not MapSet.member?(scan, {x + xo, y + yo, z + zo})
  end)
end)
|> Enum.sum()
|> IO.inspect()
