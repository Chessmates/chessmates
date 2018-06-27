class Pawn < Piece

  def valid_move?(dest_x, dest_y)
    return false unless super
    # Allow one place movement at a time
    valid_fwd_move?(dest_x, dest_y)
  end

  def diagonal_move?(dest_x, dest_y)
    (dest_x - self.location_x).abs == (dest_y - self.location_y).abs && (dest_x - self.location_x).abs == 1
  end

  def valid_fwd_move?(dest_x, dest_y)
    return false unless dest_x == self.location_x || capture_valid?(dest_x, dest_y)
    if has_moved? && self.white
      (dest_y - self.location_y) == 1
    elsif has_moved? && !self.white
      (dest_y - self.location_y) == -1
    elsif !has_moved? && self.white
      [1,2].include?(dest_y - self.location_y)
    else
      [-1,-2].include?(dest_y - self.location_y)
    end
  end

  def capture_valid?(dest_x, dest_y)
    captured_piece = game.occupied?(dest_x, dest_y)
    return false if captured_piece.nil? || !is_opponent?(captured_piece)
    diagonal_move?(dest_x, dest_y)
  end

  # def has_moved?
  #   white ? location_y == 1 : location_y == 6
  # end

end
