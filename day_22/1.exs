{map, path} =
  IO.stream()
  |> Stream.map(&String.trim_trailing/1)
  |> Stream.with_index(1)
  |> Enum.reduce({%{}, []}, fn
    {"", _y}, {map, path} ->
      {map, path}

    {<<first::binary-size(1), _rest::binary>> = line, _y}, {map, _path}
    when first in ~w[0 1 2 3 4 5 6 7 8 9 L R] ->
      {
        map,
        Regex.scan(~r{\d+|[LR]}, line)
        |> List.flatten()
        |> Enum.map(fn
          move when move in ~w[L R] ->
            move

          move ->
            String.to_integer(move)
        end)
      }

    {line, y}, {map, path} ->
      {
        line
        |> String.split("", trim: true)
        |> Enum.with_index(1)
        |> Enum.reduce(map, fn
          {" ", _x}, map ->
            map

          {tile, x}, map ->
            Map.put(map, {x, y}, tile == ".")
        end),
        path
      }
  end)

start_xy =
  map
  |> Map.keys()
  |> Enum.filter(fn {_x, y} -> y == 1 end)
  |> Enum.min_by(fn {x, _y} -> x end)

Enum.reduce(path, {start_xy, 0}, fn
  "L", {xy, 0} ->
    {xy, 3}

  "L", {xy, facing} ->
    {xy, facing - 1}

  "R", {xy, facing} ->
    {xy, rem(facing + 1, 4)}

  move, {xy, facing} ->
    {
      Enum.reduce_while(1..move, xy, fn _i, {x, y} ->
        new_xy =
          case facing do
            0 -> {x + 1, y}
            1 -> {x, y + 1}
            2 -> {x - 1, y}
            3 -> {x, y - 1}
          end

        case Map.get(map, new_xy, :wrap) do
          true ->
            {:cont, new_xy}

          false ->
            {:halt, {x, y}}

          :wrap ->
            wrap_xy =
              case facing do
                0 ->
                  map
                  |> Map.keys()
                  |> Enum.filter(fn {_x, other_y} -> other_y == y end)
                  |> Enum.min_by(fn {other_x, _y} -> other_x end)

                1 ->
                  map
                  |> Map.keys()
                  |> Enum.filter(fn {other_x, _y} -> other_x == x end)
                  |> Enum.min_by(fn {_x, other_y} -> other_y end)

                2 ->
                  map
                  |> Map.keys()
                  |> Enum.filter(fn {_x, other_y} -> other_y == y end)
                  |> Enum.max_by(fn {other_x, _y} -> other_x end)

                3 ->
                  map
                  |> Map.keys()
                  |> Enum.filter(fn {other_x, _y} -> other_x == x end)
                  |> Enum.max_by(fn {_x, other_y} -> other_y end)
              end

            if Map.get(map, wrap_xy) do
              {:cont, wrap_xy}
            else
              {:halt, {x, y}}
            end
        end
      end),
      facing
    }
end)
|> then(fn {{x, y}, facing} -> x * 4 + y * 1000 + facing end)
|> IO.inspect()
