class GamesController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create, :update, :destroy, :forfeit]

  def index
    @games = Game.available
  end

  def new
    @game = Game.new
  end

  def create
    @game = current_user.initiated_games.create(game_params)
      if @game.valid?
        redirect_to root_path
    else
    render :new, status: :unprocessable_entity
    end
    @game.update_attributes(turn: current_user.id, white_player_id: current_user.id)
    redirect_to game_path(@game.id)
  end

  def show
    @game = Game.find_by_id(params[:id])
    return render_not_found if @game.blank?
  end

  def update
    @game = Game.find_by_id(params[:id])
    return render_not_found if @game.blank?

    @game.update_attributes(black_player_id: current_user.id)

    if @game.black_player_joined?
      flash[:notice] = 'You joined the game succesfully'
      redirect_to game_path(@game)
    else
      flash[:alert] = 'You did not join the game. Please try again'
    end
  end

  def destroy
    @game = Game.find_by_id(params[:id])
    return render_not_found if @game.blank?

    if @game.white_player != current_user
      return render plain: 'Not Allowed!', status: :forbidden
    end

    @game.destroy
    redirect_to root_path
  end

  def forfeit
    @game = Game.find_by_id(params[:id])
    return render_not_found if @game.blank?

    if ! @game.black_player.nil? && (current_user == @game.white_player || current_user == @game.black_player)
      @game.forfeited!

      if @game.forfeited?
        flash[:notice] = "You have forfeited the game."
        redirect_to game_path(@game)
      else
        flash[:alert] = "Game was NOT forfeited. Please try again."
      end
    else
      flash[:alert] = "You cannot forfeit this game."
      redirect_to game_path(@game)
    end
  end

  private

  def game_params
    params.require(:game).permit(:game_name, :black_player_id, :state)
  end
end
