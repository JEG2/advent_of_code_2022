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

cube_size =
  map
  |> Map.keys()
  |> Enum.map(fn {_x, y} -> y end)
  |> Enum.max()
  |> Kernel.div(3)

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

  move, xy_and_facing ->
    Enum.reduce_while(1..move, xy_and_facing, fn _i, {{x, y}, facing} ->
      new_xy =
        case facing do
          0 -> {x + 1, y}
          1 -> {x, y + 1}
          2 -> {x - 1, y}
          3 -> {x, y - 1}
        end

      case Map.get(map, new_xy, :wrap) do
        true ->
          {:cont, {new_xy, facing}}

        false ->
          {:halt, {{x, y}, facing}}

        :wrap ->
          region =
            cond do
              x in 1..cube_size ->
                2

              x in (cube_size + 1)..(cube_size * 2) ->
                3

              x in (cube_size * 2 + 1)..(cube_size * 3) ->
                cond do
                  y in 1..cube_size -> 1
                  y in (cube_size + 1)..(cube_size * 2) -> 4
                  y in (cube_size * 2 + 1)..(cube_size * 3) -> 5
                end

              x in (cube_size * 3 + 1)..(cube_size * 4) ->
                6
            end

          {wrap_xy, wrap_facing} =
            case facing do
              0 ->
                case region do
                  1 -> {{cube_size * 4, cube_size * 3 + 1 - y}, 2}
                  4 -> {{cube_size * 4 + 1 - (y - cube_size), cube_size * 2 + 1}, 1}
                  6 -> {{cube_size * 3, cube_size + 1 - (y - cube_size * 2)}, 2}
                end

              1 ->
                case region do
                  2 -> {{cube_size * 3 + 1 - x, cube_size * 3}, 3}
                  3 -> {{cube_size * 2 + 1, cube_size * 3 + 1 - (x - cube_size)}, 0}
                  5 -> {{cube_size + 1 - (x - cube_size * 2), cube_size * 2}, 3}
                  6 -> {{1, cube_size * 2 + 1 - (x - cube_size * 3)}, 0}
                end

              2 ->
                case region do
                  2 -> {{cube_size * 4 + 1 - (y - cube_size), cube_size * 3}, 3}
                  1 -> {{y + cube_size, cube_size + 1}, 1}
                  5 -> {{cube_size * 2 + 1 - (y - cube_size * 2), cube_size * 2}, 3}
                end

              3 ->
                case region do
                  2 -> {{cube_size * 3 + 1 - x, 1}, 1}
                  3 -> {{cube_size * 2 + 1, x - cube_size}, 0}
                  1 -> {{cube_size + 1 - (x - cube_size * 2), cube_size + 1}, 1}
                  6 -> {{cube_size * 3, cube_size * 2 + 1 - (x - cube_size * 3)}, 2}
                end
            end

          if Map.get(map, wrap_xy) do
            {:cont, {wrap_xy, wrap_facing}}
          else
            {:halt, {{x, y}, facing}}
          end
      end
    end)
end)
|> then(fn {{x, y}, facing} ->
  if cube_size == 4 do
    x * 4 + y * 1000 + facing
  else
    ux = y - 50
    uy = 151 - (x - 50)
    ufacing = 3
    ux * 4 + uy * 1000 + ufacing
  end
end)
|> IO.inspect()
