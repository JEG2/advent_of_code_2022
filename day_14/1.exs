IO.stream()
|> Stream.map(&String.trim/1)
|> Enum.reduce(%{}, fn path, cave ->
  path
  |> String.split(" -> ")
  |> Enum.map(fn xy ->
    xy
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
    |> List.to_tuple()
  end)
  |> Enum.chunk_every(2, 1, :discard)
  |> Enum.map(fn
    [{x, y1}, {x, y2}] ->
      {Stream.cycle([x]), y1..y2//-trunc((y1 - y2) / abs(y1 - y2))}

    [{x1, y}, {x2, y}] ->
      {x1..x2//-trunc((x1 - x2) / abs(x1 - x2)), Stream.cycle([y])}
  end)
  |> Enum.flat_map(fn {xs, ys} ->
    Enum.zip(xs, ys)
  end)
  |> Enum.reduce(cave, fn xy, cave ->
    Map.put(cave, xy, :rock)
  end)
end)
|> IO.inspect()
