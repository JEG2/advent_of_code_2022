IO.stream()
|> Stream.map(&String.trim/1)
|> Stream.flat_map(fn motion ->
  [direction, count] = String.split(motion, " ")
  List.duplicate(direction, String.to_integer(count))
end)
|> Stream.scan({0, 0}, fn
  "U", {x, y} ->
    {x, y + 1}

  "D", {x, y} ->
    {x, y - 1}

  "L", {x, y} ->
    {x - 1, y}

  "R", {x, y} ->
    {x + 1, y}
end)
|> Stream.scan({0, 0}, fn
  {head_x, head_y}, {tail_x, tail_y}
  when abs(head_x - tail_x) <= 1 and abs(head_y - tail_y) <= 1 ->
    {tail_x, tail_y}

  {head_x, head_y}, {tail_x, tail_y} ->
    x_move =
      cond do
        tail_x < head_x -> 1
        tail_x == head_x -> 0
        tail_x > head_x -> -1
      end

    y_move =
      cond do
        tail_y < head_y -> 1
        tail_y == head_y -> 0
        tail_y > head_y -> -1
      end

    {tail_x + x_move, tail_y + y_move}
end)
|> Stream.scan({0, 0}, fn
  {head_x, head_y}, {tail_x, tail_y}
  when abs(head_x - tail_x) <= 1 and abs(head_y - tail_y) <= 1 ->
    {tail_x, tail_y}

  {head_x, head_y}, {tail_x, tail_y} ->
    x_move =
      cond do
        tail_x < head_x -> 1
        tail_x == head_x -> 0
        tail_x > head_x -> -1
      end

    y_move =
      cond do
        tail_y < head_y -> 1
        tail_y == head_y -> 0
        tail_y > head_y -> -1
      end

    {tail_x + x_move, tail_y + y_move}
end)
|> Stream.scan({0, 0}, fn
  {head_x, head_y}, {tail_x, tail_y}
  when abs(head_x - tail_x) <= 1 and abs(head_y - tail_y) <= 1 ->
    {tail_x, tail_y}

  {head_x, head_y}, {tail_x, tail_y} ->
    x_move =
      cond do
        tail_x < head_x -> 1
        tail_x == head_x -> 0
        tail_x > head_x -> -1
      end

    y_move =
      cond do
        tail_y < head_y -> 1
        tail_y == head_y -> 0
        tail_y > head_y -> -1
      end

    {tail_x + x_move, tail_y + y_move}
end)
|> Stream.scan({0, 0}, fn
  {head_x, head_y}, {tail_x, tail_y}
  when abs(head_x - tail_x) <= 1 and abs(head_y - tail_y) <= 1 ->
    {tail_x, tail_y}

  {head_x, head_y}, {tail_x, tail_y} ->
    x_move =
      cond do
        tail_x < head_x -> 1
        tail_x == head_x -> 0
        tail_x > head_x -> -1
      end

    y_move =
      cond do
        tail_y < head_y -> 1
        tail_y == head_y -> 0
        tail_y > head_y -> -1
      end

    {tail_x + x_move, tail_y + y_move}
end)
|> Stream.scan({0, 0}, fn
  {head_x, head_y}, {tail_x, tail_y}
  when abs(head_x - tail_x) <= 1 and abs(head_y - tail_y) <= 1 ->
    {tail_x, tail_y}

  {head_x, head_y}, {tail_x, tail_y} ->
    x_move =
      cond do
        tail_x < head_x -> 1
        tail_x == head_x -> 0
        tail_x > head_x -> -1
      end

    y_move =
      cond do
        tail_y < head_y -> 1
        tail_y == head_y -> 0
        tail_y > head_y -> -1
      end

    {tail_x + x_move, tail_y + y_move}
end)
|> Stream.scan({0, 0}, fn
  {head_x, head_y}, {tail_x, tail_y}
  when abs(head_x - tail_x) <= 1 and abs(head_y - tail_y) <= 1 ->
    {tail_x, tail_y}

  {head_x, head_y}, {tail_x, tail_y} ->
    x_move =
      cond do
        tail_x < head_x -> 1
        tail_x == head_x -> 0
        tail_x > head_x -> -1
      end

    y_move =
      cond do
        tail_y < head_y -> 1
        tail_y == head_y -> 0
        tail_y > head_y -> -1
      end

    {tail_x + x_move, tail_y + y_move}
end)
|> Stream.scan({0, 0}, fn
  {head_x, head_y}, {tail_x, tail_y}
  when abs(head_x - tail_x) <= 1 and abs(head_y - tail_y) <= 1 ->
    {tail_x, tail_y}

  {head_x, head_y}, {tail_x, tail_y} ->
    x_move =
      cond do
        tail_x < head_x -> 1
        tail_x == head_x -> 0
        tail_x > head_x -> -1
      end

    y_move =
      cond do
        tail_y < head_y -> 1
        tail_y == head_y -> 0
        tail_y > head_y -> -1
      end

    {tail_x + x_move, tail_y + y_move}
end)
|> Stream.scan({0, 0}, fn
  {head_x, head_y}, {tail_x, tail_y}
  when abs(head_x - tail_x) <= 1 and abs(head_y - tail_y) <= 1 ->
    {tail_x, tail_y}

  {head_x, head_y}, {tail_x, tail_y} ->
    x_move =
      cond do
        tail_x < head_x -> 1
        tail_x == head_x -> 0
        tail_x > head_x -> -1
      end

    y_move =
      cond do
        tail_y < head_y -> 1
        tail_y == head_y -> 0
        tail_y > head_y -> -1
      end

    {tail_x + x_move, tail_y + y_move}
end)
|> Stream.scan({0, 0}, fn
  {head_x, head_y}, {tail_x, tail_y}
  when abs(head_x - tail_x) <= 1 and abs(head_y - tail_y) <= 1 ->
    {tail_x, tail_y}

  {head_x, head_y}, {tail_x, tail_y} ->
    x_move =
      cond do
        tail_x < head_x -> 1
        tail_x == head_x -> 0
        tail_x > head_x -> -1
      end

    y_move =
      cond do
        tail_y < head_y -> 1
        tail_y == head_y -> 0
        tail_y > head_y -> -1
      end

    {tail_x + x_move, tail_y + y_move}
end)
|> MapSet.new()
|> MapSet.size()
|> IO.inspect()
