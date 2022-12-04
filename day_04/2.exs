IO.stream()
|> Stream.map(&String.trim/1)
|> Stream.map(fn pair ->
  pair
  |> String.split(",")
  |> Enum.map(fn sections ->
    sections
    |> String.split("-")
    |> Enum.map(&String.to_integer/1)
    |> then(&apply(Range, :new, &1))
  end)
  |> List.to_tuple()
end)
|> Enum.count(fn {elf_1, elf_2} ->
  not Range.disjoint?(elf_1, elf_2)
end)
|> IO.inspect()
