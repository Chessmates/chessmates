class King < Piece

  def valid_move?(x,y)
    return false unless super
    current_x = self.location_x
    current_y = self.location_y
    (x - current_x).abs <= 1 && (y - current_y).abs <= 1
  end

  def can_castle?(rook_x, rook_y, has_moved)
    rook = game.pieces.find_by(location_x: rook_x, location_y: rook_y)
    return false if self.has_moved? || rook.has_moved?
    # return false if game.check?(self.white)
    return false if self.h_obs?(rook_x, rook_y)
    return true
  end

  def can_escape_check?
    range = (-1..1)
    range.each do |x|
      range.each do |y|
        if valid_move(x, y) && threatening_pieces.valid_move?
           return true
        else
          return false
        end
      end
    end
  end

  def castle!(rook_x, rook_y, has_moved)
    rook = game.pieces.find_by(location_x: rook_x, location_y: rook_y)

    if (self.white && rook.white)
      if rook.location_x < self.location_x
        self.update_attributes(location_x: 1, location_y: 0, has_moved: true)
        rook.update_attributes(location_x: 2, location_y: 0, has_moved: true)
      elsif rook.location_x > self.location_x
        self.update_attributes(location_x: 5, location_y: 0, has_moved: true)
        rook.update_attributes(location_x: 4, location_y: 0, has_moved: true)
      end
    elsif !(self.white && rook.white)
      if rook.location_x < self.location_x
        self.update_attributes(location_x: 1, location_y: 7, has_moved: true)
        rook.update_attributes(location_x: 2, location_y: 7, has_moved: true)
      elsif rook.location_x > self.location_x
        self.update_attributes(location_x: 5, location_y: 7, has_moved: true)
        rook.update_attributes(location_x: 4, location_y: 7, has_moved: true)
      end
    end
  end
end
