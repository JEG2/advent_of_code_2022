{valves, tunnels} =
  IO.stream()
  |> Stream.map(&String.trim/1)
  |> Enum.reduce({%{}, %{}}, fn line, {valves, tunnels} ->
    %{"current" => current, "rate" => rate, "to" => to} =
      Regex.named_captures(
        ~r{\AValve (?<current>\w+) has flow rate=(?<rate>\d+); tunnels? leads? to valves? (?<to>.+)\z},
        line
      )

    rate = String.to_integer(rate)

    valves =
      if rate > 0 do
        Map.put(valves, current, rate)
      else
        valves
      end

    tunnels =
      Map.put(
        tunnels,
        current,
        to
        |> String.split(", ")
        |> Map.new(fn t -> {t, 1} end)
        |> Map.put(current, 0)
      )

    {valves, tunnels}
  end)

goals = Map.keys(valves)

tunnels =
  tunnels
  |> Map.new(fn {from, to} ->
    to =
      to
      |> Stream.iterate(fn to ->
        steps = to |> Map.values() |> Enum.max()

        froms =
          to
          |> Enum.filter(fn {_from, step} -> step == steps end)
          |> Enum.map(fn {from, _step} -> from end)
          |> Enum.uniq()

        tos =
          Enum.flat_map(froms, fn from ->
            tunnels
            |> Map.fetch!(from)
            |> Enum.filter(fn {_to, step} -> step == 1 end)
            |> Enum.map(fn {to, _step} -> to end)
            |> Enum.uniq()
          end)

        Enum.reduce(tos, to, fn next, to -> Map.put_new(to, next, steps + 1) end)
      end)
      |> Enum.find(fn to ->
        Enum.all?(goals, fn goal -> Map.has_key?(to, goal) end)
      end)

    {from, to}
  end)

{[{"AA", goals, 0, 0, 0}], []}
|> Stream.iterate(fn {in_progress, done} ->
  {in_progress, new_done} =
    in_progress
    |> Enum.flat_map(fn {current, goals, time, released, total} ->
      goals
      |> Enum.map(fn goal -> {goal, get_in(tunnels, [current, goal])} end)
      |> Enum.reject(fn {_goal, steps} -> time + steps + 1 > 30 end)
      |> Enum.map(fn {goal, steps} ->
        {
          goal,
          List.delete(goals, goal),
          time + steps + 1,
          released + Map.fetch!(valves, goal),
          total + released * (steps + 1)
        }
      end)
    end)
    |> Enum.split_with(fn {current, goals, time, _released, _total} ->
      goals
      |> Enum.map(fn goal -> {goal, get_in(tunnels, [current, goal])} end)
      |> Enum.any?(fn {_goal, steps} -> time + steps + 1 <= 30 end)
    end)

  {
    in_progress,
    done ++
      Enum.map(new_done, fn {_current, _goals, time, released, total} ->
        (30 - time) * released + total
      end)
  }
end)
|> Enum.find(fn {in_progress, _done} -> in_progress == [] end)
|> elem(1)
|> Enum.max()
|> IO.inspect()
