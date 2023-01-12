Code.require_file("doubly_linked_circular_list.exs")

ExUnit.start()

defmodule DoublyLinkedCircularListTest do
  use ExUnit.Case, async: true

  test "new lists are empty by default" do
    dlcl = DoublyLinkedCircularList.new()
    assert DoublyLinkedCircularList.empty?(dlcl)
  end

  test "round trips from lists" do
    list = [4, 5, 6, 1, 7, 8, 9]
    dlcl = DoublyLinkedCircularList.new(list)
    assert DoublyLinkedCircularList.to_list(dlcl) == list
  end

  test "can move items" do
    dlcl =
      [4, 5, 6, 1, 7, 8, 9]
      |> DoublyLinkedCircularList.new()
      |> DoublyLinkedCircularList.move(1, 1)

    assert DoublyLinkedCircularList.to_list(dlcl) == [4, 5, 6, 7, 1, 8, 9]
  end

  test "can move items backwards" do
    dlcl =
      [4, -2, 5, 6, 7, 8, 9]
      |> DoublyLinkedCircularList.new()
      |> DoublyLinkedCircularList.move(-2, -2)

    assert DoublyLinkedCircularList.to_list(dlcl) == [4, 5, 6, 7, 8, -2, 9]
  end

  test "moving can change the head" do
    dlcl =
      [1, 2, -3, 3, -2, 0, 4]
      |> DoublyLinkedCircularList.new()
      |> DoublyLinkedCircularList.move(1, 1)

    assert DoublyLinkedCircularList.to_list(dlcl) == [2, 1, -3, 3, -2, 0, 4]
  end

  test "many moves" do
    dlcl =
      [1, 2, -3, 3, -2, 0, 4]
      |> DoublyLinkedCircularList.new()
      |> DoublyLinkedCircularList.move(1, 1)
      |> DoublyLinkedCircularList.move(2, 2)
      |> DoublyLinkedCircularList.move(-3, -3)
      |> DoublyLinkedCircularList.move(3, 3)
      |> DoublyLinkedCircularList.move(-2, -2)
      |> DoublyLinkedCircularList.move(0, 0)
      |> DoublyLinkedCircularList.move(4, 4)

    assert DoublyLinkedCircularList.to_list(dlcl) == [1, 2, -3, 4, 0, 3, -2]
  end

  test "item after" do
    dlcl = DoublyLinkedCircularList.new([1, 2, -3, 4, 0, 3, -2])
    assert DoublyLinkedCircularList.item_after(dlcl, 0, 1_000) == 4
    assert DoublyLinkedCircularList.item_after(dlcl, 0, 2_000) == -3
    assert DoublyLinkedCircularList.item_after(dlcl, 0, 3_000) == 2
  end

  test "wrap around" do
    dlcl =
      [4, -2, 5, 6, 7, 8, 9]
      |> DoublyLinkedCircularList.new()
      |> DoublyLinkedCircularList.move(-2, -6)

    assert DoublyLinkedCircularList.to_list(dlcl) == [4, -2, 5, 6, 7, 8, 9]
  end
end
