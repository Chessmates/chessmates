class Pawn < Piece

  def valid_move?(dest_x, dest_y)
    return false unless super
    return true if capture_move?(dest_x, dest_y)
    return false unless valid_path?(dest_x, dest_y)
    true
  end

  def valid_path?(dest_x, dest_y)
    return false unless dest_x == self.location_x # || diagonal_move
    return false if backwards_move?(dest_y)
    # check for one vertical movement regardless of color
    return true if (dest_y - self.location_y).abs == 1
    # checks whether pawn has not moved, it allows vertical move of 1 or 2 places
    return true if !self.has_moved && [1,2].include?((dest_y - self.location_y).abs)
  end

  def capture_move?(dest_x, dest_y)
    # Check if the pawn is obstructed by another piece
    captured_piece = game.obstruction(dest_x, dest_y)
    return false if captured_piece.blank?
    return false unless captured_piece.white != self.white
    # Tests for diagonal move
    return false unless (dest_y - self.location_y).abs == 1 && (dest_x - self.location_x).abs == 1
    true
  end

  private
  def backwards_move?(dest_y)
   self.white ? location_y > dest_y : location_y < dest_y
  end
end
