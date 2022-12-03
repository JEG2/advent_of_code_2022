IO.stream()
|> Stream.map(&String.trim/1)
|> Stream.map(fn round ->
  [them, me] = String.split(round, " ")

  {
    case them do
      "A" -> :rock
      "B" -> :paper
      "C" -> :scissors
    end,
    case me do
      "X" -> :rock
      "Y" -> :paper
      "Z" -> :scissors
    end
  }
end)
|> Stream.map(fn
  {tie, tie} -> {tie, tie, 3}
  {:rock, :scissors} -> {:rock, :scissors, 0}
  {:paper, :rock} -> {:paper, :rock, 0}
  {:scissors, :paper} -> {:scissors, :paper, 0}
  {them, me} -> {them, me, 6}
end)
|> Stream.map(fn {_them, me, round_score} ->
  play_score =
    case me do
      :rock -> 1
      :paper -> 2
      :scissors -> 3
    end

  play_score + round_score
end)
|> Enum.sum()
|> IO.inspect()
