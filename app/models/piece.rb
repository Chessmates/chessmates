class Piece < ApplicationRecord

  belongs_to :game
  scope :active, -> { where(notcaptured: true) }

  def valid_move?(x,y)
    return false if self.game.forfeited? || !self.opponent_piece?(x,y) # OR King is in check after move
    destination_on_board?(x,y)
  end

  def opponent_piece?(x,y)
    piece_at_x_y = game.pieces.find_by(location_x: x, location_y: y)
    return false if piece_at_x_y && (self.white == piece_at_x_y.white)
    return true
  end

  def move_to!(new_x,new_y)
    piece_at_x_y = game.pieces.find_by(location_x: new_x, location_y: new_y)

    if self.valid_move?(new_x, new_y)
      if piece_at_x_y
        if opponent_piece?(new_x, new_y)
          piece_at_x_y.update_attributes(notcaptured: false, location_x: nil, location_y: nil)
          self.update_attributes(location_x: new_x, location_y: new_y, has_moved: true)
        end
      else
        self.update_attributes(location_x: new_x, location_y: new_y, has_moved: true)
      end
    end
  end


  def destination_on_board?(x,y)
    [x,y].all? { |e| (e.to_i >= 0) && (e.to_i <= 7) }
  end

  def is_obstructed?(x,y)
    v_obs?(x,y) || h_obs?(x,y) || d_obs?(x,y)
  end

  def v_obs?(x,y)
    if (self.location_y < y) && (self.location_x == x)
      count = self.location_y
      while count < (y - 1)
        count = count.next
        if game.pieces.find_by(location_x: x, location_y: count)
          return true
        end
      end
    elsif (self.location_y > y) && (self.location_x == x)
      count = self.location_y
      while count > (y + 1)
        count = count.pred
        if game.pieces.find_by(location_x: x, location_y: count)
          return true
        end
      end
    end
    return false
  end

  def h_obs?(x,y)
    if (self.location_x < x) && (self.location_y == y)
      count = self.location_x
      while count < (x - 1)
        count = count.next
        if game.pieces.find_by(location_x: count, location_y: y)
          return true
        end
      end
    elsif (self.location_x > x) && (self.location_y == y)
      count = self.location_x
      while count > (x + 1)
        count = count.pred
        if game.pieces.find_by(location_x: count, location_y: y)
          return true
        end
      end
    end
    return false
  end

  def d_obs?(x,y)
    a = self.location_x
    b = self.location_y

    if (a-x).abs == (b-y).abs # moves same number of spaces on both axes

      if (a<x) && (b<y)
        # bottom-right direction
        while (a < x-1)
          a = a.next
          b = b.next
          if game.pieces.find_by(location_x: a, location_y: b)
            return true
          end
        end
      end

      if (a<x) && (b>y)
        # top-right direction
        while (a < x-1)
          a = a.next
          b = b.pred
          if game.pieces.find_by(location_x: a, location_y: b)
            return true
          end
        end
      end

      if (a>x) && (b<y)
        # bottom-left direction
        while (b < y-1)
          a = a.pred
          b = b.next
          if game.pieces.find_by(location_x: a, location_y: b)
            return true
          end
        end
      end

      if (a>x) && (b>y)
        # top-left direction
        while (b > y+1)
          a = a.pred
          b = b.pred
          if game.pieces.find_by(location_x: a, location_y: b)
            return true
          end
        end
      end
    end
    return false
  end

  def can_be_captured?
    opponents = game.pieces.where(white: !self.white, notcaptured: true)
    opponents.each do |opponent|
      if opponent.valid_move?(self.location_x, self.location_y)
        return true
      else
        return false
      end
    end
  end

  def can_be_blocked?(king)
    return false if self.type = "Knight" #Knights can't be blocked
    obstruct_locations = []
    range = (-1..1)
    range.each do |i|
      range.each do |j|
        next if [i,j] == [0,0]
        obstruct_locations << [king.location_x+i,king.location_y+j]
      end
    end

    friendlies = pieces.where(white: king.white, notcaptured: true)
    obstruct_locations.each do |location|
      friendlies.each do |friendly|
        if friendly.valid_move?(location[0], location[1])
          return true
        else
          return false
        end
      end
    end
  end
end
