[drawing, moves] =
  IO.stream()
  |> Stream.map(&String.trim_trailing/1)
  |> Enum.chunk_while(
    [],
    fn line, group ->
      if line == "" do
        {:cont, Enum.reverse(group), []}
      else
        {:cont, [line | group]}
      end
    end,
    fn group ->
      {:cont, Enum.reverse(group), []}
    end
  )

stack_count =
  drawing
  |> Enum.reverse()
  |> hd()
  |> String.split(" ")
  |> List.last()
  |> String.to_integer()

stacks =
  drawing
  |> Enum.reverse()
  |> Enum.drop(1)
  |> Enum.map(fn row ->
    Enum.map(0..(stack_count - 1), &String.slice(row, 4 * &1 + 1, 1))
  end)
  |> Enum.reduce(%{}, fn crates, stacks ->
    crates
    |> Enum.with_index()
    |> Enum.reduce(stacks, fn
      {"", _i}, stacks ->
        stacks

      {" ", _i}, stacks ->
        stacks

      {crate, i}, stacks ->
        Map.update(stacks, i + 1, [crate], &[crate | &1])
    end)
  end)

moves
|> Enum.reduce(stacks, fn move, stacks ->
  %{"count" => count, "from_i" => from_i, "to_i" => to_i} =
    ~r{move (?<count>\d+) from (?<from_i>\d+) to (?<to_i>\d+)}
    |> Regex.named_captures(move)
    |> Map.new(fn {field, n} -> {field, String.to_integer(n)} end)

  from = Map.fetch!(stacks, from_i)
  moved = from |> Enum.take(count) |> Enum.reverse()

  stacks
  |> Map.put(from_i, Enum.drop(from, count))
  |> Map.update(to_i, moved, fn to -> moved ++ to end)
end)
|> Enum.sort()
|> Enum.map(fn {_i, crates} ->
  List.first(crates)
end)
|> Enum.join("")
|> IO.puts()
