IO.stream()
|> Stream.map(&String.trim/1)
|> Stream.chunk_while(
  [],
  fn line, snacks ->
    if line == "" do
      {:cont, Enum.reverse(snacks), []}
    else
      {:cont, [line | snacks]}
    end
  end,
  fn snacks ->
    {:cont, Enum.reverse(snacks), []}
  end
)
|> Enum.map(fn snacks ->
  snacks
  |> Enum.map(&String.to_integer/1)
  |> Enum.sum()
end)
|> Enum.sort(:desc)
|> Enum.take(3)
|> Enum.sum()
|> IO.inspect()
