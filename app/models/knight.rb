class Knight < Piece

def valid_move?(x, y)
#return false if

 if ((x - location_x).abs == 2 && (y - location_y).abs == 1) ||
   ((x - location_x).abs == 1 && (y - location_y).abs == 2 ) &&
   ((x != location_x) && (y != location_y))
   return true
 else
   return false
   end 
 end
end
