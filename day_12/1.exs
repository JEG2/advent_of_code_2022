{s, e, hills} =
  IO.stream()
  |> Stream.map(&String.trim/1)
  |> Stream.with_index()
  |> Enum.reduce({nil, nil, %{}}, fn {row, y}, {s, e, hills} ->
    row
    |> String.split("", trim: true)
    |> Enum.with_index()
    |> Enum.reduce({s, e, hills}, fn {height, x}, {s, e, hills} ->
      case height do
        "S" ->
          {
            {x, y},
            e,
            Map.put(hills, {x, y}, 0)
          }

        "E" ->
          {
            s,
            {x, y},
            Map.put(hills, {x, y}, 25)
          }

        <<ascii>> ->
          {
            s,
            e,
            Map.put(hills, {x, y}, ascii - ?a)
          }
      end
    end)
  end)

max_x = hills |> Enum.map(fn {{x, _y}, _height} -> x end) |> Enum.max()
max_y = hills |> Enum.map(fn {{_x, y}, _height} -> y end) |> Enum.max()

{
  [s],
  1,
  Map.new(hills, fn {xy, _height} -> {xy, if(xy == s, do: 0, else: nil)} end)
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
          Map.fetch!(hills, xy) > height + 1 or
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
  not is_nil(Map.fetch!(steps, e))
end)
|> elem(2)
|> Map.fetch!(e)
|> IO.inspect()
