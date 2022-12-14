{e, hills} =
  IO.stream()
  |> Stream.map(&String.trim/1)
  |> Stream.with_index()
  |> Enum.reduce({nil, %{}}, fn {row, y}, {e, hills} ->
    row
    |> String.split("", trim: true)
    |> Enum.with_index()
    |> Enum.reduce({e, hills}, fn {height, x}, {e, hills} ->
      case height do
        "S" ->
          {
            e,
            Map.put(hills, {x, y}, 0)
          }

        "E" ->
          {
            {x, y},
            Map.put(hills, {x, y}, 25)
          }

        <<ascii>> ->
          {
            e,
            Map.put(hills, {x, y}, ascii - ?a)
          }
      end
    end)
  end)

max_x = hills |> Enum.map(fn {{x, _y}, _height} -> x end) |> Enum.max()
max_y = hills |> Enum.map(fn {{_x, y}, _height} -> y end) |> Enum.max()

possible_starts =
  hills
  |> Enum.filter(fn {_xy, height} -> height == 0 end)
  |> Enum.map(fn {xy, _height} -> xy end)

{
  [e],
  1,
  Map.new(hills, fn {xy, _height} -> {xy, if(xy == e, do: 0, else: nil)} end)
}
|> Stream.iterate(fn {previous_locations, count, steps} ->
  current_locations =
    previous_locations
    |> Enum.flat_map(fn {x, y} ->
      height = Map.fetch!(hills, {x, y})

      [
        {x, y + 1},
        {x, y - 1},
        {x - 1, y},
        {x + 1, y}
      ]
      |> Enum.reject(fn {x, y} = xy ->
        x < 0 or
          x > max_x or
          y < 0 or
          y > max_y or
          Map.fetch!(hills, xy) < height - 1 or
          not is_nil(Map.fetch!(steps, xy))
      end)
    end)
    |> Enum.uniq()

  {
    current_locations,
    count + 1,
    Enum.into(current_locations, steps, fn xy -> {xy, count} end)
  }
end)
|> Enum.find(fn {_previous_locations, _count, steps} ->
  Enum.any?(possible_starts, fn xy -> not is_nil(Map.fetch!(steps, xy)) end)
end)
|> elem(2)
|> Enum.find(fn {xy, count} ->
  xy in possible_starts and not is_nil(count)
end)
|> elem(1)
|> IO.inspect()
