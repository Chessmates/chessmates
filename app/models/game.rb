class Game < ApplicationRecord

  has_many :pieces

  belongs_to :white_player, class_name: 'User'
  belongs_to :black_player, class_name: 'User', optional: true # was "required: false" but that seemed too strict

  validates :game_name, presence: true, length: { maximum: 140, minimum: 3 }

  scope :available, -> { where black_player_id: nil }

  def self.available
    where(black_player_id: nil)
  end

  def black_player_joined?
    black_player_id == self.black_player_id
  end

  def populate_game!
    piece_type = [Rook, Knight, Bishop, King, Queen, Bishop, Knight, Rook]
    (0..7).each do |i|
      piece_type[i].create(location_x: i, location_y: 0, game_id: self.id, white: true)
      Pawn.create(location_x: i, location_y: 1, game_id: self.id, white: true)
      piece_type[i].create(location_x: i, location_y: 7, game_id: self.id, white: false)
      Pawn.create(location_x: i, location_y: 6, game_id: self.id, white: false)
    end
  end
end

