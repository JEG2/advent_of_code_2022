elves =
  IO.stream()
  |> Stream.map(&String.trim/1)
  |> Stream.with_index()
  |> Enum.reduce(MapSet.new(), fn {line, y}, map ->
    line
    |> String.graphemes()
    |> Enum.with_index()
    |> Enum.reduce(map, fn
      {".", _x}, map ->
        map

      {"#", x}, map ->
        MapSet.put(map, {x, -y})
    end)
  end)

1..10
|> Enum.reduce(elves, fn round, elves ->
  {moving, staying} =
    elves
    |> Enum.map(fn {x, y} = elf ->
      {
        elf,
        %{
          nw: MapSet.member?(elves, {x - 1, y + 1}),
          n: MapSet.member?(elves, {x, y + 1}),
          ne: MapSet.member?(elves, {x + 1, y + 1}),
          e: MapSet.member?(elves, {x + 1, y}),
          se: MapSet.member?(elves, {x + 1, y - 1}),
          s: MapSet.member?(elves, {x, y - 1}),
          sw: MapSet.member?(elves, {x - 1, y - 1}),
          w: MapSet.member?(elves, {x - 1, y})
        }
      }
    end)
    |> Enum.split_with(fn {_elf, neighbors} ->
      Enum.any?(neighbors, fn {_xy, occupied?} -> occupied? end)
    end)

  proposals =
    Enum.reduce(moving, %{}, fn {{x, y} = elf, neighbors}, proposals ->
      [
        {~w[nw n ne]a, {x, y + 1}},
        {~w[sw s se]a, {x, y - 1}},
        {~w[nw w sw]a, {x - 1, y}},
        {~w[ne e se]a, {x + 1, y}}
      ]
      |> Stream.cycle()
      |> Stream.drop(rem(round - 1, 4))
      |> Stream.take(4)
      |> Enum.find({[], elf}, fn {checks, _move} ->
        not Enum.any?(checks, fn direction -> Map.fetch!(neighbors, direction) end)
      end)
      |> elem(1)
      |> then(&Map.update(proposals, &1, [elf], fn proposed -> [elf | proposed] end))
    end)

  Enum.reduce(proposals, MapSet.new(staying, fn {elf, _neighbors} -> elf end), fn
    {move, [_elf]}, elves ->
      MapSet.put(elves, move)

    {_move, proposed}, elves ->
      MapSet.union(elves, MapSet.new(proposed))
  end)
end)
|> then(fn elves ->
  {min_x, max_x} = elves |> Enum.map(fn {x, _y} -> x end) |> Enum.min_max()
  {min_y, max_y} = elves |> Enum.map(fn {_x, y} -> y end) |> Enum.min_max()
  (abs(min_x - max_x) + 1) * (abs(min_y - max_y) + 1) - MapSet.size(elves)
end)
|> IO.inspect()
