monkeys =
  IO.stream()
  |> Stream.map(&String.trim/1)
  |> Enum.reduce([], fn
    "Monkey " <> name, monkeys ->
      name = name |> String.slice(0..-2) |> String.to_integer()
      [%{name: name, inspections: 0} | monkeys]

    "Starting items: " <> items, [monkey | rest] ->
      items = items |> String.split(", ") |> Enum.map(&String.to_integer/1)
      monkey = Map.put(monkey, :items, items)
      [monkey | rest]

    "Operation: new = " <> operation, [monkey | rest] ->
      monkey = Map.put(monkey, :operation, operation)
      [monkey | rest]

    "Test: divisible by " <> test, [monkey | rest] ->
      test = String.to_integer(test)
      monkey = Map.put(monkey, :test, test)
      [monkey | rest]

    "If true: throw to monkey " <> name, [monkey | rest] ->
      name = String.to_integer(name)
      monkey = Map.put(monkey, true, name)
      [monkey | rest]

    "If false: throw to monkey " <> name, [monkey | rest] ->
      name = String.to_integer(name)
      monkey = Map.put(monkey, false, name)
      [monkey | rest]

    "", monkeys ->
      monkeys
  end)

max_worry =
  monkeys
  |> Enum.map(fn monkey -> monkey.test end)
  |> Enum.product()

monkeys
|> Map.new(fn monkey -> Map.pop!(monkey, :name) end)
|> Stream.iterate(fn
  monkeys when is_map(monkeys) ->
    {monkeys |> Map.keys() |> Enum.sort(), monkeys}

  {[current | next], monkeys} ->
    monkey = Map.fetch!(monkeys, current)

    monkeys =
      monkey.items
      |> Enum.reduce(monkeys, fn item, monkeys ->
        new =
          monkey.operation
          |> Code.eval_string(old: item)
          |> elem(0)
          |> rem(max_worry)

        receiver = Map.fetch!(monkey, rem(new, monkey.test) == 0)

        update_in(monkeys, [receiver, :items], fn items ->
          items ++ [new]
        end)
      end)
      |> Map.put(
        current,
        Map.merge(monkey, %{items: [], inspections: monkey.inspections + length(monkey.items)})
      )

    {next ++ [current], monkeys}
end)
|> Stream.drop(1)
|> Stream.filter(fn {order, _monkeys} -> hd(order) == 0 end)
|> Stream.drop(10_000)
|> Enum.take(1)
|> hd()
|> elem(1)
|> Enum.map(fn {_name, monkey} -> monkey.inspections end)
|> Enum.sort(:desc)
|> Enum.take(2)
|> Enum.product()
|> IO.inspect()
