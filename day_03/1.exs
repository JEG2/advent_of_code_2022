IO.stream()
|> Stream.map(&String.trim/1)
|> Stream.map(fn rucksack ->
  half = trunc(String.length(rucksack) / 2)
  compartment_1 = String.slice(rucksack, 0, half)
  compartment_2 = String.slice(rucksack, half, half)
  compartment_1
  |> String.graphemes
  |> Enum.find(fn item -> String.contains?(compartment_2, item) end)
end)
|> Stream.map(fn
  <<ascii>> when ascii < ?a ->
    ascii - 38

  <<ascii>> ->
    ascii - 96
end)
|> Enum.sum()
|> IO.inspect()
