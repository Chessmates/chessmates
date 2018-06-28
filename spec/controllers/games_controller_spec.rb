require 'rails_helper'

RSpec.describe GamesController, type: :controller do
  
  describe "games#forfeit action" do
    it "shouldn't allow unauthenticated users forfeit a game" do
      game = FactoryBot.create(:game)
      patch :forfeit, params: {id: game.id, game: { state: 'forfeited' }}

      expect(response).to redirect_to new_user_session_path
    end

    it "should return a 404:Not_Found error is the game cannot be found" do
      game = FactoryBot.create(:game)
      sign_in game.white_player
      patch :forfeit, params: {id: 'booboo', game: { state: 'forfeited' }}

      expect(response).to have_http_status(:not_found)
    end

    it "shouldn't allow a game with just one player to be forfeited" do
      game = FactoryBot.create(:game)
      sign_in game.white_player
      patch :forfeit, params: {id: game.id, game: { state: 'forfeited' }}

      expect(flash[:alert]).to eq "You cannot forfeit this game."
      expect(game.forfeited?).to be false
    end

    it "shouldn't allow a user who is not a player to forfeit the game" do
      game = FactoryBot.create(:game)
      nonPlayer = FactoryBot.create(:white_player)
      sign_in nonPlayer
      patch :forfeit, params: {id: game.id, game: { state: 'forfeited' }}

      expect(flash[:alert]).to eq "You cannot forfeit this game."
      expect(game.forfeited?).to be false
    end

    it "should allow the white player to forfeit a game" do
      game = FactoryBot.create(:game)
      sign_in game.white_player

      patch :forfeit, params: {id: game.id, game: { state: :forfeited }}
      
      expect(game.forfeited?).to be true
      expect(flash[:notice]).to eq "You have forfeited the game."
      expect(response).to redirect_to game_path
    end

    it "should allow the black player to forfeit a game" do
      game = FactoryBot.create(:game)
      bplayer = FactoryBot.create(:white_player)
      game.black_player_id = bplayer.id
      sign_in game.black_player

      patch :forfeit, params: {id: game.id, game: { state: :forfeited }}

      expect(flash[:notice]).to eq "You have forfeited the game."
      expect(game.forfeited?).to be true
      expect(response).to redirect_to game_path
    end
  end

  describe "games#index action" do
    it "should successfully show the page" do
      get :index
      expect(response).to have_http_status(:success)
    end
  end

  describe "games#update action" do

    it "shouldn't allow unauthenticated users to join a game" do
      game = FactoryBot.create(:game)
      user2 = FactoryBot.create(:white_player)

      patch :update, params: { id: game.id, game: { black_player_id: user2.id } }
      expect(response).to redirect_to new_user_session_path

      game.reload
      expect(game.black_player_id).to eq(nil)
      expect(game.white_player_id).to eq(game.white_player.id)
    end

    it "should allow users to join a game as the black player" do
      game = FactoryBot.create(:game)
      user2 = FactoryBot.create(:white_player)
      sign_in user2

      patch :update, params: { id: game.id, game: { black_player_id: user2.id } }
      expect(flash[:notice]).to eq("You joined the game succesfully")
      expect(response).to redirect_to game_path(game)

      game.reload
      expect(game.black_player_id).to eq (user2.id)
		  expect(game.black_player_id).to eq(game.black_player.id)
      expect(game.white_player_id).to eq (game.white_player.id)
    end

    it "should return a 404 error if a game cannot be found" do
      user2 = FactoryBot.create(:white_player)
      sign_in user2

      patch :update, params: { id: 'BOOBOO', game: { black_player_id: user2.id } }
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "games#new action" do

    it "should require users to be logged in" do
      get :new
      expect(response).to redirect_to new_user_session_path
    end

    it "should successfully show the new game form" do
      user = FactoryBot.create(:white_player)
      sign_in user

      get :new
      expect(response).to have_http_status(:success)
    end
  end

  describe "games#create action" do

    it "should require users to be logged in" do
      post :create, params: { game: {game_name: 'ChessKing'} }
      expect(response).to redirect_to new_user_session_path
    end

    it "should create a new game in the database" do
      user = FactoryBot.create(:white_player)
      sign_in user

      post :create, params: { game: { game_name: 'ChessKing' } }
      expect(response).to redirect_to games_path

      game = Game.last
      expect(game.game_name).to eq('ChessKing')
      expect(game.white_player).to eq(user)
    end

    it "should properly deal with validation errors (name too short)" do
      user = FactoryBot.create(:white_player)
      sign_in user

      post :create, params: { game: {game_name: 'Bo'} }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(Game.count).to eq(0)
    end

    it "should properly deal with validation errors (name blank)" do
      user = FactoryBot.create(:white_player)
      sign_in user

      post :create, params: { game: { game_name: '' } }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(Game.count).to eq(0)
    end
  end

  describe "games#show action" do
    it "should successfully show the page if the specified game is found" do
      game = FactoryBot.create(:game)
      get :show, params: { id: game.id }
      expect(response).to have_http_status(:success)
    end

    it "should return a 404 error if the game is not found" do
      get :show, params: { id: 'TACOCAT' }
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "games#destroy action" do
    it "shouldn't allow users who didn't create a game to destroy it" do
      game = FactoryBot.create(:game)
      diff_user = FactoryBot.create(:white_player)
      sign_in diff_user
      delete :destroy, params: { id: game.id }
      expect(response).to have_http_status(:forbidden)
    end

    it "shouldn't let unauthenticated users destroy a game" do
      game = FactoryBot.create(:game)
      delete :destroy, params: { id: game.id }
      expect(response).to redirect_to new_user_session_path
    end

    it "should allow user to successfully delete games" do
      game = FactoryBot.create(:game)
      sign_in game.white_player
      delete :destroy, params: { id: game.id }
      redirect_to root_path

      game = Game.find_by_id(game.id)
      expect(game).to eq nil
    end

    it "should return a 404 error if game with the specified id cannot be found" do
      user_not_owner = FactoryBot.create(:white_player) # user necessary, else redirected to sign-in page
      sign_in user_not_owner
      delete :destroy, params: { id: 'SPACEDUCK' }
      expect(response).to have_http_status(:not_found)
    end
  end
end
