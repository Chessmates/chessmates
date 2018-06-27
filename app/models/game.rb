class Game < ApplicationRecord

  has_many :pieces, :dependent => :delete_all

  belongs_to :white_player, class_name: 'User'
  belongs_to :black_player, class_name: 'User', optional: true # was "required: false" but that seemed too strict
  after_create :populate_game! # this runs the populate_game! method on a newly-created game

  validates :game_name, presence: true, length: { maximum: 140, minimum: 3 }

  enum state: [:active, :complete, :forfeited, :stalemate]

  scope :available, -> { where black_player_id: nil }

  def self.available
    where(black_player_id: nil)
  end

  def black_player_joined?
    black_player_id == self.black_player_id
  end

  def forfeitable?
    ! self.white_player_id.nil? && ! self.black_player_id.nil?
  end

  def occupied?(dest_x,dest_y)
    pieces.active.where(location_x: dest_x, location_y: dest_y).any?
  end

  def check?(is_white)
    king = King.find_by(white: is_white)
    opponents = pieces.active.where(white: !is_white)
    opponents.each do |piece|
      if piece.valid_move?(king.location_x, king.location_y)
        @threatening_piece = piece
        return true
      end
    end
    false
  end

  #def checkmate?(white)
  #  return false unless check?(white)
  #end

  def populate_game!
    piece_type = [Rook, Knight, Bishop, King, Queen, Bishop, Knight, Rook]
    picture_type_white = ["&#9814;", "&#9816;", "&#9815;", "&#9812;", "&#9813;", "&#9815;", "&#9816;", "&#9814;"]
    picture_type_black = ["&#9820;", "&#9822;", "&#9821;", "&#9818;", "&#9819;", "&#9821;", "&#9822;", "&#9820;"]
    (0..7).each do |i|
      piece_type[i].create(location_x: i, location_y: 0, game_id: self.id, white: true, notcaptured: true, picture: picture_type_white[i], has_moved: false)
      Pawn.create(location_x: i, location_y: 1, game_id: self.id, white: true, notcaptured: true, picture: "&#9817;", has_moved: false)
      piece_type[i].create(location_x: i, location_y: 7, game_id: self.id, white: false, notcaptured: true, picture: picture_type_black[i], has_moved: false)
      Pawn.create(location_x: i, location_y: 6, game_id: self.id, white: false, notcaptured: true, picture: "&#9823;", has_moved: false)
    end
  end

  # The method below allows us to query the database JUST ONCE to get the pieces' locations, when we load/refresh the chessboard
  # Our former approach was querying the database 64 times (once for every chessboard square) per chessboard refresh
  def pieces_by_col_then_row
    return @pieces_by_col_then_row if @pieces_by_col_then_row
    @pieces_by_col_then_row = (0..7).map { Array.new(8) }
    pieces.each do |piece|
      if piece.location_x && piece.location_y
        @pieces_by_col_then_row[piece.location_y][piece.location_x] = piece
      end
    end
    @pieces_by_col_then_row
  end
end
