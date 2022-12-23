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

      Map.put(expressions, name, "#{left} #{op} #{right}")
    end
  end)

:digraph_utils.topsort(monkeys)
|> Enum.reduce(%{}, fn monkey, answers ->
  expression = Map.fetch!(expressions, monkey)

  if is_integer(expression) do
    Map.put(answers, String.to_atom(monkey), expression)
  else
    {answer, _binding} = Code.eval_string(expression, Enum.to_list(answers))
    Map.put(answers, String.to_atom(monkey), answer)
  end
end)
|> Map.fetch!(:root)
|> trunc()
|> IO.inspect()
