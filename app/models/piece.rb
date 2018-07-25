class Piece < ApplicationRecord

  belongs_to :game
  scope :active, -> { where(notcaptured: true) }

  def valid_move?(x,y)
    return false if self.game.forfeited? ||  ! destination_on_board?(x,y) || friendly_at_destination(x,y) || piece_didnt_move(x,y) || move_endangers_king(x,y)
    return true
  end

  def move_endangers_king(x,y)
    current_location = [self.location_x, self.location_y]
    begin
      self.update(location_x: x, location_y: y, has_moved: true)
      reload
      king_in_check = self.game.check?(self.white)
    ensure
      self.update(location_x: current_location.first, location_y: current_location.last)
    end
    return king_in_check
  end

  def piece_at_destination(x,y)
    game.pieces.find_by(location_x: x, location_y: y)
  end

  def opponent_piece?(x,y)
    if piece_at_destination(x,y)
      return false if self.white == piece_at_destination(x,y).white
      return true if self.white != piece_at_destination(x,y).white
    end
  end

  def friendly_at_destination(x,y)
    piece_at_destination(x,y) && !opponent_piece?(x,y)
  end

  def piece_didnt_move(x,y)
    self.location_x == x && self.location_y == y
  end


  def move_to!(new_x,new_y)
    if valid_move?(new_x, new_y)
      if piece_at_destination(new_x, new_y)
        if opponent_piece?(new_x, new_y)
          piece_at_destination(new_x, new_y).update_attributes(notcaptured: false, location_x: nil, location_y: nil)
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

  def can_complete_threat?(opposite_piece)
    self.valid_path?(opposite_piece.location_x,opposite_piece.location_y) && !self.is_obstructed?(opposite_piece.location_x,opposite_piece.location_y)
  end

  def can_be_blocked?(king,blockable_locations=[])
    return false if self.type == "Knight" # Knights can't be blocked
    return false if (self.location_x - king.location_x).abs == 1 || (self.location_y - king.location_y).abs == 1

    if self.vertical_path_to(king)
      self.vertical_places(king,blockable_locations)
    elsif self.horizontal_path_to(king)
      self.horizontal_places(king,blockable_locations)
    elsif self.diagonal_path_to(king)
      self.diagonal_places(king,blockable_locations)
    end

    friendlies = game.pieces.where(white: king.white, notcaptured: true).where.not(type: "King")
    answers = []
    friendlies.each do |f|
      blockable_locations.each do |x,y|
        if f.valid_path?(x,y) && !f.is_obstructed?(x,y)
          answers.push(true)
        else
          answers.push(false)
        end
      end
    end
    return true if answers.include?(true)
    return false
  end

  def vertical_path_to(king)
    if (self.location_x == king.location_x) && ((self.location_y - king.location_y).abs > 1)
      return true
    else
      return false
    end
  end

  def vertical_places(king,blockable_locations=[])
    if self.location_y < king.location_y
      mini = self.location_y
      maxi = king.location_y
    else
      mini = king.location_y
      maxi = self.location_y
    end

    range = (mini+1..maxi-1)

    range.each do |i|
      blockable_locations << [self.location_x, i]
    end
    return blockable_locations
  end

  def horizontal_path_to(king)
    if (self.location_y == king.location_y) && ((self.location_x - king.location_x).abs > 1)
      return true
    else
      return false
    end
  end

  def horizontal_places(king,blockable_locations=[])
    if self.location_x < king.location_x
      mini = self.location_x
      maxi = king.location_x
    else
      mini = king.location_x
      maxi = self.location_x
    end 

    range = (mini+1..maxi-1)

    range.each do |i|
      blockable_locations << [i, self.location_y]
    end
    return blockable_locations
  end

  def diagonal_path_to(king)
    if ((self.location_x - king.location_x).abs == (self.location_y - king.location_y).abs) && ((self.location_x - king.location_x).abs > 1)
      return true
    else
      return false
    end
  end

  def diagonal_places(king,blockable_locations=[])
    if (self.location_x > king.location_x) && (self.location_y < king.location_y)
      a = 1
      while a < (self.location_x - king.location_x).abs
        blockable_locations << [king.location_x + a, king.location_y - a]
        a = a + 1
      end
    elsif (self.location_x > king.location_x) && (self.location_y > king.location_y)
      a = 1
      while a < (self.location_x - king.location_x).abs
        blockable_locations << [king.location_x + a, king.location_y + a]
        a = a + 1
      end
    elsif (self.location_x < king.location_x) && (self.location_y > king.location_y)
      a = 1
      while a < (self.location_x - king.location_x).abs
        blockable_locations << [king.location_x - a, king.location_y + a]
        a = a + 1
      end
    elsif (self.location_x < king.location_x) && (self.location_y < king.location_y)
      a = 1
      while a < (self.location_x - king.location_x).abs
        blockable_locations << [king.location_x - a, king.location_y - a]
        a = a + 1
      end
    end
    return blockable_locations
  end
end
