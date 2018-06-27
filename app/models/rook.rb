class Rook < Piece

  def valid_move?(x,y)
    return false unless (super && valid_path?(x,y) && !is_obstructed?(x,y))
    return true
  end

  def valid_path?(x,y)
    current_x = self.location_x             
    current_y = self.location_y

    (current_x == x && current_y != y) || (current_x != x && current_y == y) 
  end
end
