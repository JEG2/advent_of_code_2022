defmodule DoublyLinkedCircularList do
  defstruct head: nil, nodes: %{}

  def new(enum \\ []) do
    Enum.reduce(enum, %__MODULE__{}, fn item, dlcl ->
      append(dlcl, item)
    end)
  end

  def empty?(dlcl), do: map_size(dlcl.nodes) == 0

  def append(%__MODULE__{nodes: nodes}, item) when map_size(nodes) == 0 do
    %__MODULE__{head: item, nodes: %{item => {item, item}}}
  end

  def append(%__MODULE__{nodes: nodes} = dlcl, item)
      when map_size(nodes) == 1 do
    %__MODULE__{
      dlcl
      | nodes: %{
          dlcl.head => {item, item},
          item => {dlcl.head, dlcl.head}
        }
    }
  end

  def append(dlcl, item) do
    if Map.has_key?(dlcl.nodes, item) do
      raise "Items must be unique"
    end

    {tail, after_head} = Map.fetch!(dlcl.nodes, dlcl.head)
    {before_tail, head} = Map.fetch!(dlcl.nodes, tail)

    nodes =
      dlcl.nodes
      |> Map.put(tail, {before_tail, item})
      |> Map.put(item, {tail, head})
      |> Map.put(head, {item, after_head})

    %__MODULE__{dlcl | nodes: nodes}
  end

  def move(%__MODULE__{nodes: nodes} = dlcl, _item, positions)
      when rem(positions, map_size(nodes) - 1) == 0,
      do: dlcl

  def move(dlcl, item, positions) do
    {before_item, after_item} = Map.fetch!(dlcl.nodes, item)
    {two_before_item, ^item} = Map.fetch!(dlcl.nodes, before_item)
    {^item, two_after_item} = Map.fetch!(dlcl.nodes, after_item)

    nodes =
      dlcl.nodes
      |> Map.put(before_item, {two_before_item, after_item})
      |> Map.put(after_item, {before_item, two_after_item})
      |> Map.delete(item)

    move_after =
      if positions < 0 do
        item
        |> Stream.unfold(fn item ->
          {item, dlcl.nodes |> Map.fetch!(item) |> elem(0)}
        end)
        |> Enum.at(rem(abs(positions) + 1, map_size(dlcl.nodes) - 1))
      else
        item
        |> Stream.unfold(fn item ->
          {item, dlcl.nodes |> Map.fetch!(item) |> elem(1)}
        end)
        |> Enum.at(rem(positions, map_size(dlcl.nodes) - 1))
      end

    {before_move, after_move} = Map.fetch!(nodes, move_after)
    {^move_after, two_after_move} = Map.fetch!(nodes, after_move)

    nodes =
      nodes
      |> Map.put(move_after, {before_move, item})
      |> Map.put(item, {move_after, after_move})
      |> Map.put(after_move, {item, two_after_move})

    head =
      if item == dlcl.head do
        after_item
      else
        dlcl.head
      end

    %__MODULE__{head: head, nodes: nodes}
  end

  def item_after(dlcl, item, offset) do
    item
    |> Stream.unfold(fn item ->
      {item, dlcl.nodes |> Map.fetch!(item) |> elem(1)}
    end)
    |> Enum.at(rem(offset, map_size(dlcl.nodes)))
  end

  def to_list(dlcl) do
    dlcl.head
    |> Stream.unfold(fn item ->
      {item, dlcl.nodes |> Map.fetch!(item) |> elem(1)}
    end)
    |> Enum.take(map_size(dlcl.nodes))
  end
end
