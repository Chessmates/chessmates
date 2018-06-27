class Knight < Piece

  def valid_move?(x, y)
    return false unless (super && valid_path?(x,y))
    return true
  end

  def valid_path?(x,y)
    (((x - location_x).abs == 2 && (y - location_y).abs == 1) || ((x - location_x).abs == 1 && (y - location_y).abs == 2))  && ((x != location_x) && (y != location_y))
  end
end
