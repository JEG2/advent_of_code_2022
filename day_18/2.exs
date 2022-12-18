scan =
  IO.stream()
  |> Stream.map(&String.trim/1)
  |> Enum.into(MapSet.new(), fn xyz ->
    xyz
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
    |> List.to_tuple()
  end)

{min_x, max_x} = scan |> Enum.map(fn {x, _y, _z} -> x end) |> Enum.min_max()
{min_y, max_y} = scan |> Enum.map(fn {_x, y, _z} -> y end) |> Enum.min_max()
{min_z, max_z} = scan |> Enum.map(fn {_x, _y, z} -> z end) |> Enum.min_max()

# Enum.each(min_z..max_z, fn z ->
#   IO.write(IO.ANSI.clear())
#   IO.puts(z)

#   Enum.each(min_y..max_y, fn y ->
#     min_x..max_x
#     |> Enum.map(fn x ->
#       if MapSet.member?(scan, {x, y, z}) do
#         "#"
#       else
#         "."
#       end
#     end)
#     |> Enum.join("")
#     |> IO.puts()
#   end)

#   Process.sleep(1_000)
# end)

water =
  {[{min_x - 1, min_y - 1, min_z - 1}], MapSet.new()}
  |> Stream.iterate(fn {edge, filled} ->
    {
      edge
      |> Enum.flat_map(fn {x, y, z} ->
        [
          {1, 0, 0},
          {-1, 0, 0},
          {0, 1, 0},
          {0, -1, 0},
          {0, 0, 1},
          {0, 0, -1}
        ]
        |> Enum.map(fn {xo, yo, zo} -> {x + xo, y + yo, z + zo} end)
        |> Enum.filter(fn xyz ->
          not MapSet.member?(scan, xyz) and
            not MapSet.member?(filled, xyz) and
            x in (min_x - 1)..(max_x + 1) and
            y in (min_y - 1)..(max_y + 1) and
            z in (min_z - 1)..(max_z + 1)
        end)
      end)
      |> Enum.uniq(),
      Enum.reduce(edge, filled, fn xyz, filled ->
        MapSet.put(filled, xyz)
      end)
    }
  end)
  |> Enum.find(fn {edge, _filled} -> edge == [] end)
  |> elem(1)

# Enum.each(min_z..max_z, fn z ->
#   IO.write(IO.ANSI.clear())
#   IO.puts(z)

#   Enum.each(min_y..max_y, fn y ->
#     min_x..max_x
#     |> Enum.map(fn x ->
#       if MapSet.member?(water, {x, y, z}) do
#         "~"
#       else
#         if MapSet.member?(scan, {x, y, z}) do
#           "#"
#         else
#           "."
#         end
#       end
#     end)
#     |> Enum.join("")
#     |> IO.puts()
#   end)

#   Process.sleep(1_000)
# end)

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
    MapSet.member?(water, {x + xo, y + yo, z + zo})
  end)
end)
|> Enum.sum()
|> IO.inspect()
