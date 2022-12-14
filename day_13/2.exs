defmodule Pair do
  def compare([left | _left_rest], [right | _right_rest])
      when is_integer(left) and is_integer(right) and left < right do
    true
  end

  def compare([left | _left_rest], [right | _right_rest])
      when is_integer(left) and is_integer(right) and left > right do
    false
  end

  def compare([left | left_rest], [right | right_rest])
      when is_integer(left) and is_integer(right) and left == right do
    compare(left_rest, right_rest)
  end

  def compare([left | left_rest], [right | right_rest])
      when is_list(left) and is_list(right) do
    case compare(left, right) do
      result when is_boolean(result) ->
        result

      :unknown ->
        compare(left_rest, right_rest)
    end
  end

  def compare([], right) when right != [] do
    true
  end

  def compare(left, []) when left != [] do
    false
  end

  def compare([], []) do
    :unknown
  end

  def compare([left | left_rest], [right | right_rest])
      when is_integer(left) and is_list(right) do
    case compare([left], right) do
      result when is_boolean(result) ->
        result

      :unknown ->
        compare(left_rest, right_rest)
    end
  end

  def compare([left | left_rest], [right | right_rest])
      when is_list(left) and is_integer(right) do
    case compare(left, [right]) do
      result when is_boolean(result) ->
        result

      :unknown ->
        compare(left_rest, right_rest)
    end
  end
end

IO.stream()
|> Stream.map(&String.trim/1)
|> Stream.reject(fn line -> line == "" end)
|> Enum.map(fn line ->
  line |> Code.eval_string() |> elem(0)
end)
|> Kernel.++([[[2]], [[6]]])
|> Enum.sort(fn left, right -> Pair.compare(left, right) end)
|> Enum.with_index(1)
|> Enum.filter(fn {packet, _i} -> packet in [[[2]], [[6]]] end)
|> Enum.map(fn {_ordered, i} -> i end)
|> Enum.product()
|> IO.inspect()
