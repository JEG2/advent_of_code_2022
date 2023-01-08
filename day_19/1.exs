limit = 24

blueprints =
  IO.stream()
  |> Stream.map(&String.trim/1)
  |> Enum.reduce(%{}, fn line, blueprints ->
    %{"number" => number, "costs" => costs} =
      Regex.named_captures(~r{\ABlueprint\s(?<number>\d+):\s+(?<costs>.+)\z}, line)

    robots =
      Regex.scan(~r{Each (\w+) robot costs ([^\.]+).}, costs)
      |> Enum.map(fn [_match, type, resources] ->
        {
          type,
          Regex.scan(~r{(\d+) (\w+)}, resources)
          |> Enum.map(fn [_match, count, resource] ->
            {resource, String.to_integer(count)}
          end)
          |> Map.new()
        }
      end)
      |> Map.new()

    Map.put(blueprints, String.to_integer(number), robots)
  end)

blueprints
|> Enum.map(fn {number, costs} ->
  max_resource_needs =
    costs
    |> Map.values()
    |> Enum.flat_map(&Enum.to_list/1)
    |> Enum.group_by(&elem(&1, 0), &elem(&1, 1))
    |> Map.new(fn {type, costs} -> {type, Enum.max(costs)} end)

  quality_level =
    {[
       {
         limit,
         %{"ore" => 1, "clay" => 0, "obsidian" => 0, "geode" => 0},
         %{"ore" => 0, "clay" => 0, "obsidian" => 0, "geode" => 0}
       }
     ], 0}
    |> Stream.iterate(fn {[{remaining, production, resources} | builds], best} ->
      possible =
        Enum.filter(costs, fn {type, needed} ->
          last_useful_offset =
            case type do
              "geode" -> -1
              "obsidian" -> -3
              "clay" -> -5
              "ore" -> -1
            end

          Map.fetch!(production, type) < Map.get(max_resource_needs, type, limit) and
            Enum.all?(needed, fn {resource, cost} ->
              Map.fetch!(resources, resource) +
                Map.fetch!(production, resource) *
                  (remaining + last_useful_offset) >= cost
            end)
        end)

      if possible == [] do
        {
          builds,
          max(Map.fetch!(resources, "geode") + Map.fetch!(production, "geode") * remaining, best)
        }
      else
        next =
          possible
          |> Enum.map(fn {producing, needed} ->
            passed =
              needed
              |> Enum.map(fn {type, cost} ->
                max(
                  0,
                  ceil(
                    (cost - Map.fetch!(resources, type)) /
                      Map.fetch!(production, type)
                  )
                )
              end)
              |> Enum.max()
              |> Kernel.+(1)

            {
              remaining - passed,
              Map.update!(production, producing, &(&1 + 1)),
              Map.new(resources, fn {type, have} ->
                {type, have + Map.fetch!(production, type) * passed - Map.get(needed, type, 0)}
              end)
            }
          end)
          |> Enum.reject(fn {remaining, production, resources} ->
            geode_production = Map.fetch!(production, "geode")

            potential =
              Enum.reduce(1..remaining, Map.fetch!(resources, "geode"), fn i, total ->
                total + geode_production + i
              end)

            potential <= best
          end)

        {next ++ builds, best}
      end
    end)
    |> Enum.find(fn {builds, _best} -> builds == [] end)
    |> elem(1)

  number * quality_level
end)
|> Enum.sum()
|> IO.inspect()
