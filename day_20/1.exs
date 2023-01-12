Code.require_file("doubly_linked_circular_list.exs")

numbers =
  IO.stream()
  |> Stream.map(&String.trim/1)
  |> Enum.map(&String.to_integer/1)

order =
  numbers
  |> Enum.with_index(1)
  |> Enum.map(fn {n, i} -> {"move #{i}:  #{n}", n} end)

ring =
  order
  |> Enum.map(fn {item, _move} -> item end)
  |> DoublyLinkedCircularList.new()

mixed =
  Enum.reduce(order, ring, fn {item, positions}, ring ->
    DoublyLinkedCircularList.move(ring, item, positions)
  end)

zero =
  order
  |> Enum.find(fn {_item, move} -> move == 0 end)
  |> elem(0)

[
  DoublyLinkedCircularList.item_after(mixed, zero, 1_000),
  DoublyLinkedCircularList.item_after(mixed, zero, 2_000),
  DoublyLinkedCircularList.item_after(mixed, zero, 3_000)
]
|> Enum.map(fn item ->
  item
  |> String.split("  ")
  |> tl
  |> hd
  |> String.to_integer()
end)
|> Enum.sum()
|> IO.inspect()
