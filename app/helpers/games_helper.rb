module GamesHelper
  def player_classes(player)
    return "czar"    if player.czar?
    return "playing" if player.playing?
    return "winner"  if player.winner?
    return ""
  end

  def hand_classes(player)
    return "noclick czar-hand" if player.czar?
    return "noclick"      if player.ready?
    return ""
  end

  def display_meme?(player)
    player.ready? || player.czar?
  end

  def display_template?(player)
    !display_meme?(player)
  end
end
