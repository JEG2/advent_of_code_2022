gasses =
  IO.read(:eof)
  |> String.trim()
  |> String.split("", trim: true)
  |> List.to_tuple()

{
  repeated_pieces,
  repeated_rows,
  prefix_pieces,
  prefix_rows,
  pieces_to_lines
} =
  %{
    rocks: {
      fn x, y -> [{x, y}, {x + 1, y}, {x + 2, y}, {x + 3, y}] end,
      fn x, y -> [{x + 1, y + 2}, {x, y + 1}, {x + 1, y + 1}, {x + 2, y + 1}, {x + 1, y}] end,
      fn x, y -> [{x + 2, y + 2}, {x + 2, y + 1}, {x, y}, {x + 1, y}, {x + 2, y}] end,
      fn x, y -> [{x, y + 3}, {x, y + 2}, {x, y + 1}, {x, y}] end,
      fn x, y -> [{x, y + 1}, {x + 1, y + 1}, {x, y}, {x + 1, y}] end
    },
    rock_index: 0,
    gasses: gasses,
    gas_index: 0,
    x: 2,
    y: 3,
    cycle: :push,
    chamber: MapSet.new(),
    at_rest: 0,
    heights: %{},
    pieces: %{}
  }
  |> Stream.iterate(fn
    %{cycle: :push} = state ->
      rock = elem(state.rocks, state.rock_index)

      push =
        case elem(state.gasses, state.gas_index) do
          "<" -> -1
          ">" -> 1
        end

      x = state.x + push

      valid? =
        Enum.all?(rock.(x, state.y), fn {x, _y} = xy ->
          x >= 0 and x < 7 and not MapSet.member?(state.chamber, xy)
        end)

      new_x =
        if valid? do
          x
        else
          state.x
        end

      %{
        state
        | gas_index: rem(state.gas_index + 1, tuple_size(state.gasses)),
          x: new_x,
          cycle: :fall
      }

    %{cycle: :fall} = state ->
      rock = elem(state.rocks, state.rock_index)

      y = state.y - 1

      valid? =
        Enum.all?(rock.(state.x, y), fn {_x, y} = xy ->
          y >= 0 and not MapSet.member?(state.chamber, xy)
        end)

      if valid? do
        %{
          state
          | y: y,
            cycle: :push
        }
      else
        chamber = Enum.into(rock.(state.x, state.y), state.chamber)
        max_y = chamber |> Enum.map(fn {_x, y} -> y end) |> Enum.max()

        %{
          state
          | rock_index: rem(state.rock_index + 1, tuple_size(state.rocks)),
            x: 2,
            y: max_y + 4,
            cycle: :push,
            chamber: chamber,
            at_rest: state.at_rest + 1,
            heights: Map.put(state.heights, max_y, state.at_rest + 1),
            pieces: Map.put(state.pieces, state.at_rest + 1, max_y)
        }
      end
  end)
  |> Stream.chunk_by(fn state -> state.at_rest end)
  |> Enum.find_value(fn [state | _dupes] ->
    max_y =
      state.chamber
      |> Enum.map(fn {_x, y} -> y end)
      |> Enum.max(fn -> 0 end)

    if max_y > 20 do
      Enum.find_value(10..trunc(max_y / 2)//1, fn rows ->
        dupe =
          max_y..(max_y - (rows - 1))//-1
          |> Stream.zip((max_y - rows)..(max_y - (rows * 2 - 1))//-1)
          |> Enum.all?(fn {upper_y, lower_y} ->
            upper =
              Enum.map(0..6//1, fn x ->
                if MapSet.member?(state.chamber, {x, upper_y}) do
                  "#"
                else
                  "."
                end
              end)

            lower =
              Enum.map(0..6//1, fn x ->
                if MapSet.member?(state.chamber, {x, lower_y}) do
                  "#"
                else
                  "."
                end
              end)

            upper == lower
          end)

        if dupe do
          total_pieces = Map.fetch!(state.heights, max_y)
          repeated_pieces = total_pieces - Map.fetch!(state.heights, max_y - rows)

          {
            repeated_pieces,
            rows,
            total_pieces - repeated_pieces * 2,
            max_y + 1 - rows * 2,
            state.pieces
          }
        else
          false
        end
      end)
    else
      false
    end
  end)

middle_and_suffix_pieces = 1_000_000_000_000 - prefix_pieces
middle_pieces = div(middle_and_suffix_pieces, repeated_pieces)
suffix_pieces = rem(middle_and_suffix_pieces, repeated_pieces)

suffix_rows =
  if suffix_pieces != 0 do
    pieces_to_lines
    |> Map.fetch!(suffix_pieces + prefix_pieces)
    |> Kernel.-(prefix_rows)
    |> Kernel.+(1)
  else
    0
  end

(middle_pieces * repeated_rows + prefix_rows + suffix_rows)
|> IO.inspect()
