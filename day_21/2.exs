monkeys = :digraph.new([:acyclic])

expressions =
  IO.stream()
  |> Stream.map(&String.trim/1)
  |> Enum.reduce(%{}, fn line, expressions ->
    if String.match?(line, ~r{\d}) do
      [name, number] = String.split(line, ": ")
      :digraph.add_vertex(monkeys, name)
      Map.put(expressions, name, String.to_integer(number))
    else
      %{"name" => name, "left" => left, "op" => op, "right" => right} =
        Regex.named_captures(~r{\A(?<name>\w+): (?<left>\w+) (?<op>\S) (?<right>\w+)\z}, line)

      :digraph.add_vertex(monkeys, name)
      :digraph.add_vertex(monkeys, left)
      :digraph.add_vertex(monkeys, right)
      :digraph.add_edge(monkeys, left, name)
      :digraph.add_edge(monkeys, right, name)

      if name == "root" do
        Map.put(expressions, name, {:root, left, right})
      else
        Map.put(expressions, name, {String.to_atom(op), left, right})
      end
    end
  end)

order = :digraph_utils.topsort(monkeys)
humn_i = Enum.find_index(order, fn name -> name == "humn" end)

{unchanged, changed} = Enum.split(order, humn_i)

unchanged_answers =
  Enum.reduce(unchanged, %{}, fn monkey, answers ->
    expression = Map.fetch!(expressions, monkey)

    if is_integer(expression) do
      Map.put(answers, monkey, expression)
    else
      left = Map.fetch!(answers, elem(expression, 1))
      right = Map.fetch!(answers, elem(expression, 2))

      answer = apply(Kernel, elem(expression, 0), [left, right])
      Map.put(answers, monkey, answer)
    end
  end)

0
|> Stream.iterate(fn i -> i + 1 end)
|> Stream.map(fn humn ->
  changed
  |> Enum.drop(1)
  |> Enum.reduce(Map.put(unchanged_answers, "humn", humn), fn monkey, answers ->
    expression = Map.fetch!(expressions, monkey)

    if is_integer(expression) do
      Map.put(answers, monkey, expression)
    else
      left = Map.fetch!(answers, elem(expression, 1))
      right = Map.fetch!(answers, elem(expression, 2))

      if monkey == "root" do
        Map.put(answers, monkey, {left == trunc(left), humn, right - left})
      else
        answer = apply(Kernel, elem(expression, 0), [left, right])
        Map.put(answers, monkey, answer)
      end
    end
  end)
  |> Map.fetch!("root")
end)
|> Stream.filter(fn {even?, _humn, _diff} -> even? end)
|> Enum.take(2)
|> then(fn [{true, humn1, diff1}, {true, humn2, diff2}] ->
  trunc(humn2 + (humn2 - humn1) * -diff2 / (diff2 - diff1))
end)
|> IO.inspect()
