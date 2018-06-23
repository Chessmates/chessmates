class Piece < ApplicationRecord

  belongs_to :game
  scope :active, -> { where(notcaptured: true) }

  def valid_move?(x,y)
    destination_on_board?(x,y)
  end

  def is_opponent?(piece)
    piece.white == white
  end


  def destination_on_board?(x,y)
    [x,y].all? { |e| (e >= 0) && (e <= 7) }
  end


  def is_obstructed?(x,y) #checking if obstructed in any direction
    v_obs?(x,y) || h_obs?(x,y) || d_obs?(x,y) || invalid(x,y)
  end



  def v_obs?(x,y)
    if (self.location_y < y) && (self.location_x == x)
      count = self.location_y
      until count == y
        count = count.next
        if game.pieces.find_by(location_x: x, location_y: count)
          return true
        end
      end
    elsif (self.location_y > y) && (self.location_x == x)
      count = self.location_y
      until count == y
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
      until count == x
        count = count.next
        if game.pieces.find_by(location_x: count, location_y: y)
          return true
        end
      end
    elsif (self.location_x > x) && (self.location_y == y)
      count = self.location_x
      until count == x
        count = count.pred
        if game.pieces.find_by(location_x: count, location_y: y)
          return true
        end
      end
    end
    return false
  end



  def d_obs?(x,y)
    if (self.location_x < x) && (self.location_y < y) && (x-self.location_x == y-self.location_y)
      a = self.location_x
      b = self.location_y
      until (a == x) && (b == y)
        a = a.next
        b = b.next
        if game.pieces.find_by(location_x: a, location_y: b)
          return true
        end
      end
    elsif (self.location_x < x) && (self.location_y > y) && (x-self.location_x == self.location_y-y)
      a = self.location_x
      b = self.location_y
      until (a == x) && (b == y)
        a = a.next
        b = b.pred
        if game.pieces.find_by(location_x: a, location_y: b)
          return true
        end
      end
    elsif (self.location_x > x) && (self.location_y < y) && (self.location_x-x == y-self.location_y)
      a = self.location_x
      b = self.location_y
      until (a == x) && (b == y)
        a = a.pred
        b = b.next
        if game.pieces.find_by(location_x: a, location_y: b)
          return true
        end
      end
    elsif (self.location_x > x) && (self.location_y > y) && (self.location_x-x == self.location_y-y)
      a = self.location_x
      b = self.location_y
      until (a == x) && (b == y)
        a = a.pred
        b = b.pred
        if game.pieces.find_by(location_x: a, location_y: b)
          return true
        end
      end
    end
  end


  # Each Piece Type must Implement this logic in their Class
  def valid_path?(x,y)
    puts "This method needs to be defined in the piece's Unique Class;\ne.g. for the Queen piece, edit the Queen Class in queen.rb"
  end

  def can_be_captured(piece)
    friendlies = pieces.active.where(white: !piece.white)
    friendlies.each do |friendly|
      if friendly.valid_move?(piece.location_x, piece.location_y)
        return piece
      end
  end

  def can_be_blocked?(king)
    obstruct_locations = []
    range = (-1..1)
    range.each do |i|
      range.each do |j|
        next if [i,j] == [0,0]
        obstruct_locations << [king.location_x+i,king.location_y+j]
      end
    end

    friendlies = pieces.active.where(white: !piece.white)
    obstruct_locations.each do |location|
      friendlies.each do |friendly|
        if friendly.valid_move?(location[0], location[1])
          true
        else
          false
        end
      end
    end
  end


  def move_to!(new_x,new_y)
    dest = game.pieces.find_by(location_x: new_x, location_y: new_y)

    if dest.nil?
      self.update_attributes(location_x: new_x, location_y: new_y)
    elsif dest.white != self.white
      dest.update_attributes(notcaptured: false, location_x: nil, location_y: nil)
      self.update_attributes(location_x: new_x, location_y: new_y)
    else
      return "ERROR! Cannot move there; occupied by a friendly piece"
    end
  end
end
