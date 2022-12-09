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

for y <- 0..max_y, x <- 0..max_x do
  treehouse = Map.fetch!(forest, {x, y})

  right =
    Enum.reduce_while((x + 1)..max_x//1, 0, fn x, trees ->
      tree = Map.fetch!(forest, {x, y})

      if tree >= treehouse do
        {:halt, trees + 1}
      else
        {:cont, trees + 1}
      end
    end)

  left =
    Enum.reduce_while((x - 1)..0//-1, 0, fn x, trees ->
      tree = Map.fetch!(forest, {x, y})

      if tree >= treehouse do
        {:halt, trees + 1}
      else
        {:cont, trees + 1}
      end
    end)

  down =
    Enum.reduce_while((y + 1)..max_y//1, 0, fn y, trees ->
      tree = Map.fetch!(forest, {x, y})

      if tree >= treehouse do
        {:halt, trees + 1}
      else
        {:cont, trees + 1}
      end
    end)

  up =
    Enum.reduce_while((y - 1)..0//-1, 0, fn y, trees ->
      tree = Map.fetch!(forest, {x, y})

      if tree >= treehouse do
        {:halt, trees + 1}
      else
        {:cont, trees + 1}
      end
    end)

  left * right * down * up
end
|> Enum.max()
|> IO.inspect()
