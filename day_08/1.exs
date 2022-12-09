forest =
  IO.stream()
  |> Stream.map(&String.trim/1)
  |> Stream.map(fn row ->
    row
    |> String.split("", trim: true)
    |> Enum.map(&String.to_integer/1)
  end)
  |> Stream.with_index()
  |> Enum.reduce(%{}, fn {row, y}, forest ->
    row
    |> Enum.with_index()
    |> Enum.reduce(forest, fn {tree, x}, forest ->
      Map.put_new(forest, {x, y}, tree)
    end)
  end)

coords = Map.keys(forest)
max_x = coords |> Enum.map(fn {x, _y} -> x end) |> Enum.max()
max_y = coords |> Enum.map(fn {_x, y} -> y end) |> Enum.max()

visible =
  Enum.reduce(0..max_y//1, MapSet.new(), fn y, visible ->
    {_largest, visible} =
      Enum.reduce_while(0..max_x//1, {-1, visible}, fn x, {largest, visible} ->
        tree = Map.fetch!(forest, {x, y})

        {largest, visible} =
          if tree > largest do
            {tree, MapSet.put(visible, {x, y})}
          else
            {largest, visible}
          end

        if tree == 9 do
          {:halt, {largest, visible}}
        else
          {:cont, {largest, visible}}
        end
      end)

    {_largest, visible} =
      Enum.reduce_while(max_x..0//-1, {-1, visible}, fn x, {largest, visible} ->
        tree = Map.fetch!(forest, {x, y})

        {largest, visible} =
          if tree > largest do
            {tree, MapSet.put(visible, {x, y})}
          else
            {largest, visible}
          end

        if tree == 9 do
          {:halt, {largest, visible}}
        else
          {:cont, {largest, visible}}
        end
      end)

    visible
  end)

Enum.reduce(0..max_x//1, visible, fn x, visible ->
  {_largest, visible} =
    Enum.reduce_while(0..max_y//1, {-1, visible}, fn y, {largest, visible} ->
      tree = Map.fetch!(forest, {x, y})

      {largest, visible} =
        if tree > largest do
          {tree, MapSet.put(visible, {x, y})}
        else
          {largest, visible}
        end

      if tree == 9 do
        {:halt, {largest, visible}}
      else
        {:cont, {largest, visible}}
      end
    end)

  {_largest, visible} =
    Enum.reduce_while(max_y..0//-1, {-1, visible}, fn y, {largest, visible} ->
      tree = Map.fetch!(forest, {x, y})

      {largest, visible} =
        if tree > largest do
          {tree, MapSet.put(visible, {x, y})}
        else
          {largest, visible}
        end

      if tree == 9 do
        {:halt, {largest, visible}}
      else
        {:cont, {largest, visible}}
      end
    end)

  visible
end)
|> MapSet.size()
|> IO.inspect()
