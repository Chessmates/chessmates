class Pawn < Piece

  def valid_move?(dest_x, dest_y)
    return false unless valid_path?(dest_x, dest_y) || capture_move?(dest_x, dest_y)
    return false unless super
    true
  end

  def valid_path?(dest_x, dest_y)
    return false unless dest_x == self.location_x
    return false unless one_space?(dest_y) || pawn_first_move_spaces(dest_y)
    return false if backwards_move?(dest_y)
    return true
  end

  def one_space?(dest_y)
    (dest_y - self.location_y).abs == 1
  end

  def pawn_first_move_spaces(dest_y)
    !self.has_moved && [1,2].include?((dest_y - self.location_y).abs)
  end


  def backwards_move?(dest_y)
   self.white ? location_y > dest_y : location_y < dest_y
  end

  def capture_move?(dest_x, dest_y)
    # return false unless (1) destination has opponent_piece (2) forward-only 1-space diagnonal move
    return false unless (self.opponent_piece?(dest_x,dest_y) && ((dest_y - self.location_y).abs == 1 && (dest_x - self.location_x).abs == 1))
    return true
  end
end