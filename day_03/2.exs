IO.stream()
|> Stream.map(&String.trim/1)
|> Stream.chunk_every(3)
|> Stream.map(fn [rucksack_1, rucksack_2, rucksack_3] ->
  rucksack_1
  |> String.graphemes()
  |> Enum.find(fn item ->
    String.contains?(rucksack_2, item) and String.contains?(rucksack_3, item)
  end)
end)
|> Stream.map(fn
  <<ascii>> when ascii < ?a ->
    ascii - 38

  <<ascii>> ->
    ascii - 96
end)
|> Enum.sum()
|> IO.inspect()
