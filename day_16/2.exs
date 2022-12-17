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

{[{"AA", "AA", goals, 0, 0, 0, 0, 0, 0}], 0}
|> Stream.iterate(fn {in_progress, done} ->
  {in_progress, new_done} =
    in_progress
    |> Enum.flat_map(fn {current, ecurrent, goals, time, released, total, etime, ereleased,
                         etotal} ->
      my_goals =
        goals
        |> Enum.map(fn goal -> {goal, get_in(tunnels, [current, goal])} end)
        |> Enum.reject(fn {_goal, steps} -> time + steps + 1 > 26 end)

      e_goals =
        goals
        |> Enum.map(fn goal -> {goal, get_in(tunnels, [ecurrent, goal])} end)
        |> Enum.reject(fn {_goal, steps} -> etime + steps + 1 > 26 end)

      if length(e_goals) == 0 or (time <= etime and length(my_goals) > 0) do
        Enum.map(my_goals, fn {goal, steps} ->
          {
            goal,
            ecurrent,
            List.delete(goals, goal),
            time + steps + 1,
            released + Map.fetch!(valves, goal),
            total + released * (steps + 1),
            etime,
            ereleased,
            etotal
          }
        end)
      else
        Enum.map(e_goals, fn {goal, steps} ->
          {
            current,
            goal,
            List.delete(goals, goal),
            time,
            released,
            total,
            etime + steps + 1,
            ereleased + Map.fetch!(valves, goal),
            etotal + ereleased * (steps + 1)
          }
        end)
      end
    end)
    |> Enum.split_with(fn {current, ecurrent, goals, time, _released, _total, etime, _ereleased,
                           _etotal} ->
      my_goals =
        goals
        |> Enum.map(fn goal -> {goal, get_in(tunnels, [current, goal])} end)
        |> Enum.any?(fn {_goal, steps} -> time + steps + 1 <= 26 end)

      e_goals =
        goals
        |> Enum.map(fn goal -> {goal, get_in(tunnels, [ecurrent, goal])} end)
        |> Enum.any?(fn {_goal, steps} -> etime + steps + 1 <= 26 end)

      my_goals or e_goals
    end)

  {
    in_progress,
    Enum.max([
      done
      | Enum.map(new_done, fn {_current, _ecurrent, _goals, time, released, total, etime,
                               ereleased, etotal} ->
          (26 - time) * released + total + (26 - etime) * ereleased + etotal
        end)
    ])
  }
end)
|> Enum.find(fn {in_progress, _done} -> in_progress == [] end)
|> elem(1)
|> IO.inspect()
