class King < Piece

  def valid_move?(x,y)
    return false unless super
    current_x = self.location_x
    current_y = self.location_y
    (x - current_x).abs <= 1 && (y - current_y).abs <= 1
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

  def has_valid_move
    # check if king has a valid a move
    # check if all the places around the king can be moved(no threatening_pieces)
    # 
  end

end
