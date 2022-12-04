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
  (elf_1.first >= elf_2.first and elf_1.last <= elf_2.last) or
    (elf_2.first >= elf_1.first and elf_2.last <= elf_1.last)
end)
|> IO.inspect()
