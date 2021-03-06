class Player < ApplicationRecord
  acts_as_paranoid

  belongs_to :game
  has_many   :sources, dependent: :destroy
  has_many   :memes
  has_many   :messages

  after_create_commit { BroadcastGameJob.perform_later(game, :scoreboard) }
  before_destroy { PlayerChannel.broadcast_to(self, redirect: true) }
  after_destroy_commit :revalidate_game

  validates_uniqueness_of :name, scope: :game
  validates_length_of :name, minimum: 1, maximum: 20
  validate :game_in_play

  def discard_played_sources
    memes.last&.sources&.each { |source| source.discard }
  end

  def active_sources
    sources.reject(&:discarded)
  end

  def master?
    game.master == self
  end

  def czar?
    game.playing && game.round&.czar == self
  end

  def winner?
    game.round&.winner == self
  end

  def ready?
    game.playing && game.round&.memes&.include?(memes.last)
  end

  def playing?
    game.playing && !ready?
  end

  def can_kick?(player)
    master? && self != player
  end

  def inactive?
    sources.empty? || czar?
  end

  private

  def revalidate_game
    game.revalidate
    BroadcastGameJob.perform_later(game, :leave)
  end

  def game_in_play
    return unless game.playing && !game.join_midgame
    errors.add(:base, "game already in play")
  end
end
