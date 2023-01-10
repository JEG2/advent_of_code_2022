#     AAAABBBB
#     AAAABBBB
#     AAAABBBB
#     AAAABBBB
#     CCCC
#     CCCC
#     CCCC
#     CCCC
# DDDDEEEE
# DDDDEEEE
# DDDDEEEE
# DDDDEEEE
# FFFF
# FFFF
# FFFF
# FFFF
input =
  IO.stream()
  |> Enum.to_list()

Enum.each(0..151, fn
  y when y in 0..49 ->
    IO.puts([String.duplicate(" ", 100), input |> Enum.at(y) |> String.slice(50..99)])

  y when y in 50..99 ->
    left = Enum.map(0..49, fn x -> input |> Enum.at(199 - x) |> String.at(y - 50) end)
    middle = Enum.map(50..99, fn x -> input |> Enum.at(149 - (x - 50)) |> String.at(y - 50) end)
    IO.puts([left, middle, input |> Enum.at(y) |> String.slice(50..99)])

  y when y in 100..149 ->
    right = Enum.map(0..49, fn x -> input |> Enum.at(49 - (y - 100)) |> String.at(149 - x) end)
    IO.puts([String.duplicate(" ", 100), input |> Enum.at(y) |> String.slice(50..99), right])

  y when y in 150..151 ->
    IO.puts(Enum.at(input, y + 50))
end)
