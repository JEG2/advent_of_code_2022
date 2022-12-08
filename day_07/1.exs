{_path, directories, files} =
  IO.stream()
  |> Stream.map(&String.trim/1)
  |> Enum.reduce({"/", MapSet.new(["/"]), %{}}, fn
    "$ cd /", {_path, directories, files} ->
      {"/", directories, files}

    "$ cd ..", {path, directories, files} ->
      {Path.dirname(path), directories, files}

    "$ cd " <> dir, {path, directories, files} ->
      path = Path.join(path, dir)
      {path, MapSet.put(directories, path), files}

    "$ ls", acc ->
      acc

    "dir " <> _dir, acc ->
      acc

    file, {path, directories, files} ->
      [size, name] = String.split(file, " ")
      size = String.to_integer(size)

      {
        path,
        directories,
        Map.put(files, Path.join(path, name), size)
      }
  end)

directories
|> Enum.reduce(%{}, fn dir, sizes ->
  file_sizes =
    files
    |> Enum.filter(fn {path, _size} -> String.starts_with?(path, dir) end)
    |> Enum.map(&elem(&1, 1))

  size = Enum.sum(file_sizes)
  Map.put(sizes, dir, size)
end)
|> Map.values()
|> Enum.filter(fn size -> size <= 100_000 end)
|> Enum.sum()
|> IO.inspect()
