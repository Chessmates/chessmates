class PiecesController < ApplicationController
  before_action :authenticate_user!, only: [:show, :update, :castle]
  
  def create
  end

  def update
    piece = Piece.find_by_id(params[:id])
    return render_not_found if piece.blank?

    if piece.white
      return render_not_found(:forbidden) if current_user != piece.game.white_player 
    else
      return render_not_found(:forbidden) if current_user != piece.game.black_player
    end

    dest_x = params[:piece][:location_x].to_i
    dest_y = params[:piece][:location_y].to_i

    return render_not_found(:forbidden) if !piece.valid_move?(dest_x,dest_y)

    piece.move_to!(dest_x,dest_y)

    ActionCable.server.broadcast 'moves',
        game_id: piece.game.id
      head :ok
  end

  def castle
    piece = Piece.find_by_id(params[:id])
    return render_not_found if piece.blank?

    if piece.white
      return render_not_found(:forbidden) if current_user == piece.game.black_player 
    else
      return render_not_found(:forbidden) if current_user == piece.game.white_player
    end

    piece.castle!(params[:rook_x],params[:rook_y],params[:has_moved])
  end

  private

  def piece_params
    params.require(:piece).permit(:game_id, :location_x, :location_y, :has_moved, :notcaptured)
  end
end
