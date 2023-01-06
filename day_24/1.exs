{width, height, entrance, {exit_x, exit_y} = exit, blizzards} =
  IO.stream()
  |> Stream.map(&String.trim/1)
  |> Stream.with_index(-1)
  |> Enum.reduce({nil, nil, nil, nil, []}, fn
    {line, -1}, {nil, nil, nil, nil, []} ->
      size = String.length(line)

      {
        size - 2,
        nil,
        {Enum.find(0..(size - 1), &(String.at(line, &1) == ".")) - 1, -1},
        nil,
        []
      }

    {line, y}, {width, height, entrance, exit, blizzards} ->
      if line |> String.graphemes() |> Enum.count(&(&1 == "#")) > 2 do
        size = String.length(line)

        {
          width,
          y,
          entrance,
          {Enum.find(0..(size - 1), &(String.at(line, &1) == ".")) - 1, y},
          blizzards
        }
      else
        blizzards =
          line
          |> String.slice(1..-2)
          |> String.graphemes()
          |> Enum.with_index()
          |> Enum.reduce(blizzards, fn
            {".", _x}, blizzards ->
              blizzards

            {">", x}, blizzards ->
              [fn minute, _height -> {rem(x + minute, width), y} end | blizzards]

            {"v", x}, blizzards ->
              [fn minute, height -> {x, rem(y + minute, height)} end | blizzards]

            {"<", x}, blizzards ->
              [
                fn minute, _height ->
                  case rem(x - minute, width) do
                    offset when offset < 0 ->
                      {width + offset, y}

                    offset ->
                      {offset, y}
                  end
                end
                | blizzards
              ]

            {"^", x}, blizzards ->
              [
                fn minute, height ->
                  case rem(y - minute, height) do
                    offset when offset < 0 ->
                      {x, height + offset}

                    offset ->
                      {x, offset}
                  end
                end
                | blizzards
              ]
          end)

        {width, height, entrance, exit, blizzards}
      end
  end)

{:gb_sets.singleton({0, [entrance]}), MapSet.new(), %{}}
|> Stream.iterate(fn {paths, seen, blizzards_by_minute} ->
  {{_f, [{x, y} | _rest] = previous}, paths} = :gb_sets.take_smallest(paths)
  minute = length(previous)
  next_minute = minute + 1

  blizzards_by_minute =
    Map.put_new_lazy(blizzards_by_minute, minute, fn ->
      MapSet.new(blizzards, fn blizzard -> blizzard.(minute, height) end)
    end)

  blocked = Map.fetch!(blizzards_by_minute, minute)

  moves =
    Enum.reject([{x, y - 1}, {x, y + 1}, {x - 1, y}, {x + 1, y}, {x, y}], fn {x, y} = xy ->
      xy != entrance and xy != exit and
        (x < 0 or x >= width or
           y < 0 or y >= height or
           MapSet.member?(blocked, xy) or
           MapSet.member?(seen, {next_minute, xy}))
    end)

  seen = Enum.reduce(moves, seen, fn xy, seen -> MapSet.put(seen, {next_minute, xy}) end)

  paths =
    moves
    |> Enum.map(fn xy ->
      path = [xy | previous]
      g = next_minute
      h = abs(x - exit_x) + abs(y - exit_y)
      f = g + h
      {f, path}
    end)
    |> Enum.reduce(paths, fn f_and_path, paths -> :gb_sets.add(f_and_path, paths) end)

  {paths, seen, blizzards_by_minute}
end)
|> Enum.find(fn {paths, _seen, _blizzards_by_minute} ->
  paths |> :gb_sets.smallest() |> elem(1) |> hd() == exit
end)
|> elem(0)
|> :gb_sets.smallest()
|> elem(1)
|> Enum.reverse()
|> length()
|> Kernel.-(1)
|> IO.inspect()
