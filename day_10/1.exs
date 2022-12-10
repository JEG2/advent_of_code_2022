process = fn
  "noop", x -> {0, x}
  "addx " <> v, x -> {1, x + String.to_integer(v)}
end

IO.stream()
|> Enum.map(&String.trim/1)
|> Stream.iterate(fn
  [instruction | rest] ->
    {1, 1, process.(instruction, 1), rest}

  {cycle, _x, {0, new_x}, instructions} ->
    {
      cycle + 1,
      new_x,
      process.(List.first(instructions) || "noop", new_x),
      Enum.drop(instructions, 1)
    }

  {cycle, x, {delay, new_x}, instructions} ->
    {cycle + 1, x, {delay - 1, new_x}, instructions}
end)
|> Stream.drop(1)
|> Stream.take(220)
|> Stream.map(fn {cycle, x, _delay_and_new_x, _instructions} -> {cycle, x} end)
|> Stream.filter(fn {cycle, _x} -> cycle in [20, 60, 100, 140, 180, 220] end)
|> Stream.map(fn {cycle, x} -> cycle * x end)
|> Enum.sum()
|> IO.inspect()
