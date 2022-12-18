gasses =
  IO.read(:eof)
  |> String.trim()
  |> String.split("", trim: true)
  |> List.to_tuple()

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
  at_rest: 0
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
          at_rest: state.at_rest + 1
      }
    end
end)
|> Enum.find(fn state -> state.at_rest == 2022 end)
|> Map.fetch!(:chamber)
|> Enum.map(fn {_x, y} -> y end)
|> Enum.max()
|> Kernel.+(1)
|> IO.inspect()
