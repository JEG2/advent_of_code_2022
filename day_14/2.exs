cave =
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

max_y = cave |> Enum.map(fn {{_x, y}, :rock} -> y end) |> Enum.max()

cave
|> Stream.iterate(fn cave ->
  {500, 0}
  |> Stream.iterate(fn {x, y} ->
    cond do
      y == max_y + 1 ->
        {:cont, Map.put(cave, {x, y}, :sand)}

      is_nil(cave[{x, y + 1}]) ->
        {x, y + 1}

      is_nil(cave[{x - 1, y + 1}]) ->
        {x - 1, y + 1}

      is_nil(cave[{x + 1, y + 1}]) ->
        {x + 1, y + 1}

      true ->
        if x == 500 and y == 0 do
          {:halt, Map.put(cave, {x, y}, :sand)}
        else
          {:cont, Map.put(cave, {x, y}, :sand)}
        end
    end
  end)
  |> Enum.find(
    &match?({cont_or_halt, cave} when cont_or_halt in ~w[cont halt]a and is_map(cave), &1)
  )
  |> case do
    {:cont, cave} ->
      cave

    {:halt, cave} ->
      {:halt, cave}
  end
end)
|> Enum.find(&match?({:halt, cave} when is_map(cave), &1))
|> elem(1)
|> Enum.count(fn {_xy, contents} -> contents == :sand end)
|> IO.inspect()
